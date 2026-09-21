import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z
    .string()
    .default('4000')
    .transform((val) => parseInt(val, 10)),
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
  CORS_ORIGIN: z.string().default('http://localhost:3000'),

  // Audius Configuration
  AUDIUS_API_URL: z.string().url().default('https://discoveryprovider.audius.co'),
  AUDIUS_APP_NAME: z.string().default('melo_app'),

  // Jamendo Configuration (Optional credentials)
  JAMENDO_API_URL: z.string().url().default('https://api.jamendo.com/v3.0'),
  JAMENDO_CLIENT_ID: z.string().optional().default(''),

  // Auth & Cloud Database Configuration
  JWT_SECRET: z.string().default('melo_secret_jwt_key_development_2026'),
  SUPABASE_URL: z.string().url().optional(),
  SUPABASE_ANON_KEY: z.string().optional(),
}).superRefine((data, ctx) => {
  if (data.NODE_ENV === 'production') {
    if (data.JWT_SECRET === 'melo_secret_jwt_key_development_2026') {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['JWT_SECRET'],
        message: 'JWT_SECRET must not use the default development key in production mode',
      });
    }
    if (data.JWT_SECRET.length < 32) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['JWT_SECRET'],
        message: 'JWT_SECRET must be at least 32 characters in production',
      });
    }
    if (data.CORS_ORIGIN === '*') {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['CORS_ORIGIN'],
        message: 'Wildcard CORS_ORIGIN is not allowed in production mode',
      });
    }
  }
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Invalid environment configuration:', parsed.error.format());
  throw new Error('Environment variable validation failed');
}

export const env = parsed.data;
