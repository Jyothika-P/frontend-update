import 'package:flutter/material.dart';
import 'package:psychesail/components/video.dart';
import 'package:psychesail/pages/room_screen.dart';
import 'package:random_avatar/random_avatar.dart';

import '../components/crud.dart';

class VideoSDKQuickStart extends StatefulWidget {
  const VideoSDKQuickStart({Key? key}) : super(key: key);

  @override
  State<VideoSDKQuickStart> createState() => _VideoSDKQuickStartState();
}

class _VideoSDKQuickStartState extends State<VideoSDKQuickStart> {
  late Future<String> _roomFuture;
  String? _currentUserId;
  String? _senderUserId;
  String? _createdRoomId;
  bool _isCommunityCall = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_senderUserId != null) {
      return;
    }

    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    _currentUserId = args?['currentid'] ?? "";
    _senderUserId = args?['senderid'] ?? "";
    _isCommunityCall = _senderUserId == 'community';
    _roomFuture = _initRoom(_currentUserId!, _senderUserId!);
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text("Video Calls"),
        actions: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: sizeWidth / 20),
              child: RandomAvatar(
                _currentUserId ?? "",
                trBackground: false,
                height: 50,
                width: 50,
              )),
        ],
      ),
      body: FutureBuilder<dynamic>(
          future: _roomFuture,
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
                  final roomId = snapshot.data as String;
                  _createdRoomId = roomId;
                  return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RoomScreen(
                        roomId: roomId,
                        token: token,
                        leaveRoom: _cleanupCall,
                        currentId: _currentUserId ?? "",
                        userId: _senderUserId ?? "",
                      ));
                }
            }
          }),
    );
  }

  void _cleanupCall() async {
    final currentUserId = _currentUserId;
    final senderUserId = _senderUserId;

    if (currentUserId == null || senderUserId == null) {
      return;
    }

    if (!_isCommunityCall) {
      await completeCallHistory(_createdRoomId ?? '');
    }

    if (senderUserId == 'community') {
      deleteCall('Exams', currentUserId);
    } else {
      deleteCall(senderUserId, currentUserId);
    }
  }
}

Future<String> _initRoom(String currentUserId, String senderId) async {
  if (senderId == 'community') {
    final roomId = await getCommunityRoomId();
    print('Using shared community room: $roomId');
    var snapshot = await getcommunityconstmessages(currentUserId, 'Exams');
    print(snapshot);
    snapshot.forEach((element) {
      addCall(element, 'Exams', roomId);
    });
    addCall(senderId, currentUserId, roomId);
    return roomId;
  }

  final roomId = await createRoom();
  addCall(senderId, currentUserId, roomId);
  return roomId;
}
