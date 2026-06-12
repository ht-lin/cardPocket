import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../data/friendship_repository.dart';
import '../domain/friend_model.dart';

class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() =>
      _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<UserSummary>? _results;
  bool _searching = false;
  String? _error;
  final _sentRequests = <String>{};
  final _pendingRequests = <String>{};

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() {
        _results = null;
        _searching = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _search(q.trim()),
    );
  }

  Future<void> _search(String q) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results =
          await ref.read(friendshipRepositoryProvider).searchUsers(q);
      if (mounted) setState(() => _results = results);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = switch (e) {
              NetworkException() => 'Network error, check your connection',
              ForbiddenException() => 'Permission denied',
              ServerException() => 'Server error, try later',
              _ => 'An error occurred',
            });
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _sendRequest(String userId) async {
    setState(() => _pendingRequests.add(userId));
    try {
      await ref.read(friendshipRepositoryProvider).sendRequest(userId);
      if (mounted) {
        setState(() {
          _sentRequests.add(userId);
          _pendingRequests.remove(userId);
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _pendingRequests.remove(userId));
        final message = switch (e) {
          NetworkException() => 'Network error, check your connection',
          ForbiddenException() => 'Permission denied',
          UnprocessableException(:final errors) =>
            errors.values.expand((v) => v).join(', '),
          ServerException() => 'Server error, try later',
          _ => 'An error occurred',
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Friends')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by username or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    final results = _results;
    if (results == null) return const SizedBox.shrink();
    if (results.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        final sent = _sentRequests.contains(user.id);
        final pending = _pendingRequests.contains(user.id);
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(user.userName),
          trailing: sent
              ? const Chip(label: Text('Request sent'))
              : TextButton(
                  onPressed: pending ? null : () => _sendRequest(user.id),
                  child: const Text('Add friend'),
                ),
        );
      },
    );
  }
}
