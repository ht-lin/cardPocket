import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../application/owned_cards_notifier.dart';
import '../data/cards_repository.dart';
import '../domain/card_model.dart';
import 'widgets/color_field.dart';
import 'widgets/expiry_field.dart';

class EditCardScreen extends ConsumerStatefulWidget {
  const EditCardScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends ConsumerState<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CardModel? _card;
  DateTime? _expiresAt;
  String? _color;
  String? _nameError;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    ref.read(cardsRepositoryProvider).getCardById(widget.id).then((card) {
      if (!mounted || card == null) return;
      setState(() {
        _card = card;
        _nameController.text = card.name;
        _expiresAt = card.expiresAt;
        _color = card.color;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Card')),
      body: _card == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Card name',
                        errorText: _nameError,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
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
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submit() async {
    setState(() => _nameError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ref.read(cardsRepositoryProvider).updateCard(
            id: widget.id,
            name: _nameController.text.trim(),
            expiresAt: _expiresAt,
            color: _color,
          );
      await ref.read(ownedCardsProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card updated'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
        context.pop();
      }
    } on UnprocessableException catch (e) {
      setState(() {
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
