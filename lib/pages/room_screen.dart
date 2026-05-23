import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:psychesail/components/crud.dart';
import 'package:psychesail/pages/paticipant_tile.dart';
import 'package:videosdk/videosdk.dart';
import 'room.dart';

class RoomScreen extends StatefulWidget {
  final String roomId;
  final String token;
  final void Function() leaveRoom;
  final String currentId;
  final String userId;

  const RoomScreen(
      {Key? key,
      required this.roomId,
      required this.token,
      required this.leaveRoom,
      required this.currentId,
      required this.userId})
      : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  Map<String, Stream?> participantVideoStreams = {};

  bool micEnabled = true;
  bool camEnabled = true;
  late Room room;

  void setParticipantStreamEvents(Participant participant) {
    participant.on(Events.streamEnabled, (Stream stream) {
      if (stream.kind == 'video') {
        setState(() => participantVideoStreams[participant.id] = stream);
      }
    });

    participant.on(Events.streamDisabled, (Stream stream) {
      if (stream.kind == 'video') {
        print(stream.id + " hello " + participant.displayName);
        setState(() => participantVideoStreams[participant.id] = null);
      }
    });
  }

  void setRoomEventListener(Room _room) {
    setParticipantStreamEvents(_room.localParticipant);
    _room.on(
      Events.participantJoined,
      (Participant participant) => setParticipantStreamEvents(participant),
    );
    _room.on(Events.participantLeft, (String participantId) {
      if (participantVideoStreams.containsKey(participantId)) {
        setState(() => participantVideoStreams.remove(participantId));
      }
    });
    _room.on(Events.roomLeft, () {
      participantVideoStreams.clear();
      if (widget.userId == 'community')
        deleteCall('Exams', widget.currentId);
      else
        deleteCall(widget.userId, widget.currentId);
    });
  }

  @override
  void initState() {
    super.initState();
    // Create instance of Roo

    room = VideoSDK.createRoom(
      participantId: widget.currentId,
      roomId: widget.roomId,
      token: widget.token,
      displayName: widget.currentId,
      micEnabled: micEnabled,
      camEnabled: camEnabled,
      maxResolution: 'hd',
      defaultCameraIndex: 1,
      notification: const NotificationInfo(
        title: "Video SDK",
        message: "Video SDK is sharing screen in the room",
        icon: "notification_share", // drawable icon name
      ),
    );

    setRoomEventListener(room);

    // Join room
    room.join();
  }

  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    print("Room ID: ${widget.roomId}");
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...participantVideoStreams.entries
                .map(
                  (e) => e.key == widget.currentId
                      ? ParticipantTile(
                          key: Key(e.key),
                          stream: e.value,
                          width: sizeWidth * 0.7,
                          height: sizeHeight * 0.5,
                        )
                      : Text(''),
                )
                .toList(),
            RoomControls(
                onToggleMicButtonPressed: () {
                  micEnabled ? room.muteMic() : room.unmuteMic();
                  setState(() => micEnabled = !micEnabled);
                },
                micEnabled: micEnabled,
                camEnabled: camEnabled,
                onToggleCameraButtonPressed: () {
                  camEnabled ? room.disableCam() : room.enableCam();
                  setState(() => camEnabled = !camEnabled);
                },
                onLeaveButtonPressed: () => {
                      room.leave(),
                      Navigator.pop(context, "Result"),
                    }),
            SizedBox(
              height: sizeHeight / 4,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                      width: 10); // Adjust the width of the separator as needed
                },
                itemCount: participantVideoStreams.entries.length,
                itemBuilder: (BuildContext context, int index) {
                  var entry = participantVideoStreams.entries.elementAt(index);
                  return entry.key != widget.currentId
                      ? ParticipantTile(
                          width: sizeWidth / 4,
                          height: sizeHeight / 4,
                          key: Key(entry.key),
                          stream: entry.value,
                        )
                      : SizedBox(
                          width: sizeWidth / 4,
                          height: sizeHeight / 4); // Placeholder for empty tile
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
