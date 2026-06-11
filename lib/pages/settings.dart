import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psychesail/components/sos_bottom_sheet.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/crud.dart';
import '../components/text.dart';
import '../model/supportcontactsmodel.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final SupportCircleRepo _supportCircleRepo = SupportCircleRepo();
  Future<List<Map<String, dynamic>>>? _pendingRequestsFuture;
  Future<List<Map<String, dynamic>>>? _communityFriendsFuture;
  Stream<List<SupportContact>>? _supportContactsStream;
  bool _helpExpanded = false;

  String _currentUserId() {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return args?['currentid']?.toString() ?? '';
  }

  void _refreshFutures() {
    final currentUserId = _currentUserId();
    _pendingRequestsFuture = getPendingCommunityFriendRequests(currentUserId);
    _communityFriendsFuture = getCommunityFriendsForUser(currentUserId);
    _supportContactsStream = currentUserId.isEmpty
        ? const Stream<List<SupportContact>>.empty()
        : _supportCircleRepo.getContacts(currentUserId);
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

  Future<void> _deleteContact(String contactId) async {
    final currentUserId = _currentUserId();
    await _supportCircleRepo.deleteContact(currentUserId, contactId);
  }

  Future<void> _saveContact({
    SupportContact? existing,
    required String name,
    required String phone,
    required String relationship,
  }) async {
    final currentUserId = _currentUserId();
    final contactId = existing?.id ??
        FirebaseFirestore.instance
            .collection('customers')
            .doc(currentUserId)
            .collection('supportCircle')
            .doc()
            .id;

    final contact = SupportContact(
      id: contactId,
      name: name.trim(),
      phone: phone.trim(),
      relationship: relationship,
    );

    if (existing == null) {
      await _supportCircleRepo.addContact(currentUserId, contact);
    } else {
      await _supportCircleRepo.updateContact(currentUserId, contact);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openContactEditor({
    SupportContact? contact,
    required int currentCount,
  }) async {
    if (contact == null && currentCount >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can save up to 5 support contacts.')),
      );
      return;
    }

    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');
    String relationship = contact?.relationship ?? 'Friend';
    const relationships = ['Friend', 'Parent', 'Sibling', 'Mentor', 'Other'];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(contact == null
              ? 'Add Support Contact'
              : 'Update Support Contact'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    DropdownButtonFormField<String>(
                      value: relationship,
                      decoration:
                          const InputDecoration(labelText: 'Relationship'),
                      items: relationships
                          .map(
                            (option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            relationship = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  return;
                }

                await _saveContact(
                  existing: contact,
                  name: nameController.text,
                  phone: phoneController.text,
                  relationship: relationship,
                );

                if (mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupportCircleSection() {
    return StreamBuilder<List<SupportContact>>(
      stream: _supportContactsStream,
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];

        if (!_helpExpanded) {
          return const SizedBox.shrink();
        }

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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_border, color: Colors.black),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Support Circle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ABeeZee',
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openContactEditor(
                      currentCount: contacts.length,
                    ),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Save up to 5 trusted contacts. You can update them anytime from Help.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => showSOSSheet(context, contacts),
                icon: const Icon(Icons.sos_outlined),
                label: const Text('Need Immediate Support?'),
              ),
              const SizedBox(height: 16),
              if (contacts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'No support contacts added yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${contact.relationship} • ${contact.phone}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Edit',
                                onPressed: () => _openContactEditor(
                                  contact: contact,
                                  currentCount: contacts.length,
                                ),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                onPressed: () async {
                                  await _deleteContact(contact.id);
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TextButton.icon(
                                onPressed: () => callContact(context, contact),
                                icon: const Icon(Icons.call),
                                label: const Text('Call'),
                              ),
                              TextButton.icon(
                                onPressed: () => sendSupportMessage(
                                    context, contact,
                                    useWhatsApp: false),
                                icon: const Icon(Icons.message),
                                label: const Text('SMS'),
                              ),
                              TextButton.icon(
                                onPressed: () => sendSupportMessage(
                                    context, contact,
                                    useWhatsApp: true),
                                icon: const Icon(Icons.chat),
                                label: const Text('WhatsApp'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
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
                        InkWell(
                          onTap: () {
                            setState(() {
                              _helpExpanded = !_helpExpanded;
                            });
                          },
                          child: settingsContainer(constr, 25.00, sizeWidth,
                              Icons.help, 'Help', 'Support Circle and SOS'),
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          color: Colors.grey,
                          height: 36,
                          thickness: 0.50,
                        ),
                        _buildSupportCircleSection(),
                        const SizedBox(height: 16),
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
