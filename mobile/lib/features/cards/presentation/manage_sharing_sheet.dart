import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../share/data/share_repository.dart';
import '../../share/domain/card_share_model.dart';
import '../domain/card_model.dart';

class ManageSharingSheet extends ConsumerStatefulWidget {
  const ManageSharingSheet({super.key, required this.card});

  final CardModel card;

  @override
  ConsumerState<ManageSharingSheet> createState() => _ManageSharingSheetState();
}

class _ManageSharingSheetState extends ConsumerState<ManageSharingSheet> {
  List<CardShareModel>? _shares;
  List<({String id, String userName})>? _friends;
  bool _loadingShares = true;
  bool _loadingFriends = true;
  String? _sharesError;
  String? _friendsError;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadShares(), _loadFriends()]);
  }

  Future<void> _loadShares() async {
    setState(() {
      _loadingShares = true;
      _sharesError = null;
    });
    try {
      final shares = await ref
          .read(shareRepositoryProvider)
          .getShares(widget.card.id);
      if (mounted) setState(() => _shares = shares);
    } on ApiException catch (e) {
      if (mounted) setState(() => _sharesError = _errorMessage(e));
    } finally {
      if (mounted) setState(() => _loadingShares = false);
    }
  }

  Future<void> _loadFriends() async {
    setState(() {
      _loadingFriends = true;
      _friendsError = null;
    });
    try {
      final friends = await ref.read(shareRepositoryProvider).getFriends();
      if (mounted) setState(() => _friends = friends);
    } on ApiException catch (e) {
      if (mounted) setState(() => _friendsError = _errorMessage(e));
    } finally {
      if (mounted) setState(() => _loadingFriends = false);
    }
  }

  Future<void> _addViewer(String viewerId) async {
    try {
      await ref
          .read(shareRepositoryProvider)
          .addViewer(widget.card.id, viewerId);
      await _loadShares();
    } on ApiException catch (e) {
      if (mounted) _showSnackBar(_errorMessage(e));
    }
  }

  Future<void> _removeViewer(String shareId) async {
    try {
      await ref.read(shareRepositoryProvider).removeViewer(shareId);
      await _loadShares();
    } on ApiException catch (e) {
      if (mounted) _showSnackBar(_errorMessage(e));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  List<({String id, String userName})> get _filteredFriends {
    final friends = _friends ?? [];
    final viewerIds = (_shares ?? []).map((s) => s.viewerUserId).toSet();
    return friends
        .where((f) =>
            !viewerIds.contains(f.id) &&
            f.userName.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Column(
        children: [
          _SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage sharing',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),
                Text(
                  'Add from friends',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search friends',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 4),
                if (_loadingFriends)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_friendsError != null)
                  Text(_friendsError!, style: const TextStyle(color: Colors.red))
                else if (_filteredFriends.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No friends to add',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ..._filteredFriends.map(
                    (f) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(f.userName),
                      trailing: TextButton(
                        onPressed: () => _addViewer(f.id),
                        child: const Text('Add'),
                      ),
                    ),
                  ),
                const Divider(height: 24),
                Text(
                  'Current viewers',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                if (_loadingShares)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_sharesError != null)
                  Text(_sharesError!, style: const TextStyle(color: Colors.red))
                else if ((_shares ?? []).isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No viewers yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...(_shares ?? []).map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(s.viewerUserName),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_remove_outlined),
                        tooltip: 'Remove',
                        onPressed: () => _removeViewer(s.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
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

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
