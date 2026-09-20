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
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Invalid environment configuration:', parsed.error.format());
  throw new Error('Environment variable validation failed');
}

export const env = parsed.data;
