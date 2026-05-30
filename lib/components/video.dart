import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

// String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiIwYzdlZWNlNS04MTUyLTQyODQtODBmOC1iZTJjMzVlZWU0MGMiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTcxNDI2ODE2MSwiZXhwIjoxNzQ1ODA0MTYxfQ.WeeRpIwQx6ftJ3KMXA7hUda8KnqHO9-SNCjXOWRxk0o";
String token =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiJlMjJjZTU3Zi0wZGZkLTQzYTQtYmRiNS02YTIxODcyYjY4YTkiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTc3OTkxNzAwMywiZXhwIjoxNzgwNTIxODAzfQ.L6EDYBG6Xc0e4dUPMCTL6m7aX3sJRYQ2GU5SaDeVoNE";
Future<String> createRoom() async {
  var url = Uri.parse("https://api.videosdk.live/v2/rooms");
  var headers = {'Authorization': token};
  try {
    final http.Response httpResponse = await http.post(
      url,
      headers: headers,
    );
    final decodedBody = json.decode(httpResponse.body);
    print(decodedBody);
    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
      final createdRoomId = decodedBody['roomId'];
      if (createdRoomId is String && createdRoomId.isNotEmpty) {
        return createdRoomId;
      }
    }
    throw Exception(
        'Failed to create VideoSDK room: ${httpResponse.statusCode} ${httpResponse.body}');
  } catch (e) {
    print("Error : ${e}");
    rethrow;
  }
}

Future<String> getCommunityRoomId() async {
  final firestore = FirebaseFirestore.instance;
  final roomRef = firestore.collection('video_room_meta').doc('community');
  final snapshot = await roomRef.get();

  final existingRoomId = snapshot.data()?['roomId']?.toString();
  if (snapshot.exists && existingRoomId != null && existingRoomId.isNotEmpty) {
    return existingRoomId;
  }

  final roomId = await createRoom();
  await roomRef.set({
    'roomId': roomId,
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  return roomId;
}
