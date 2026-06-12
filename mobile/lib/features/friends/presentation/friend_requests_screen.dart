import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../application/friend_requests_notifier.dart';
import '../domain/friend_model.dart';

class FriendRequestsScreen extends ConsumerWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(friendRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: requests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const Center(child: Text('No pending requests'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) =>
                    _RequestTile(request: list[index]),
              ),
      ),
    );
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.request});
  final FriendRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(request.requester.userName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _accept(context, ref),
            child: const Text('Accept'),
          ),
          TextButton(
            onPressed: () => _reject(context, ref),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(friendRequestsProvider.notifier)
          .accept(request.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${request.requester.userName} is now a friend'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(friendRequestsProvider.notifier)
          .reject(request.id);
    } on ApiException catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  void _showError(BuildContext context, ApiException e) {
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
