import 'package:flutter/material.dart';
import 'package:psychesail/components/video.dart';
import 'package:psychesail/pages/join_room.dart';
import 'package:psychesail/pages/room_screen.dart';
import 'package:random_avatar/random_avatar.dart';

import '../components/crud.dart';

class VideoSDKQuickStart extends StatefulWidget {
  const VideoSDKQuickStart({Key? key}) : super(key: key);

  @override
  State<VideoSDKQuickStart> createState() => _VideoSDKQuickStartState();
}

class _VideoSDKQuickStartState extends State<VideoSDKQuickStart> {
  String roomId = "";
  bool isRoomActive = false;

  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    var currentUserId = '';
    var senderUserId = '';
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Access individual parameters

    currentUserId = args?['currentid'] ?? "";
    senderUserId = args?['senderid'] ?? "";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("Video Calls"),
        actions: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: sizeWidth / 20),
              child: RandomAvatar(
                currentUserId,
                trBackground: false,
                height: 50,
                width: 50,
              )),
        ],
      ),
      body: FutureBuilder<dynamic>(
          future: calling(currentUserId, senderUserId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Loading....',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RoomScreen(
                        roomId: snapshot.data,
                        token: token,
                        leaveRoom: () {},
                        currentId: currentUserId,
                        userId: senderUserId,
                      ));
                }
            }
          }),
    );
  }
}

calling(currentUserId, senderId) async {
  dynamic roomId = await createRoom();
  if (senderId == 'community') {
    print("start");
    var snapshot = await getcommunityconstmessages(currentUserId, 'Exams');
    print(snapshot);
//     for (var docSnapshot in snapshot) {
//       print("no" + docSnapshot);
//  var docDataRaw = docSnapshot.data();
//  listOfPeople.add(docDataRaw['senderid']);
//   }
    snapshot.forEach((element) {
      addCall(element, 'Exams', roomId);
    });
//   } else
    addCall(senderId, currentUserId, roomId);
    return roomId;
  }
}
