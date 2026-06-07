import React from 'react';
import { render } from '@testing-library/react-native';
import { BarcodeDisplay } from '@/components/cards/BarcodeDisplay';
import type { BarcodeType } from '@/schemas/card';

jest.mock('react-native-qrcode-svg', () => jest.fn(() => null));

jest.mock('react-native-svg', () => ({
  SvgXml: jest.fn(() => null),
}));

jest.mock('jsbarcode', () => jest.fn());

jest.mock('@xmldom/xmldom', () => ({
  DOMImplementation: jest.fn(() => ({
    createDocument: jest.fn(() => ({ documentElement: {} })),
  })),
  XMLSerializer: jest.fn(() => ({
    serializeToString: jest.fn(() => '<svg/>'),
  })),
}));

const CASES: Array<{ type: BarcodeType; testID: string }> = [
  { type: 'QR_CODE', testID: 'barcode-qr' },
  { type: 'CODE_128', testID: 'barcode-svg' },
  { type: 'EAN_13', testID: 'barcode-svg' },
  { type: 'EAN_8', testID: 'barcode-svg' },
  { type: 'CODE_39', testID: 'barcode-svg' },
  { type: 'UPC_A', testID: 'barcode-svg' },
  { type: 'PDF_417', testID: 'barcode-fallback' },
  { type: 'AZTEC', testID: 'barcode-fallback' },
  { type: 'DATA_MATRIX', testID: 'barcode-fallback' },
];

describe('BarcodeDisplay', () => {
  CASES.forEach(({ type, testID }) => {
    it(`${type} renders correct branch (testID=${testID})`, async () => {
      const { getByTestId } = await render(
        <BarcodeDisplay barcodeType={type} barcodeContent="1234567890123" />,
      );
      expect(getByTestId(testID)).toBeTruthy();
    });
  });
});
