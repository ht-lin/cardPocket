import { useState, useCallback } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import {
  CameraView,
  useCameraPermissions,
  type BarcodeType as CameraBarcodeType,
  type BarcodeScanningResult,
} from 'expo-camera';
import type { BarcodeType } from '@/schemas/card';
import { colors, spacing, fontSize, radius } from '@/theme';

const CAMERA_TO_APP_TYPE: Record<string, BarcodeType> = {
  qr: 'QR_CODE',
  code128: 'CODE_128',
  ean13: 'EAN_13',
  ean8: 'EAN_8',
  code39: 'CODE_39',
  upc_a: 'UPC_A',
  pdf417: 'PDF_417',
  aztec: 'AZTEC',
  datamatrix: 'DATA_MATRIX',
};

export default function ScanScreen() {
  const router = useRouter();
  const [permission, requestPermission] = useCameraPermissions();
  const [scanned, setScanned] = useState(false);

  const handleBarcodeScanned = useCallback(
    ({ type, data }: BarcodeScanningResult) => {
      if (scanned) return;
      setScanned(true);
      const barcodeType: BarcodeType = CAMERA_TO_APP_TYPE[type.toLowerCase()] ?? 'QR_CODE';
      router.replace({
        pathname: '/cards/add',
        params: { barcodeContent: data, barcodeType },
      });
    },
    [scanned, router],
  );

  if (!permission) {
    return <View style={styles.center} />;
  }

  if (!permission.granted) {
    return (
      <View style={styles.center}>
        <Text style={styles.permissionText}>需要相机权限才能扫码</Text>
        <TouchableOpacity style={styles.permissionBtn} onPress={requestPermission} activeOpacity={0.8}>
          <Text style={styles.permissionBtnText}>授权相机</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <CameraView
        style={StyleSheet.absoluteFill}
        facing="back"
        onBarcodeScanned={handleBarcodeScanned}
        barcodeScannerSettings={{
          barcodeTypes: [
            'qr', 'code128', 'ean13', 'ean8', 'code39',
            'upc_a', 'pdf417', 'aztec', 'datamatrix',
          ] as CameraBarcodeType[],
        }}
      />
      <View style={styles.overlay}>
        <View style={styles.scanBox} />
        <Text style={styles.hint}>将条码置于框内扫描</Text>
        {scanned && (
          <TouchableOpacity
            style={styles.rescanBtn}
            onPress={() => setScanned(false)}
            activeOpacity={0.8}
          >
            <Text style={styles.rescanText}>重新扫描</Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.background,
    padding: spacing.lg,
  },
  permissionText: {
    fontSize: fontSize.md,
    color: colors.text,
    textAlign: 'center',
    marginBottom: spacing.md,
  },
  permissionBtn: {
    backgroundColor: colors.primary,
    borderRadius: radius.md,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
  },
  permissionBtnText: {
    color: '#fff',
    fontSize: fontSize.md,
    fontWeight: '600',
  },
  overlay: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  scanBox: {
    width: 240,
    height: 240,
    borderWidth: 2,
    borderColor: '#fff',
    borderRadius: radius.md,
    marginBottom: spacing.lg,
  },
  hint: {
    color: '#fff',
    fontSize: fontSize.sm,
    backgroundColor: 'rgba(0,0,0,0.5)',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: radius.sm,
  },
  rescanBtn: {
    marginTop: spacing.md,
    backgroundColor: colors.primary,
    borderRadius: radius.md,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
  },
  rescanText: {
    color: '#fff',
    fontSize: fontSize.sm,
    fontWeight: '600',
  },
});
