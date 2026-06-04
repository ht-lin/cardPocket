import { ExpoConfig, ConfigContext } from 'expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...(config as ExpoConfig),
  extra: {
    apiBaseUrl: process.env.API_BASE_URL ?? 'http://localhost:8000',
  },
});
