import assert from 'node:assert/strict';
import test from 'node:test';

import { createApp } from '../src/app.js';
import type { GatewayConfig } from '../src/config.js';
import { MemoryRateLimiter } from '../src/rate_limiter.js';

const certificate = 'a'.repeat(64);
const config: GatewayConfig = {
  port: 8080,
  packageName: 'com.zzy.studyloop',
  cloudProjectId: 'studyloop-test',
  sessionSigningSecret: 'test-signing-secret-with-enough-entropy',
  deepSeekApiKey: 'not-used-by-tests',
  allowedCertificateDigests: new Set([certificate]),
  model: 'deepseek-chat',
  maxRequestsPerWindow: 2,
  rateLimitWindowSeconds: 60,
};

const acceptedVerdict = {
  requestDetails: {
    requestPackageName: config.packageName,
    requestHash: 'b6bdc9b9-6f9a-48d3-a606-b4a4fa90e6dd',
  },
  appIntegrity: {
    appRecognitionVerdict: 'PLAY_RECOGNIZED',
    packageName: config.packageName,
    certificateSha256Digest: [certificate],
  },
  accountDetails: { appLicensingVerdict: 'LICENSED' },
  deviceIntegrity: { deviceRecognitionVerdict: ['MEETS_DEVICE_INTEGRITY'] },
};

const newApp = (overrides: Partial<typeof acceptedVerdict> = {}) =>
  createApp(config, {
    integrityVerifier: { verify: async () => ({ ...acceptedVerdict, ...overrides }) },
    rateLimiter: new MemoryRateLimiter(config.maxRequestsPerWindow, config.rateLimitWindowSeconds),
    companionModel: {
      respond: async () => ({ reply: 'Start with one small step.', intent: 'support' }),
    },
  });

test('issues a short-lived session only for a verified Play installation', async () => {
  const app = newApp();
  const response = await app.inject({
    method: 'POST',
    url: '/v1/session',
    payload: {
      installationId: '4a21a53d-c6d9-4aee-b493-b188ba82bbc8',
      requestHash: acceptedVerdict.requestDetails.requestHash,
      integrityToken: 'x'.repeat(64),
    },
  });
  assert.equal(response.statusCode, 200);
  assert.equal(typeof response.json().accessToken, 'string');
  await app.close();
});

test('rejects an unlicensed or mismatched integrity result', async () => {
  const app = newApp({ accountDetails: { appLicensingVerdict: 'UNLICENSED' } });
  const response = await app.inject({
    method: 'POST',
    url: '/v1/session',
    payload: {
      installationId: '4a21a53d-c6d9-4aee-b493-b188ba82bbc8',
      requestHash: acceptedVerdict.requestDetails.requestHash,
      integrityToken: 'x'.repeat(64),
    },
  });
  assert.equal(response.statusCode, 401);
  assert.deepEqual(response.json(), { error: 'integrity_rejected' });
  await app.close();
});

test('requires a session and rate limits companion requests', async () => {
  const app = newApp();
  const session = await app.inject({
    method: 'POST',
    url: '/v1/session',
    payload: {
      installationId: '4a21a53d-c6d9-4aee-b493-b188ba82bbc8',
      requestHash: acceptedVerdict.requestDetails.requestHash,
      integrityToken: 'x'.repeat(64),
    },
  });
  const token = session.json().accessToken;
  const request = {
    method: 'POST' as const,
    url: '/v1/companion',
    headers: { authorization: `Bearer ${token}` },
    payload: {
      message: 'Help me begin.',
      locale: 'en-US',
      context: { state: 'waiting', currentFocusSeconds: 0 },
    },
  };
  assert.equal((await app.inject(request)).statusCode, 200);
  assert.equal((await app.inject(request)).statusCode, 200);
  assert.equal((await app.inject(request)).statusCode, 429);
  await app.close();
});
