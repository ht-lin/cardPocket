import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../share/data/share_repository.dart';
import '../application/cards_search_notifier.dart';
import '../application/owned_cards_notifier.dart';
import '../application/viewed_cards_notifier.dart';
import '../data/cards_repository.dart';
import '../domain/card_model.dart';
import 'manage_sharing_sheet.dart';
import 'set_nickname_sheet.dart';

class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final q = value.trim();
    setState(() => _query = q);
    _debounce?.cancel();
    if (q.isEmpty) {
      ref.read(cardsSearchProvider.notifier).search('');
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => ref.read(cardsSearchProvider.notifier).search(q),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.read(ownedCardsProvider.notifier).refresh(),
          ref.read(viewedCardsProvider.notifier).refresh(),
        ]),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text('Cards'),
              floating: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search cards',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                    ),
                  ),
                ),
              ),
            ),
            ...(_query.isEmpty ? _buildBrowseSlivers() : _buildSearchSlivers()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.cardsScan),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildBrowseSlivers() {
    final owned = ref.watch(ownedCardsProvider);
    final viewed = ref.watch(viewedCardsProvider);
    return [
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
          onLoadMore: () => ref.read(ownedCardsProvider.notifier).loadMore(),
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
          onLoadMore: () => ref.read(viewedCardsProvider.notifier).loadMore(),
        ),
      ),
    ];
  }

  List<Widget> _buildSearchSlivers() {
    final search = ref.watch(cardsSearchProvider);
    return [
      search.when(
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (e, _) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(_searchErrorMessage(e))),
          ),
        ),
        data: (state) {
          if (state.results.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'No cards match "$_query"',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final card = state.results[index];
                return _CardTile(card: card, isOwner: card.isOwner);
              },
              childCount: state.results.length,
            ),
          );
        },
      ),
    ];
  }

  String _searchErrorMessage(Object e) => switch (e) {
        NetworkException() => 'Network error, check your connection',
        ForbiddenException() => 'Permission denied',
        ServerException() => 'Server error, try later',
        _ => 'An error occurred',
      };
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
    final errorColor = Theme.of(context).colorScheme.error;

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.credit_card)),
      title: Row(
        children: [
          Flexible(child: Text(displayName, overflow: TextOverflow.ellipsis)),
          if (card.isExpired) ...[
            const SizedBox(width: 8),
            _ExpiredBadge(color: errorColor),
          ],
        ],
      ),
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

class _ExpiredBadge extends StatelessWidget {
  const _ExpiredBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Expired',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
          value: _MenuAction.editCard,
          child: Text('Edit card'),
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
      case _MenuAction.editCard:
        context.pushNamed(
          RouteNames.cardsEdit,
          pathParameters: {'id': card.id},
        );
      case _MenuAction.manageSharing:
        _showManageSharingSheet(context);
      case _MenuAction.delete:
        await _showDeleteDialog(context, ref);
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

enum _MenuAction { editCard, manageSharing, delete }

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
