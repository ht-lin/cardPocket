export const colors = {
  primary: '#2563EB',
  primaryLight: '#EFF6FF',
  surface: '#FFFFFF',
  background: '#F8FAFC',
  border: '#E2E8F0',
  text: '#0F172A',
  textMuted: '#64748B',
  danger: '#DC2626',
  success: '#16A34A',
  warning: '#D97706',
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
} as const;

export const radius = {
  sm: 6,
  md: 10,
  lg: 16,
  card: 16,
  full: 9999,
} as const;

export const fontSize = {
  xs: 12,
  sm: 14,
  md: 16,
  lg: 18,
  xl: 22,
  xxl: 28,
} as const;

export const fontWeight = {
  regular: '400' as const,
  medium: '500' as const,
  semibold: '600' as const,
  bold: '700' as const,
};
