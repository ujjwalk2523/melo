import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { ICloudStore } from '../db/cloud-store.interface.js';
import {
  AuthSuccessResponse,
  AuthTokens,
  AuthUserResponse,
  TokenPayload,
} from './auth.types.js';

const JWT_SECRET = process.env.JWT_SECRET || 'melo_secret_jwt_key_development_2026';
const ACCESS_TOKEN_EXPIRY = 3600; // 1 hour in seconds
const REFRESH_TOKEN_EXPIRY = 30 * 24 * 3600; // 30 days in seconds

export class AuthService {
  constructor(private cloudStore: ICloudStore) {}

  private generateTokens(userId: string, email: string): AuthTokens {
    const accessPayload: TokenPayload = {
      userId,
      email,
      type: 'access',
    };
    const refreshPayload: TokenPayload = {
      userId,
      email,
      type: 'refresh',
    };

    const accessToken = jwt.sign(accessPayload, JWT_SECRET, {
      expiresIn: ACCESS_TOKEN_EXPIRY,
    });
    const refreshToken = jwt.sign(refreshPayload, JWT_SECRET, {
      expiresIn: REFRESH_TOKEN_EXPIRY,
    });

    return {
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TOKEN_EXPIRY,
      tokenType: 'Bearer',
    };
  }

  verifyToken(token: string, expectedType: 'access' | 'refresh' = 'access'): TokenPayload {
    try {
      const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload;
      if (decoded.type !== expectedType) {
        throw new Error(`Invalid token type. Expected ${expectedType}, received ${decoded.type}`);
      }
      return decoded;
    } catch (err: any) {
      throw new Error(err.message || 'Invalid or expired authentication token');
    }
  }

  async register(params: {
    email: string;
    password: string;
    displayName: string;
  }): Promise<AuthSuccessResponse> {
    const normalizedEmail = params.email.trim().toLowerCase();

    // Check if user already exists
    const existing = await this.cloudStore.findUserByEmail(normalizedEmail);
    if (existing) {
      const err = new Error('An account with this email address already exists');
      (err as any).statusCode = 409;
      throw err;
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(params.password, salt);

    // Create user in store
    const user = await this.cloudStore.createUser(normalizedEmail, passwordHash);

    // Create profile
    const profile = await this.cloudStore.upsertProfile(user.id, {
      displayName: params.displayName.trim(),
    });

    const tokens = this.generateTokens(user.id, user.email);

    return {
      user: {
        id: user.id,
        email: user.email,
        displayName: profile.displayName,
        avatarUrl: profile.avatarUrl ?? null,
        createdAt: user.createdAt.toISOString(),
      },
      tokens,
    };
  }

  async login(params: {
    email: string;
    password: string;
  }): Promise<AuthSuccessResponse> {
    const normalizedEmail = params.email.trim().toLowerCase();

    const user = await this.cloudStore.findUserByEmail(normalizedEmail);
    if (!user || !user.passwordHash) {
      const err = new Error('Invalid email or password');
      (err as any).statusCode = 401;
      throw err;
    }

    const isValidPassword = await bcrypt.compare(params.password, user.passwordHash);
    if (!isValidPassword) {
      const err = new Error('Invalid email or password');
      (err as any).statusCode = 401;
      throw err;
    }

    const profile = await this.cloudStore.getProfile(user.id);
    const tokens = this.generateTokens(user.id, user.email);

    return {
      user: {
        id: user.id,
        email: user.email,
        displayName: profile?.displayName || user.email.split('@')[0],
        avatarUrl: profile?.avatarUrl ?? null,
        createdAt: user.createdAt.toISOString(),
      },
      tokens,
    };
  }

  async refreshTokens(refreshToken: string): Promise<AuthTokens> {
    const decoded = this.verifyToken(refreshToken, 'refresh');
    const user = await this.cloudStore.findUserById(decoded.userId);
    if (!user) {
      const err = new Error('User not found or account deactivated');
      (err as any).statusCode = 401;
      throw err;
    }

    return this.generateTokens(user.id, user.email);
  }

  async getProfile(userId: string): Promise<AuthUserResponse> {
    const user = await this.cloudStore.findUserById(userId);
    if (!user) {
      const err = new Error('User not found');
      (err as any).statusCode = 404;
      throw err;
    }
    const profile = await this.cloudStore.getProfile(userId);

    return {
      id: user.id,
      email: user.email,
      displayName: profile?.displayName || user.email.split('@')[0],
      avatarUrl: profile?.avatarUrl ?? null,
      createdAt: user.createdAt.toISOString(),
    };
  }

  async updateProfile(
    userId: string,
    data: { displayName?: string; avatarUrl?: string | null }
  ): Promise<AuthUserResponse> {
    const user = await this.cloudStore.findUserById(userId);
    if (!user) {
      const err = new Error('User not found');
      (err as any).statusCode = 404;
      throw err;
    }

    const currentProfile = await this.cloudStore.getProfile(userId);
    const displayName = data.displayName?.trim() || currentProfile?.displayName || user.email.split('@')[0];

    const updatedProfile = await this.cloudStore.upsertProfile(userId, {
      displayName,
      avatarUrl: data.avatarUrl !== undefined ? data.avatarUrl : currentProfile?.avatarUrl,
    });

    return {
      id: user.id,
      email: user.email,
      displayName: updatedProfile.displayName,
      avatarUrl: updatedProfile.avatarUrl ?? null,
      createdAt: user.createdAt.toISOString(),
    };
  }

  async forgotPassword(email: string): Promise<{ message: string }> {
    // Security requirement: Do not reveal whether a particular email exists.
    // Always return success message.
    return {
      message: 'If an account exists for this email, a password reset link has been sent.',
    };
  }

  async deleteAccount(userId: string): Promise<void> {
    const user = await this.cloudStore.findUserById(userId);
    if (!user) {
      const err = new Error('User not found');
      (err as any).statusCode = 404;
      throw err;
    }
    await this.cloudStore.deleteUser(userId);
  }
}
