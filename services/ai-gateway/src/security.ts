import { createHash, randomUUID } from 'node:crypto';

import { GoogleAuth } from 'google-auth-library';
import { SignJWT, jwtVerify } from 'jose';

import type { GatewayConfig } from './config.js';

export const digest = (value: string) =>
  createHash('sha256').update(value).digest('hex');

interface IntegrityPayload {
  requestDetails?: { requestPackageName?: string; requestHash?: string };
  appIntegrity?: {
    appRecognitionVerdict?: string;
    packageName?: string;
    certificateSha256Digest?: string[];
  };
  accountDetails?: { appLicensingVerdict?: string };
  deviceIntegrity?: { deviceRecognitionVerdict?: string[] };
}

export interface IntegrityVerifier {
  verify(integrityToken: string): Promise<IntegrityPayload>;
}

export class GooglePlayIntegrityVerifier implements IntegrityVerifier {
  private readonly auth = new GoogleAuth({
    scopes: ['https://www.googleapis.com/auth/playintegrity'],
  });

  constructor(private readonly packageName: string) {}

  async verify(integrityToken: string): Promise<IntegrityPayload> {
    const client = await this.auth.getClient();
    const response = await client.request<{ tokenPayloadExternal?: IntegrityPayload }>({
      url: `https://playintegrity.googleapis.com/v1/${this.packageName}:decodeIntegrityToken`,
      method: 'POST',
      data: { integrity_token: integrityToken },
    });
    if (!response.data.tokenPayloadExternal) throw new Error('Invalid integrity response');
    return response.data.tokenPayloadExternal;
  }
}

export function assertProductionIntegrity(
  payload: IntegrityPayload,
  requestHash: string,
  config: GatewayConfig,
) {
  const verdict = payload.appIntegrity;
  const deviceVerdicts = payload.deviceIntegrity?.deviceRecognitionVerdict ?? [];
  const certificates = verdict?.certificateSha256Digest ?? [];
  const certificateAccepted = certificates.some((value) =>
    config.allowedCertificateDigests.has(value.toLowerCase()),
  );
  if (
    payload.requestDetails?.requestPackageName !== config.packageName ||
    payload.requestDetails.requestHash !== requestHash ||
    verdict?.appRecognitionVerdict !== 'PLAY_RECOGNIZED' ||
    verdict.packageName !== config.packageName ||
    !certificateAccepted ||
    payload.accountDetails?.appLicensingVerdict !== 'LICENSED' ||
    !deviceVerdicts.includes('MEETS_DEVICE_INTEGRITY')
  ) {
    throw new Error('Integrity verdict rejected');
  }
}

export class SessionIssuer {
  private readonly secret: Uint8Array;

  constructor(secret: string) {
    this.secret = new TextEncoder().encode(secret);
  }

  async issue(installationId: string) {
    return new SignJWT({ installation: digest(installationId) })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuer('studyloop-ai-gateway')
      .setAudience('studyloop-mobile')
      .setSubject(digest(installationId))
      .setJti(randomUUID())
      .setIssuedAt()
      .setExpirationTime('15m')
      .sign(this.secret);
  }

  async verify(header: string | undefined) {
    const token = header?.replace(/^Bearer\s+/i, '');
    if (!token) throw new Error('Missing bearer token');
    const verified = await jwtVerify(token, this.secret, {
      issuer: 'studyloop-ai-gateway',
      audience: 'studyloop-mobile',
    });
    if (!verified.payload.sub) throw new Error('Invalid session subject');
    return verified.payload.sub;
  }
}
