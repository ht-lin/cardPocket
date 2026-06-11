import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../share/data/share_repository.dart';
import '../application/viewed_cards_notifier.dart';
import '../domain/card_model.dart';

class SetNicknameSheet extends ConsumerStatefulWidget {
  const SetNicknameSheet({super.key, required this.card});

  final CardModel card;

  @override
  ConsumerState<SetNicknameSheet> createState() => _SetNicknameSheetState();
}

class _SetNicknameSheetState extends ConsumerState<SetNicknameSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.card.viewerNickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    final nickname = value.isEmpty ? null : value;
    await _submit(nickname);
  }

  Future<void> _clear() async {
    await _submit(null);
  }

  Future<void> _submit(String? nickname) async {
    final shareId = widget.card.shareId;
    if (shareId == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(shareRepositoryProvider)
          .setNickname(shareId, widget.card.id, nickname);
      ref.invalidate(viewedCardsProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nickname == null ? 'Nickname cleared' : 'Nickname saved'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNickname = widget.card.viewerNickname != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Set nickname',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nickname',
              hintText: widget.card.name,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
          if (hasNickname) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _saving ? null : _clear,
              child: const Text('Clear nickname'),
            ),
          ],
        ],
      ),
    );
  }

  String _errorMessage(ApiException e) => switch (e) {
        NetworkException() => 'Network error, check your connection',
        ForbiddenException() => 'Permission denied',
        ServerException() => 'Server error, try later',
        UnprocessableException(:final errors) =>
          errors.values.expand((v) => v).join(', '),
        _ => 'An error occurred',
      };
}
