import { createApp } from './app.js';
import { loadConfig } from './config.js';
import { DeepSeekCompanionModel } from './deepseek.js';
import { FirestoreRateLimiter } from './rate_limiter.js';
import { GooglePlayIntegrityVerifier } from './security.js';

const config = loadConfig();
const app = createApp(config, {
  integrityVerifier: new GooglePlayIntegrityVerifier(config.packageName),
  rateLimiter: new FirestoreRateLimiter(
    config.maxRequestsPerWindow,
    config.rateLimitWindowSeconds,
  ),
  companionModel: new DeepSeekCompanionModel(config),
});

await app.listen({ port: config.port, host: '0.0.0.0' });
