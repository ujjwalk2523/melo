import { Response } from 'express';
import { z } from 'zod';
import { SyncService } from '../sync/sync.service.js';
import { AuthenticatedRequest } from '../auth/auth.middleware.js';

const syncOperationSchema = z.object({
  id: z.string().min(1),
  entityType: z.enum(['favorite', 'playlist', 'playlist_song', 'history', 'preference']),
  entityId: z.string().min(1),
  operationType: z.enum(['upsert', 'delete']),
  payload: z.record(z.any()).default({}),
  clientTimestamp: z.string(),
});

const pushSchema = z.object({
  operations: z.array(syncOperationSchema).default([]),
  lastSyncTimestamp: z.string().optional(),
});

const fullSyncSchema = z.object({
  operations: z.array(syncOperationSchema).optional().default([]),
});

export class SyncController {
  constructor(private syncService: SyncService) {}

  pull = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const state = await this.syncService.pull(userId);
      res.status(200).json(state);
    } catch (err: any) {
      res.status(500).json({ error: 'Sync Pull Failed', message: err.message });
    }
  };

  push = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const parsed = pushSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({
          error: 'Validation Error',
          details: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const result = await this.syncService.push(userId, parsed.data);
      res.status(200).json(result);
    } catch (err: any) {
      res.status(500).json({ error: 'Sync Push Failed', message: err.message });
    }
  };

  sync = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const parsed = fullSyncSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({
          error: 'Validation Error',
          details: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const result = await this.syncService.fullSync(userId, parsed.data.operations);
      res.status(200).json(result);
    } catch (err: any) {
      res.status(500).json({ error: 'Full Sync Failed', message: err.message });
    }
  };
}
