import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

import '../components/crud.dart';
import '../components/text.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Future<List<Map<String, dynamic>>>? _pendingRequestsFuture;
  Future<List<Map<String, dynamic>>>? _communityFriendsFuture;

  String _currentUserId() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return args?['currentid']?.toString() ?? '';
  }

  void _refreshFutures() {
    final currentUserId = _currentUserId();
    _pendingRequestsFuture = getPendingCommunityFriendRequests(currentUserId);
    _communityFriendsFuture = getCommunityFriendsForUser(currentUserId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pendingRequestsFuture == null || _communityFriendsFuture == null) {
      _refreshFutures();
    }
  }

  Future<void> _acceptRequest(
      String communityId, String fromId, String toId) async {
    await acceptCommunityFriendRequest(communityId, fromId, toId);
    setState(_refreshFutures);
  }

  Widget _buildFriendChips(List<Map<String, dynamic>> friends) {
    if (friends.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No friends yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: friends.map((friend) {
        final friendId = friend['friendId']?.toString() ?? '';
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/chatroom', arguments: {
              'currentid': _currentUserId(),
              'receiverid': friendId,
              'chatmode': 'private',
              'chatroomId': getDirectChatRoomId(_currentUserId(), friendId),
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(26, 174, 144, 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              friendId,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFriendsSection(
      bool constr, dynamic sizeWidth, dynamic sizeHeight) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _communityFriendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.black),
            ),
          );
        }

        final friends = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, color: Colors.black),
                  SizedBox(width: sizeWidth / 80),
                  Text(
                    'Friends',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: constr ? sizeWidth / 55 : sizeWidth / 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ABeeZee',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildFriendChips(friends),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _pendingRequestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.black),
            ),
          );
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'No requests',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final request = requests[index];
            final communityId = request['communityId']?.toString() ?? '';
            final fromId = request['fromId']?.toString() ?? '';
            final toId = request['toId']?.toString() ?? '';

            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fromId,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Community: $communityId',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _acceptRequest(communityId, fromId, toId),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeWidth = MediaQuery.of(context).size.width;
    final sizeHeight = MediaQuery.of(context).size.height;
    final currentUserId = _currentUserId();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final constr = constraints.maxWidth > 600;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: sizeWidth / 2.3),
                    child: const Divider(
                      color: Color.fromARGB(255, 201, 195, 195),
                      height: 36,
                      thickness: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: sizeWidth / 4,
                          child: RandomAvatar(
                            currentUserId,
                            trBackground: false,
                            height: 50,
                            width: 50,
                          ),
                        ),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUserId,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      constr ? sizeWidth / 40 : sizeWidth / 20,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'ABeeZee',
                                ),
                              ),
                              Text(
                                'Never give up',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize:
                                      constr ? sizeWidth / 40 : sizeWidth / 20,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'ABeeZee',
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 36,
                    thickness: 0.50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        settingsContainer(constr, 25.00, sizeWidth,
                            Icons.key_outlined, 'Accounts', 'Privacy,security'),
                        settingsContainer(constr, 25.00, sizeWidth, Icons.chat,
                            'Chat', 'Chat history,theme'),
                        settingsContainer(
                            constr,
                            25.00,
                            sizeWidth,
                            Icons.group_add,
                            'Community Requests',
                            'Accept friends before calls'),
                        settingsContainer(
                            constr,
                            25.00,
                            sizeWidth,
                            Icons.notifications,
                            'Notifications',
                            'Messages and others'),
                        settingsContainer(constr, 25.00, sizeWidth, Icons.help,
                            'Help', 'Help center,contact us'),
                        const SizedBox(height: 16),
                        const Divider(
                          color: Colors.grey,
                          height: 36,
                          thickness: 0.50,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.group_add,
                                    color: Colors.black),
                                const SizedBox(width: 8),
                                Text(
                                  'Community requests',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: constr
                                        ? sizeWidth / 55
                                        : sizeWidth / 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ABeeZee',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRequestsSection(),
                        const Divider(
                          color: Colors.grey,
                          height: 36,
                          thickness: 0.50,
                        ),
                        _buildFriendsSection(constr, sizeWidth, sizeHeight),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
            onTap: (int index) {
              final currentUserId = _currentUserId();
              if (index >= 0 && index <= 2) {
                Navigator.pop(context, index);
              }
              // index == 3 -> already on Settings
            },
            unselectedItemColor: const Color.fromRGBO(35, 154, 139, 75),
            fixedColor: const Color.fromRGBO(35, 154, 139, 75),
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.call),
                label: 'Calls',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

format(Duration d) => d.toString().split('.').first.padLeft(8, '0');
