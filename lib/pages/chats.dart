import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psychesail/components/button.dart';
import 'package:psychesail/components/crud.dart';
import 'package:psychesail/model/places.dart';
import 'package:random_avatar/random_avatar.dart';

class ChatsContent extends StatelessWidget {
  final String currentUserId;
  final Places place;

  const ChatsContent({
    super.key,
    required this.currentUserId,
    required this.place,
  });

  DateTime _chatTimestamp(List<dynamic> chat) {
    final metadata = chat.length > 1 && chat[1] is Map
        ? Map<String, dynamic>.from(chat[1] as Map)
        : <String, dynamic>{};
    final date = metadata['date']?.toString() ?? '';
    final time = metadata['time']?.toString() ?? '';

    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date $time');
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  List<List<dynamic>> _sortedChats(dynamic rawChats) {
    if (rawChats is! List) {
      return [];
    }

    final chats = rawChats
        .whereType<List>()
        .map((item) => List<dynamic>.from(item))
        .toList();

    chats.sort((a, b) => _chatTimestamp(b).compareTo(_chatTimestamp(a)));

    final serenityIndex =
        chats.indexWhere((chat) => chat.isNotEmpty && chat[0] == 'Serenity');
    if (serenityIndex > 0) {
      final serenity = chats.removeAt(serenityIndex);
      chats.insert(0, serenity);
    }

    return chats;
  }

  void _openChat(BuildContext context, List<dynamic> chat) {
    if (chat.isEmpty) {
      return;
    }

    final receiverId = chat[0].toString();
    final metadata = chat.length > 1 && chat[1] is Map
        ? Map<String, dynamic>.from(chat[1] as Map)
        : <String, dynamic>{};

    if (receiverId == 'Serenity') {
      Navigator.pushNamed(context, '/monkeybot', arguments: {
        'receiverid': receiverId,
        'currentid': currentUserId,
        'lastmessage': metadata['message'] ?? '',
        'obj': place.getObject(),
        'url': place.getImagestring(),
      });
      return;
    }

    Navigator.pushNamed(context, '/chatroom', arguments: {
      'receiverid': receiverId,
      'currentid': currentUserId,
      'receiveremail': 'gaand_maarao',
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sizeWidth = size.width;
    final isWide = sizeWidth > 600;

    return Container(
      color: Colors.white,
      child: FutureBuilder<dynamic>(
        future: getUsers(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text(
                'Loading chats...',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.black),
              ),
            );
          }

          final allChats = _sortedChats(snapshot.data[0]);
          if (allChats.isEmpty) {
            return const Center(
              child: Text(
                'No chats yet',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final now = DateTime.now();
          final formattedDate = dateFormatter.format(now);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: allChats.length,
            itemBuilder: (context, index) {
              final chat = allChats[index];
              final receiverId = chat[0].toString();
              final chatMeta = chat.length > 1 && chat[1] is Map
                  ? Map<String, dynamic>.from(chat[1] as Map)
                  : <String, dynamic>{};
              final message = chatMeta['message']?.toString() ?? '';

              final displayTime = (() {
                final msgDate = chatMeta['date']?.toString() ?? '';
                final msgTimeStr = chatMeta['time']?.toString() ?? '';
                if (msgDate == formattedDate) {
                  try {
                    final parsedTime = DateFormat('HH:mm:ss').parse(msgTimeStr);
                    return DateFormat('hh:mm a').format(parsedTime);
                  } catch (_) {
                    return msgTimeStr;
                  }
                }
                return msgDate;
              })();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => _openChat(context, chat),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                          color: receiverId == 'Serenity'
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.black26,
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.0,
                        vertical: receiverId == 'Serenity' ? 8.0 : 6.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: sizeWidth / 5,
                            child: receiverId == 'Serenity'
                                ? circleButton(
                                    isWide,
                                    sizeWidth / 150,
                                    sizeWidth / 45,
                                    'assets/serenity_1.png',
                                    borderneed: false,
                                  )
                                : RandomAvatar(
                                    receiverId,
                                    trBackground: false,
                                    height: 50,
                                    width: 50,
                                  ),
                          ),
                          SizedBox(
                            width: sizeWidth / 2.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  receiverId,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: isWide ? sizeWidth / 40 : sizeWidth / 20,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'ABeeZee',
                                  ),
                                ),
                                Text(
                                  receiverId == 'Serenity'
                                      ? 'There for u 😇'
                                      : (message.length < 20
                                          ? message
                                          : message.substring(0, 20)),
                                  style: TextStyle(
                                    color: receiverId == 'Serenity'
                                        ? const Color.fromRGBO(35, 154, 139, 75)
                                        : Colors.grey,
                                    fontFamily: 'AbeeZee',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: sizeWidth / 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  displayTime,
                                  style: TextStyle(
                                    color: receiverId == 'Serenity'
                                        ? const Color.fromRGBO(35, 154, 139, 75)
                                        : Colors.grey,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'ABeeZee',
                                  ),
                                ),
                                CircleAvatar(
                                  maxRadius: isWide ? sizeWidth / 65 : sizeWidth / 40,
                                  backgroundColor: Colors.transparent,
                                  child: Text(
                                    '',
                                    style: TextStyle(fontSize: sizeWidth / 50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
