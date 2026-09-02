export interface GatewayConfig {
  port: number;
  packageName: string;
  cloudProjectId: string;
  sessionSigningSecret: string;
  deepSeekApiKey: string;
  allowedCertificateDigests: Set<string>;
  model: string;
  maxRequestsPerWindow: number;
  rateLimitWindowSeconds: number;
}

const numberValue = (value: string | undefined, fallback: number) => {
  const parsed = Number(value ?? fallback);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

export function loadConfig(env: NodeJS.ProcessEnv = process.env): GatewayConfig {
  const required = [
    'GOOGLE_CLOUD_PROJECT',
    'SESSION_SIGNING_SECRET',
    'DEEPSEEK_API_KEY',
    'PLAY_APP_CERT_SHA256',
  ];
  const missing = required.filter((name) => !env[name]?.trim());
  if (missing.length > 0) {
    throw new Error(`Missing required gateway configuration: ${missing.join(', ')}`);
  }
  return {
    port: numberValue(env.PORT, 8080),
    packageName: env.PLAY_PACKAGE_NAME?.trim() || 'com.zzy.studyloop',
    cloudProjectId: env.GOOGLE_CLOUD_PROJECT!.trim(),
    sessionSigningSecret: env.SESSION_SIGNING_SECRET!.trim(),
    deepSeekApiKey: env.DEEPSEEK_API_KEY!.trim(),
    allowedCertificateDigests: new Set(
      env.PLAY_APP_CERT_SHA256!
        .split(',')
        .map((value) => value.trim().toLowerCase())
        .filter(Boolean),
    ),
    model: env.DEEPSEEK_MODEL?.trim() || 'deepseek-chat',
    maxRequestsPerWindow: numberValue(env.AI_RATE_LIMIT_REQUESTS, 30),
    rateLimitWindowSeconds: numberValue(env.AI_RATE_LIMIT_WINDOW_SECONDS, 900),
  };
}
