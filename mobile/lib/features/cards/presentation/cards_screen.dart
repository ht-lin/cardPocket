import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../share/data/share_repository.dart';
import '../application/owned_cards_notifier.dart';
import '../application/viewed_cards_notifier.dart';
import '../data/cards_repository.dart';
import '../domain/card_model.dart';
import 'manage_sharing_sheet.dart';
import 'set_nickname_sheet.dart';

class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownedCardsProvider);
    final viewed = ref.watch(viewedCardsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.read(ownedCardsProvider.notifier).refresh(),
          ref.read(viewedCardsProvider.notifier).refresh(),
        ]),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          const SliverAppBar(
            title: Text('Cards'),
            floating: true,
          ),
          const _SectionHeader(title: 'My Cards'),
          owned.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
            data: (state) => _CardSection(
              cards: state.items,
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
              isOwner: true,
              emptyMessage: 'No cards yet, tap + to add your first',
              onLoadMore: () =>
                  ref.read(ownedCardsProvider.notifier).loadMore(),
            ),
          ),
          const _SectionHeader(title: 'Shared with Me'),
          viewed.when(
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
            data: (state) => _CardSection(
              cards: state.items,
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
              isOwner: false,
              emptyMessage: 'No shared cards yet',
              onLoadMore: () =>
                  ref.read(viewedCardsProvider.notifier).loadMore(),
            ),
          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.cardsScan),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.cards,
    required this.isLoadingMore,
    required this.hasMore,
    required this.isOwner,
    required this.emptyMessage,
    required this.onLoadMore,
  });

  final List<CardModel> cards;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isOwner;
  final String emptyMessage;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              const Icon(Icons.credit_card_off_outlined, size: 48),
              const SizedBox(height: 8),
              Text(emptyMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == cards.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (hasMore) {
              return NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  onLoadMore();
                  return false;
                },
                child: const SizedBox(height: 1),
              );
            }
            return const SizedBox.shrink();
          }
          final card = cards[index];
          return _CardTile(card: card, isOwner: isOwner);
        },
        childCount: cards.length + 1,
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  const _CardTile({required this.card, required this.isOwner});
  final CardModel card;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = (!isOwner && card.viewerNickname != null)
        ? '${card.viewerNickname} (${card.ownerUsername ?? ''})'
        : card.name;

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.credit_card)),
      title: Text(displayName),
      subtitle: isOwner ? null : Text(card.ownerUsername ?? ''),
      trailing: isOwner
          ? _OwnerMenu(card: card)
          : _ViewerMenu(card: card),
      onTap: () => context.pushNamed(
        RouteNames.cardBarcode,
        pathParameters: {'id': card.id},
      ),
    );
  }
}

class _OwnerMenu extends ConsumerWidget {
  const _OwnerMenu({required this.card});
  final CardModel card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_MenuAction>(
      onSelected: (action) => _handleAction(context, ref, action),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _MenuAction.editName,
          child: Text('Edit name'),
        ),
        PopupMenuItem(
          value: _MenuAction.manageSharing,
          child: Text('Manage sharing'),
        ),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _MenuAction action,
  ) async {
    switch (action) {
      case _MenuAction.editName:
        await _showEditDialog(context, ref);
      case _MenuAction.manageSharing:
        _showManageSharingSheet(context);
      case _MenuAction.delete:
        await _showDeleteDialog(context, ref);
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: card.name);
    String? errorText;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Card name',
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final newName = controller.text.trim();
    if (newName.isEmpty || newName == card.name) return;

    try {
      await ref.read(cardsRepositoryProvider).updateName(card.id, newName);
      await ref.read(ownedCardsProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card name updated'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackBar(context, e);
    }
  }

  void _showManageSharingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ManageSharingSheet(card: card),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card'),
        content: Text('Delete "${card.name}"? This cannot be undone.'),
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
      await ref.read(cardsRepositoryProvider).delete(card.id);
      await ref.read(ownedCardsProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card deleted'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) _showErrorSnackBar(context, e);
    }
  }

  void _showErrorSnackBar(BuildContext context, ApiException e) {
    final message = switch (e) {
      NetworkException() => 'Network error, check your connection',
      ForbiddenException() => 'Permission denied',
      ServerException() => 'Server error, try later',
      UnprocessableException(:final errors) =>
        errors.values.expand((v) => v).join(', '),
      _ => 'An error occurred',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

enum _MenuAction { editName, manageSharing, delete }

class _ViewerMenu extends ConsumerWidget {
  const _ViewerMenu({required this.card});
  final CardModel card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_ViewerMenuAction>(
      onSelected: (action) => _handleAction(context, ref, action),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _ViewerMenuAction.setNickname,
          child: Text('Set nickname'),
        ),
        PopupMenuItem(
          value: _ViewerMenuAction.leave,
          child: Text('Leave sharing'),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _ViewerMenuAction action,
  ) async {
    switch (action) {
      case _ViewerMenuAction.setNickname:
        if (!context.mounted) return;
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => SetNicknameSheet(card: card),
        );
      case _ViewerMenuAction.leave:
        await _showLeaveDialog(context, ref);
    }
  }

  Future<void> _showLeaveDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave sharing'),
        content: Text(
          'Stop viewing "${card.viewerNickname ?? card.name}"? You will lose access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final shareId = card.shareId;
    if (shareId == null) return;

    try {
      await ref.read(shareRepositoryProvider).leave(shareId, card.id);
      ref.invalidate(viewedCardsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Left sharing'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        final message = switch (e) {
          NetworkException() => 'Network error, check your connection',
          ForbiddenException() => 'Permission denied',
          ServerException() => 'Server error, try later',
          UnprocessableException(:final errors) =>
            errors.values.expand((v) => v).join(', '),
          _ => 'An error occurred',
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
}

enum _ViewerMenuAction { setNickname, leave }
