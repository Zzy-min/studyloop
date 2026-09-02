import { Firestore } from '@google-cloud/firestore';

export interface RateLimiter {
  check(key: string): Promise<{ allowed: boolean; retryAfterSeconds: number }>;
}

export class MemoryRateLimiter implements RateLimiter {
  private readonly entries = new Map<string, { count: number; resetAt: number }>();

  constructor(
    private readonly limit: number,
    private readonly windowSeconds: number,
  ) {}

  async check(key: string) {
    const now = Date.now();
    const current = this.entries.get(key);
    const entry = !current || current.resetAt <= now
      ? { count: 0, resetAt: now + this.windowSeconds * 1000 }
      : current;
    entry.count += 1;
    this.entries.set(key, entry);
    return {
      allowed: entry.count <= this.limit,
      retryAfterSeconds: Math.max(1, Math.ceil((entry.resetAt - now) / 1000)),
    };
  }
}

export class FirestoreRateLimiter implements RateLimiter {
  private readonly firestore = new Firestore();

  constructor(
    private readonly limit: number,
    private readonly windowSeconds: number,
  ) {}

  async check(key: string) {
    const reference = this.firestore.collection('studyloop_rate_limits').doc(key);
    return this.firestore.runTransaction(async (transaction) => {
      const now = Date.now();
      const snapshot = await transaction.get(reference);
      const existing = snapshot.data() as { count?: number; resetAt?: number } | undefined;
      const resetAt = existing?.resetAt && existing.resetAt > now
        ? existing.resetAt
        : now + this.windowSeconds * 1000;
      const count = existing?.resetAt && existing.resetAt > now
        ? (existing.count ?? 0) + 1
        : 1;
      transaction.set(reference, {
        count,
        resetAt,
        expiresAt: new Date(resetAt + this.windowSeconds * 1000),
      });
      return {
        allowed: count <= this.limit,
        retryAfterSeconds: Math.max(1, Math.ceil((resetAt - now) / 1000)),
      };
    });
  }
}
