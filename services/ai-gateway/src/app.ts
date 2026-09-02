import { randomUUID } from 'node:crypto';

import Fastify from 'fastify';

import type { GatewayConfig } from './config.js';
import { companionRequestSchema, sessionRequestSchema } from './contracts.js';
import type { CompanionModel } from './deepseek.js';
import type { RateLimiter } from './rate_limiter.js';
import {
  assertProductionIntegrity,
  digest,
  type IntegrityVerifier,
  SessionIssuer,
} from './security.js';

interface Dependencies {
  integrityVerifier: IntegrityVerifier;
  rateLimiter: RateLimiter;
  companionModel: CompanionModel;
}

export function createApp(config: GatewayConfig, dependencies: Dependencies) {
  const app = Fastify({ logger: true, trustProxy: true });
  const sessions = new SessionIssuer(config.sessionSigningSecret);

  app.get('/health', async () => ({ status: 'ok' }));

  app.post('/v1/session', async (request, reply) => {
    const requestId = randomUUID();
    const parsed = sessionRequestSchema.safeParse(request.body);
    if (!parsed.success) return reply.code(400).send({ error: 'invalid_request' });
    try {
      const verdict = await dependencies.integrityVerifier.verify(parsed.data.integrityToken);
      assertProductionIntegrity(verdict, parsed.data.requestHash, config);
      const accessToken = await sessions.issue(parsed.data.installationId);
      request.log.info({ event: 'session_issued', requestId }, 'StudyLoop session issued');
      return { accessToken, expiresInSeconds: 900 };
    } catch {
      request.log.warn({ event: 'integrity_rejected', requestId }, 'StudyLoop integrity rejected');
      return reply.code(401).send({ error: 'integrity_rejected' });
    }
  });

  app.post('/v1/companion', async (request, reply) => {
    const requestId = randomUUID();
    let installationHash: string;
    try {
      installationHash = await sessions.verify(request.headers.authorization);
    } catch {
      return reply.code(401).send({ error: 'invalid_session' });
    }
    const parsed = companionRequestSchema.safeParse(request.body);
    if (!parsed.success) return reply.code(400).send({ error: 'invalid_request' });

    const forwardedFor = request.ip || 'unknown';
    const installLimit = await dependencies.rateLimiter.check(`install-${installationHash}`);
    const ipLimit = await dependencies.rateLimiter.check(`ip-${digest(forwardedFor)}`);
    if (!installLimit.allowed || !ipLimit.allowed) {
      const retryAfterSeconds = Math.max(installLimit.retryAfterSeconds, ipLimit.retryAfterSeconds);
      reply.header('Retry-After', retryAfterSeconds);
      request.log.warn({ event: 'rate_limited', requestId }, 'StudyLoop request rate limited');
      return reply.code(429).send({ error: 'rate_limited' });
    }

    const startedAt = Date.now();
    try {
      const result = await dependencies.companionModel.respond(parsed.data);
      request.log.info(
        { event: 'companion_completed', requestId, latencyMs: Date.now() - startedAt },
        'StudyLoop companion completed',
      );
      return result;
    } catch {
      request.log.error(
        { event: 'companion_failed', requestId, latencyMs: Date.now() - startedAt },
        'StudyLoop companion failed',
      );
      return reply.code(503).send({ error: 'companion_unavailable' });
    }
  });

  return app;
}
