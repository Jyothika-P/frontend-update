import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../components/crud.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({
    super.key,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  DatabaseReference reff = FirebaseDatabase.instance.ref("/users");

  var receiveremail;
  var receiverid;
  var currentid;
  var communityname;
  var chatmode;
  var chatroomId;
  bool _privateHistoryTrimmed = false;

  Future<List<String>> _loadCommunityMembers() async {
    final members = await getcommunityconstmessages(currentid, communityname);
    final List<String> memberList = members is Set
        ? members.map((member) => member.toString()).toList()
        : List<String>.from(members);

    memberList.removeWhere(
        (member) => member.isEmpty || member == currentid || member == 'Disha');
    memberList.sort();
    return memberList;
  }

  Future<void> _openFriendSheet() async {
    if (communityname == 'community') {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<String>>(
            future: _loadCommunityMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 280,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 280,
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              final members = snapshot.data ?? [];
              if (members.isEmpty) {
                return const SizedBox(
                  height: 280,
                  child: Center(
                    child: Text(
                      'No community members found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Colors.white24,
                        ),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return FutureBuilder<String>(
                            future: getCommunityFriendState(
                              communityname,
                              currentid,
                              member,
                            ),
                            builder: (context, relationSnapshot) {
                              final relation = relationSnapshot.data ?? 'none';
                              final isLoading =
                                  relationSnapshot.connectionState ==
                                      ConnectionState.waiting;

                              String buttonLabel = 'Add Friend';
                              VoidCallback? onPressed;

                              if (relation == 'accepted') {
                                buttonLabel = 'Call';
                                onPressed = () {
                                  Navigator.pop(sheetContext);
                                  Navigator.pushNamed(context, '/video',
                                      arguments: {
                                        'currentid': currentid,
                                        'senderid': member,
                                      });
                                };
                              } else if (relation == 'pending_sent') {
                                buttonLabel = 'Requested';
                              } else if (relation == 'pending_received') {
                                buttonLabel = 'Accept';
                                onPressed = () async {
                                  await acceptCommunityFriendRequest(
                                    communityname,
                                    member,
                                    currentid,
                                  );
                                  if (mounted) {
                                    setState(() {});
                                  }
                                };
                              } else {
                                onPressed = () async {
                                  await sendCommunityFriendRequest(
                                    communityname,
                                    currentid,
                                    member,
                                  );
                                  if (mounted) {
                                    setState(() {});
                                  }
                                };
                              }

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  member,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  relation == 'accepted'
                                      ? 'Friend accepted'
                                      : relation == 'pending_sent'
                                          ? 'Request sent'
                                          : relation == 'pending_received'
                                              ? 'Wants to connect'
                                              : 'No request yet',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: onPressed,
                                        child: Text(buttonLabel),
                                      ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _trimPrivateHistoryIfNeeded() async {
    if (_privateHistoryTrimmed ||
        chatroomId == null ||
        chatroomId.toString().isEmpty) {
      return;
    }
    _privateHistoryTrimmed = true;
    await trimChatHistory(chatroomId.toString());
  }

  Widget _buildPrivateMessageList(double sizeWidth, double sizeHeight) {
    return StreamBuilder(
      stream: getmessages(currentid, receiverid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }

        final documents = snapshot.data == null ? [] : snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(
              documents[index],
              currentid,
              sizeWidth,
              sizeHeight,
            );
          },
        );
      },
    );
  }

  Widget _buildPrivateChatBody(double sizeHeight, double sizeWidth) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: _buildPrivateMessageList(sizeWidth, sizeHeight),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: sizeHeight / 80, horizontal: sizeWidth / 40),
          height: sizeHeight / 8.6,
          color: Colors.white,
          child: Row(
            children: [
              _chatField(_messageController),
              const SizedBox(width: 9),
              InkWell(
                onTap: () async {
                  if (_messageController.text.isNotEmpty) {
                    await sendmessage(
                        receiverid, _messageController.text, currentid);
                    _messageController.clear();
                    await trimChatHistory(chatroomId.toString());
                  }
                },
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final size = MediaQuery.of(context).size;
    // final sizeHeight = size.height;
    // final sizeWidth = size.width;
    // Access individual parameters
    communityname = args?['communityname'] ?? 'community';
    currentid = args?['currentid'] ?? '';
    receiverid =
        args?['receiverid'] ?? ((currentid == 'Joe') ? 'Disha' : 'Joe');
    chatmode = args?['chatmode'] ?? 'community';
    chatroomId =
        args?['chatroomId'] ?? getDirectChatRoomId(currentid, receiverid);
    var name = args?['name'] ?? "Exams";
    print(receiverid);
    print(communityname);
    print(currentid);

    if (chatmode == 'private') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _trimPrivateHistoryIfNeeded();
      });

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
          title: Center(child: Text(receiverid)),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/chat_background_1.jpeg"),
              fit: BoxFit.cover,
              opacity: 0.92,
            ),
          ),
          child: _buildPrivateChatBody(sizeHeight, sizeWidth),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          title: Center(child: Text(name)),
          actions: [
            if (communityname != 'community')
              Padding(
                  padding: EdgeInsets.only(right: size.width / 50),
                  child: IconButton(
                      onPressed: _openFriendSheet,
                      icon: Icon(Icons.person_add_alt_1),
                      color: Colors.white))
          ],
        ),
        body: Column(children: [
          if (name != 'Exams')
            Container(
                color: Colors.grey,
                height: sizeHeight / 22,
                child: Center(
                    child: Text(
                  "This community will disappear after 24 hours",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'AbeeZee',
                      fontSize: 14,
                      fontStyle: FontStyle.italic),
                ))),
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              color: Colors.white,
              child: _buildMessageList(
                  receiverid, currentid, sizeWidth, sizeHeight),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: sizeHeight / 80, horizontal: sizeWidth / 40),
              height: size.height / 8.6,
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      _chatField(_messageController),
                      SizedBox(
                        width: 9,
                      ),
                      InkWell(
                        onTap: () async {
                          if (_messageController.text.isNotEmpty) {
                            await sendcommunitymessage(_messageController.text,
                                currentid, communityname);
                            _messageController.clear();
                            print("message sent");
                          }
                        },
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
          SizedBox(),
        ]));
  }

// build message list
  Widget _buildMessageList(receiverid, currentid, sizeWidth, sizeHeight) {
    return StreamBuilder(
        stream: getcommunitymessages(currentid, communityname),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }
          var documents;
          if (snapshot.data == null) {
            documents = [];
          } else {
            documents = snapshot.data!.docs;
            for (var docSnapshot in documents) {
              var docDataRaw = docSnapshot.data();
              print(docDataRaw);

              // Accessing a sub-co // Print the data of each document in the sub-collection
            }
          }
          // return Placeholder(
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return _buildMessageItem(
                  documents[index], currentid, sizeWidth, sizeHeight);
            },
          );
        });
  }

  // build message item
  Widget _buildMessageItem(
      DocumentSnapshot document, currentid, sizeHeight, sizeWidth) {
    print("POPOPOPOO");
    print(document.data());
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        crossAxisAlignment: (data['senderid'] == currentid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: (data['senderid'] == currentid)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: (data['senderid'] == currentid)
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: (data['senderid'] == currentid)
                          ? EdgeInsets.only(
                              top: min(12, sizeWidth * 0.05),
                              right: min(sizeHeight * 0.05, 12),
                              left: sizeHeight * 0.05,
                            )
                          : EdgeInsets.only(
                              top: min(12, sizeWidth * 0.05),
                              left: min(sizeHeight * 0.05, 12),
                              right: sizeHeight * 0.05,
                            ),
                      child: Text(
                        data['senderid'],
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                    Container(
                      margin: (data['senderid'] == currentid)
                          ? EdgeInsets.only(
                              right: min(sizeHeight * 0.05, 12),
                              left: sizeHeight * 0.05,
                            )
                          : EdgeInsets.only(
                              left: min(sizeHeight * 0.05, 12),
                              right: sizeHeight * 0.05,
                            ),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: (data['senderid'] == currentid)
                            ? BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(12),
                              )
                            : BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                        color: (data['senderid'] == currentid)
                            ? const Color.fromARGB(156, 32, 160, 144)
                            : Colors.grey,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        data['message'],
                        style: TextStyle(
                          color: (data['senderid'] == currentid)
                              ? Colors.grey[700]
                              : Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: (data['senderid'] == currentid)
                ? EdgeInsets.only(
                    right: min(sizeHeight * 0.05, 12),
                    left: sizeHeight * 0.05,
                  )
                : EdgeInsets.only(
                    left: min(sizeHeight * 0.05, 12),
                    right: sizeHeight * 0.05,
                  ),
            child: Text(
              '${data['timestamp'].toDate().toLocal().hour}:' +
                  '${data['timestamp'].toDate().toLocal().minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      );

      // Container(
      //   alignment: alignment,
      //   child: Column(
      //     crossAxisAlignment: (data['senderid'] == currentid)
      //         ? CrossAxisAlignment.end
      //         : CrossAxisAlignment.start,
      //     mainAxisAlignment: (data['senderid'] == currentid)
      //         ? MainAxisAlignment.end
      //         : MainAxisAlignment.start,
      //     children: [
      //       // Text(data['senderid'],style: const TextStyle(backgroundColor: Colors.transparent,color: Colors.black,fontSize: 15,),),
      //       textbubble(
      //           data['message'],
      // return
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     Row(
      //       mainAxisAlignment: (data['senderid'] == currentid) ? MainAxisAlignment.end : MainAxisAlignment.start,
      //       children: [
      //         Flexible(
      //           child: Container(
      //     margin: (data['senderid'] == currentid)
      //     ? EdgeInsets.only(
      //         top: min(12, sizeWidth * 0.05),
      //
      //         right: min(sizeHeight * 0.05, 12),
      //         left: sizeHeight * 0.05,
      //       )
      //     : EdgeInsets.only(
      //         top: min(12, sizeWidth * 0.05),
      //
      //         left: min(sizeHeight * 0.05, 12),
      //         right: sizeHeight * 0.05,
      //       ),
      //         padding: EdgeInsets.all(12.0),
      //     decoration: BoxDecoration(
      //           borderRadius: (data['senderid'] == currentid)
      //       ? BorderRadius.only(
      //           topLeft: Radius.circular(12),
      //           topRight: Radius.circular(20),
      //           bottomLeft: Radius.circular(12),
      //         )
      //       : BorderRadius.only(
      //           topLeft: Radius.circular(20),
      //           topRight: Radius.circular(12),
      //           bottomRight: Radius.circular(12),
      //         ),
      //           color: (data['senderid'] == currentid)
      //       ? Color.fromRGBO(32, 160, 144, 100)
      //       : Colors.grey,
      //           border: Border.all(color: Colors.black),
      //         ),
      //     child: Text(
      //       data['message'],
      //       style: TextStyle(
      //         color: (data['senderid'] == currentid) ? Colors.white : Colors.black,
      //         fontSize: 17,
      //       ),
      //     ),
      //           ),
      //         ),
      //       ],
      //     ),
      //     Padding(
      //       padding: (data['senderid'] == currentid)
      //     ? EdgeInsets.only(
      //
      //         right: min(sizeHeight * 0.05, 12),
      //         left: sizeHeight * 0.05,
      //       )
      //     : EdgeInsets.only(
      //         left: min(sizeHeight * 0.05, 12),
      //         right: sizeHeight * 0.05,
      //       ),
      //       child: Text(
      //           '${data['timestamp']
      //                 .toDate()
      //                 .toLocal()
      //                 .hour}:' +
      //                 '${data['timestamp']
      //                     .toDate()
      //                     .toLocal()
      //                     .minute
      //                     .toString()
      //                     .padLeft(2, '0')}',
      //           style: TextStyle(color: Colors.black45, fontSize: 12),
      //         ),
      //     ),
      //   ],
      // return Container(
      //   alignment: alignment,
      //   child: Column(
      //     crossAxisAlignment: (data['senderid'] == currentid)
      //         ? CrossAxisAlignment.end
      //         : CrossAxisAlignment.start,
      //     mainAxisAlignment: (data['senderid'] == currentid)
      //         ? MainAxisAlignment.end
      //         : MainAxisAlignment.start,
      //     children: [
      //       Row(
      //         children: [circleButton(
      //             constr,
      //             sizeHeight /
      //                 100,
      //             sizeWidth /
      //                 50,
      //             "assets/group_dp.png"),
      //           textbubble(
      //               data['message'],
      //               '${data['timestamp']
      //                   .toDate()
      //                   .toLocal()
      //                   .hour}:' +
      //                   '${data['timestamp']
      //                       .toDate()
      //                       .toLocal()
      //                       .minute
      //                       .toString()
      //                       .padLeft(2, '0')}',
      //               data['senderid'],
      //               currentid,
      //               bgcolor,
      //               constr,
      //               context),
      //         ],
      //       ),
      //     ],
      //   ),
      //
      // );
    });
  }

  Widget _chatField(_messageController) {
    return Expanded(
      child: Theme(
        data: ThemeData(
          // Set the border color for TextField
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide:
                  BorderSide(color: Colors.black), // Set border color here
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide(
                  color: Colors.black), // Set focused border color here
            ),
          ),
        ),
        child: TextField(
          cursorColor: Colors.black,
          style: TextStyle(
            color: Colors.black,
          ),
          controller: _messageController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
