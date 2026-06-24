import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../application/owned_cards_notifier.dart';
import '../data/barcode_image_analyzer.dart';
import '../data/cards_repository.dart';
import 'widgets/color_field.dart';
import 'widgets/expiry_field.dart';

const _barcodeTypes = [
  'QR_CODE',
  'CODE_128',
  'EAN_13',
  'EAN_8',
  'CODE_39',
  'UPC_A',
  'UPC_E',
  'PDF_417',
  'DATA_MATRIX',
  'AZTEC',
];

class CreateCardScreen extends ConsumerStatefulWidget {
  const CreateCardScreen({super.key});

  @override
  ConsumerState<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends ConsumerState<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedType = _barcodeTypes.first;
  DateTime? _expiresAt;
  String? _color;
  String? _contentError;
  String? _nameError;
  bool _loading = false;

  @override
  void dispose() {
    _contentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Card Manually')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _loading ? null : _detectFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Detect from gallery'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Barcode content',
                  errorText: _contentError,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Content is required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Barcode type'),
                items: _barcodeTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Card name',
                  errorText: _nameError,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              ExpiryField(
                value: _expiresAt,
                onChanged: (v) => setState(() => _expiresAt = v),
              ),
              const SizedBox(height: 16),
              ColorField(
                value: _color,
                onChanged: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _detectFromGallery() async {
    final picked = await ref
        .read(imagePickerProvider)
        .pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final result =
        await ref.read(barcodeImageAnalyzerProvider).analyze(picked.path);
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No barcode found in the image')),
      );
      return;
    }
    setState(() {
      _contentController.text = result.barcodeContent;
      if (_barcodeTypes.contains(result.barcodeType)) {
        _selectedType = result.barcodeType;
      }
      _contentError = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _contentError = null;
      _nameError = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ref.read(cardsRepositoryProvider).create(
            name: _nameController.text.trim(),
            barcodeType: _selectedType,
            barcodeContent: _contentController.text.trim(),
            expiresAt: _expiresAt,
            color: _color,
          );
      await ref.read(ownedCardsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card added'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
        context.goNamed(RouteNames.cards);
      }
    } on UnprocessableException catch (e) {
      setState(() {
        _contentError = e.errors['barcodeContent']?.join(', ');
        _nameError = e.errors['name']?.join(', ');
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() => _loading = false);
      if (mounted) _showErrorSnackBar(context, e);
    }
  }

  void _showErrorSnackBar(BuildContext context, ApiException e) {
    final message = switch (e) {
      NetworkException() => 'Network error, check your connection',
      ForbiddenException() => 'Permission denied',
      ServerException() => 'Server error, try later',
      _ => 'An error occurred',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
