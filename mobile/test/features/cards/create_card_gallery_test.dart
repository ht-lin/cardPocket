import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import 'package:card_pocket/features/cards/data/barcode_image_analyzer.dart';
import 'package:card_pocket/features/cards/presentation/create_card_screen.dart';

class _MockImagePicker extends Mock implements ImagePicker {}

class _FakeAnalyzer extends BarcodeImageAnalyzer {
  const _FakeAnalyzer(this.result);
  final BarcodeScanResult? result;

  @override
  Future<BarcodeScanResult?> analyze(String path) async => result;
}

Widget _buildApp({
  required ImagePicker picker,
  required BarcodeImageAnalyzer analyzer,
}) {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, _) => const CreateCardScreen()),
  ]);

  return ProviderScope(
    overrides: [
      imagePickerProvider.overrideWithValue(picker),
      barcodeImageAnalyzerProvider.overrideWithValue(analyzer),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late _MockImagePicker picker;

  setUp(() {
    picker = _MockImagePicker();
  });

  Future<void> pump(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
  }

  testWidgets('prefills content and type from a decoded gallery image',
      (tester) async {
    when(() => picker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => XFile('qr.png'));

    await pump(tester, _buildApp(
      picker: picker,
      analyzer: const _FakeAnalyzer(
        BarcodeScanResult(barcodeContent: 'HELLO-123', barcodeType: 'CODE_128'),
      ),
    ));

    await tester.tap(find.text('Detect from gallery'));
    await tester.pumpAndSettle();

    expect(find.text('HELLO-123'), findsOneWidget);
    expect(find.text('CODE_128'), findsOneWidget);
  });

  testWidgets('shows a snackbar when no barcode is found', (tester) async {
    when(() => picker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => XFile('blank.png'));

    await pump(tester, _buildApp(
      picker: picker,
      analyzer: const _FakeAnalyzer(null),
    ));

    await tester.tap(find.text('Detect from gallery'));
    await tester.pumpAndSettle();

    expect(find.text('No barcode found in the image'), findsOneWidget);
  });

  testWidgets('does nothing when the user cancels the picker', (tester) async {
    when(() => picker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => null);

    await pump(tester, _buildApp(
      picker: picker,
      analyzer: const _FakeAnalyzer(null),
    ));

    await tester.tap(find.text('Detect from gallery'));
    await tester.pumpAndSettle();

    expect(find.text('No barcode found in the image'), findsNothing);
  });
}
