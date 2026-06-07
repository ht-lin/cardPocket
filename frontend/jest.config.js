module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['<rootDir>/__tests__/setup.ts'],
  testMatch: ['**/__tests__/**/*.{test,spec}.{ts,tsx,js,jsx}'],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^axios$': '<rootDir>/node_modules/axios/dist/node/axios.cjs',
    '^msw$': '<rootDir>/node_modules/msw/lib/core/index.js',
    '^msw/node$': '<rootDir>/node_modules/msw/lib/node/index.js',
    '^rettime$': '<rootDir>/__tests__/mocks/__stubs/rettime.js',
    '^@open-draft/deferred-promise$': '<rootDir>/__tests__/mocks/__stubs/open-draft-deferred-promise.js',
  },
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg|until-async|@open-draft/deferred-promise)',
  ],
};
