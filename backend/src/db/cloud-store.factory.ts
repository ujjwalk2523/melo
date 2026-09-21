import { ICloudStore } from './cloud-store.interface.js';
import { MemoryCloudStore } from './memory-cloud-store.js';
import { SupabaseCloudStore } from './supabase-cloud-store.js';

let instance: ICloudStore | null = null;

export function getCloudStore(): ICloudStore {
  if (instance) return instance;

  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

  if (supabaseUrl && supabaseKey) {
    instance = new SupabaseCloudStore(supabaseUrl, supabaseKey);
  } else {
    instance = new MemoryCloudStore();
  }

  return instance;
}

export function setCloudStoreForTesting(mockStore: ICloudStore): void {
  instance = mockStore;
}
