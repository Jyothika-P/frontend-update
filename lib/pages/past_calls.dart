import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:psychesail/components/crud.dart';
import 'package:random_avatar/random_avatar.dart';

class PastCallsContent extends StatelessWidget {
  final String currentUserId;

  const PastCallsContent({super.key, required this.currentUserId});

  Future<List<List<String>>> _loadPastCalls() async {
    final data = await getUsers(currentUserId);
    final List<List<String>> pastCalls = List<List<String>>.from(data[4]);
    return pastCalls;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<String>>>(
      future: _loadPastCalls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text('Loading....', style: TextStyle(color: Colors.white)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white)),
          );
        }

        final calls = snapshot.data ?? [];
        if (calls.isEmpty) {
          return const Center(
            child: Text('No past calls yet',
                style: TextStyle(color: Colors.white)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: calls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final call = calls[index];
            final otherUser = call[0].isEmpty ? 'Unknown' : call[0];
            final roomId = call[1];
            final startedDate = call[2];
            final startedTime = call[3];
            final endedDate = call[4];
            final endedTime = call[5];
            final status = call[6];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RandomAvatar(otherUser,
                          trBackground: false, height: 46, width: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              otherUser,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              status == 'active' ? 'In progress' : 'Ended',
                              style: TextStyle(
                                color: status == 'active'
                                    ? Colors.green.shade700
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Text('Started: $startedDate $startedTime',
                  //     style: const TextStyle(
                  //         fontSize: 12, color: Colors.blueAccent)),
                  // if (endedDate.isNotEmpty && endedTime.isNotEmpty)
                  //   Text('Ended: $endedDate $endedTime',
                  //       style: const TextStyle(
                  //           fontSize: 12, color: Colors.redAccent)),
                  // const SizedBox(height: 8),
                  Text(
                    'Room: $roomId',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class PastCallsPage extends StatelessWidget {
  const PastCallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final currentUserId = args?['currentuser'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Past Calls'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RandomAvatar(
              currentUserId,
              trBackground: false,
              height: 42,
              width: 42,
            ),
          ),
        ],
      ),
      body: PastCallsContent(currentUserId: currentUserId),
    );
  }
}
