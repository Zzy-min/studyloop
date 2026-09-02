import { z } from 'zod';

const enumValues = <T extends readonly [string, ...string[]]>(values: T) =>
  z.enum(values);

export const sessionRequestSchema = z.object({
  installationId: z.string().uuid(),
  requestHash: z.string().uuid(),
  integrityToken: z.string().min(32).max(20_000),
});

export const companionRequestSchema = z.object({
  message: z.string().trim().max(2_000),
  locale: z.string().regex(/^[a-z]{2}(-[A-Z]{2})?$/).max(8),
  context: z.object({
    barrier: enumValues(['uncertainStart', 'overload', 'phoneDistraction', 'tiredness', 'perfectionism']).nullable().optional(),
    taskType: enumValues(['examRevision', 'homework', 'programmingPractice', 'paperWriting', 'reading', 'memorization', 'preview', 'project', 'other']).nullable().optional(),
    currentTask: z.string().trim().max(300).nullable().optional(),
    state: enumValues(['waiting', 'prompting', 'focusing', 'completed', 'interrupted', 'resting']).nullable().optional(),
    currentFocusSeconds: z.number().int().min(0).max(86_400).nullable().optional(),
    deterministicInsightText: z.string().trim().max(500).nullable().optional(),
    recentSummary: z.object({
      sessionCount7Days: z.number().int().min(0).max(1000),
      completedCount7Days: z.number().int().min(0).max(1000),
      avgActualMinutes: z.number().min(0).max(1440),
      primaryTaskType: z.string().max(32).nullable().optional(),
      primaryBarrier: z.string().max(32).nullable().optional(),
    }).nullable().optional(),
  }).strict(),
}).strict();

export type CompanionRequest = z.infer<typeof companionRequestSchema>;
