import { useMemo } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import QRCode from 'react-native-qrcode-svg';
import { SvgXml } from 'react-native-svg';
import { DOMImplementation, XMLSerializer } from '@xmldom/xmldom';
import JsBarcode from 'jsbarcode';
import type { BarcodeType } from '@/schemas/card';
import { colors, fontSize, spacing } from '@/theme';

type Props = {
  barcodeType: BarcodeType;
  barcodeContent: string;
  size?: number;
};

const JBS_FORMAT: Partial<Record<BarcodeType, string>> = {
  CODE_128: 'CODE128',
  EAN_13: 'EAN13',
  EAN_8: 'EAN8',
  CODE_39: 'CODE39',
  UPC_A: 'UPC',
};

function generateBarcodeSvg(value: string, format: string): string | null {
  try {
    const doc = new DOMImplementation().createDocument('http://www.w3.org/2000/svg', 'svg', null);
    const svg = doc.documentElement;
    (JsBarcode as Function)(svg, value, { format, xmlDocument: doc, margin: 10 });
    return new XMLSerializer().serializeToString(svg);
  } catch {
    return null;
  }
}

export function BarcodeDisplay({ barcodeType, barcodeContent, size = 220 }: Props) {
  const svgXml = useMemo(() => {
    const fmt = JBS_FORMAT[barcodeType];
    if (!fmt) return null;
    return generateBarcodeSvg(barcodeContent, fmt);
  }, [barcodeType, barcodeContent]);

  if (barcodeType === 'QR_CODE') {
    return (
      <View testID="barcode-qr" style={styles.center}>
        <QRCode value={barcodeContent || ' '} size={size} />
      </View>
    );
  }

  if (JBS_FORMAT[barcodeType]) {
    if (!svgXml) {
      return (
        <View testID="barcode-svg-error" style={styles.error}>
          <Text style={styles.errorText}>条码内容无效</Text>
        </View>
      );
    }
    return (
      <View testID="barcode-svg" style={styles.center}>
        <SvgXml xml={svgXml} width={size * 1.4} height={size * 0.6} />
      </View>
    );
  }

  return (
    <View testID="barcode-fallback" style={styles.fallback}>
      <Text style={styles.fallbackLabel}>{barcodeType.replace('_', ' ')}</Text>
      <Text style={styles.fallbackContent}>{barcodeContent}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  center: {
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.md,
  },
  error: {
    alignItems: 'center',
    padding: spacing.md,
  },
  errorText: {
    color: colors.danger,
    fontSize: fontSize.sm,
  },
  fallback: {
    alignItems: 'center',
    padding: spacing.lg,
    backgroundColor: colors.surface,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: colors.border,
  },
  fallbackLabel: {
    fontSize: fontSize.xs,
    color: colors.textMuted,
    marginBottom: spacing.xs,
    letterSpacing: 1,
  },
  fallbackContent: {
    fontSize: fontSize.md,
    color: colors.text,
    fontWeight: '600',
    textAlign: 'center',
  },
});
