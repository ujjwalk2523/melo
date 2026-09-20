import { MusicProvider } from '../providers/interfaces/music-provider.js';
import { AudiusProvider } from '../providers/audius/audius.provider.js';
import { JamendoProvider } from '../providers/jamendo/jamendo.provider.js';
import { AppError } from '../utils/app-error.js';

export class ProviderRegistry {
  private readonly providers: Map<string, MusicProvider> = new Map();
  private defaultProviderName: string = 'audius';

  constructor() {
    // Register default built-in providers
    this.register(new AudiusProvider());
    this.register(new JamendoProvider());
  }

  public register(provider: MusicProvider): void {
    this.providers.set(provider.name.toLowerCase(), provider);
  }

  public get(name?: string): MusicProvider {
    const target = (name || this.defaultProviderName).toLowerCase().trim();
    const provider = this.providers.get(target);

    if (!provider) {
      const available = Array.from(this.providers.keys()).join(', ');
      throw AppError.badRequest(
        `Unknown music provider '${name}'. Available providers: ${available}`,
        'INVALID_PROVIDER'
      );
    }

    return provider;
  }

  public listProviders(): string[] {
    return Array.from(this.providers.keys());
  }

  public setDefault(name: string): void {
    if (!this.providers.has(name.toLowerCase())) {
      throw AppError.badRequest(`Cannot set unknown provider '${name}' as default`);
    }
    this.defaultProviderName = name.toLowerCase();
  }

  public getDefaultName(): string {
    return this.defaultProviderName;
  }
}
