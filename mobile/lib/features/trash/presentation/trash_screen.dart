import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/connectivity/is_offline_provider.dart';
import '../application/trash_notifier.dart';
import '../domain/trash_card_model.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider).value ?? false;
    final trash = ref.watch(trashProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: offline
          ? const _TrashMessage(
              icon: Icons.wifi_off,
              text: 'Trash is unavailable offline',
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(trashProvider.notifier).refresh(),
              child: trash.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _TrashError(
                  message: _errorMessage(e),
                  onRetry: () => ref.read(trashProvider.notifier).refresh(),
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return const _TrashMessage(
                      icon: Icons.delete_outline,
                      text: 'Trash is empty',
                    );
                  }
                  return _TrashList(state: state);
                },
              ),
            ),
    );
  }

  String _errorMessage(Object e) => switch (e) {
        NetworkException() => 'Network error, check your connection',
        ForbiddenException() => 'Permission denied',
        ServerException() => 'Server error, try later',
        _ => 'An error occurred',
      };
}

class _TrashList extends ConsumerWidget {
  const _TrashList({required this.state});
  final TrashListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.items.length + 1,
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          if (state.isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.hasMore) {
            return NotificationListener<ScrollEndNotification>(
              onNotification: (_) {
                ref.read(trashProvider.notifier).loadMore();
                return false;
              },
              child: const SizedBox(height: 1),
            );
          }
          return const SizedBox.shrink();
        }
        return _TrashTile(card: state.items[index]);
      },
    );
  }
}

class _TrashTile extends ConsumerWidget {
  const _TrashTile({required this.card});
  final TrashCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.credit_card)),
      title: Text(card.name, overflow: TextOverflow.ellipsis),
      subtitle: Text('Deleted on ${_formatDate(card.deletedAt)}'),
      trailing: PopupMenuButton<_TrashAction>(
        onSelected: (action) => _handleAction(context, ref, action),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: _TrashAction.restore,
            child: Text('Restore'),
          ),
          PopupMenuItem(
            value: _TrashAction.permanentDelete,
            child: Text('Delete permanently'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _TrashAction action,
  ) async {
    switch (action) {
      case _TrashAction.restore:
        await _restore(context, ref);
      case _TrashAction.permanentDelete:
        await _permanentDelete(context, ref);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(trashProvider.notifier).restore(card.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card restored'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _permanentDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete permanently'),
        content: Text(
          'Permanently delete "${card.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(trashProvider.notifier).permanentDelete(card.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card permanently deleted'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  void _showError(BuildContext context, ApiException e) {
    final message = switch (e) {
      NetworkException() => 'Network error, check your connection',
      ForbiddenException() => 'Permission denied',
      NotFoundException() => 'Card no longer in trash',
      ServerException() => 'Server error, try later',
      _ => 'An error occurred',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}

enum _TrashAction { restore, permanentDelete }

class _TrashMessage extends StatelessWidget {
  const _TrashMessage({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TrashError extends StatelessWidget {
  const _TrashError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
