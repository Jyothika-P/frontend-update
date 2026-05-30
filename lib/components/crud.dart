import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:psychesail/model/message.dart';
import 'package:psychesail/model/time.dart';

final dateFormatter = DateFormat('yyyy-MM-dd');

final timeFormatter = DateFormat('HH:mm:ss');
dynamic createRecord(name, email, id, password) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("/users/$id");
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var check = await getData(id);
  if (check == 'No data available.') {
    ref.set({"name": name, "email": email, "password": password});

    _firestore.collection('customers').doc(id).set({
      'id': id,
      'email': email,
      'password': password,
      'stresshistory': [],
    });
    createChatrooms(name, "Serenity", "");
    createChatrooms(name, "Groupchat", "");
    _firestore
        .collection('community')
        .doc('Exams')
        .collection('users')
        .doc(id)
        .collection('messages')
        .add({
      'senderEmail': email,
      'senderid': id,
      'message': '',
      'timestamp': DateTime.now()
    });
    return 'created';
  } else if (check['email'] == email) return 'userExists';
  return {};
}

dynamic getData(id) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final snapshot = await _firestore.collection('customers').doc(id).get();
  if (snapshot.exists) {
    return (snapshot);
  } else {
    return ('No data available.');
  }
}

dynamic checkUser(name, email, password) async {
  var check = await getData(name);
  if (check == 'No data available.') return 'IncorrectDetails';
  if (check['id'] == name &&
      check['email'] == email &&
      check['password'] == password) {
    return 'userExists';
  } else
    return 'IncorrectDetails';
}

dynamic createChatrooms(String currentUser, String receiveUser, message) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String small = "";
  String large = "";
  print(currentUser.runtimeType);
  if (currentUser.compareTo(receiveUser) == -1) {
    small = currentUser;
    large = receiveUser;
  } else {
    large = currentUser;
    small = receiveUser;
  }
  final DateTime now = DateTime.now();
  final formattedDate = dateFormatter.format(now);
  final formattedTime = timeFormatter.format(now);
  _firestore.collection('chatAvailable').doc('$currentUser').set({
    "$receiveUser": {
      'message': message,
      'time': formattedTime,
      'date': formattedDate
    }
  }, SetOptions(merge: true));
  _firestore
      .collection('chatrooms')
      .doc('${small}_$large')
      .collection('$formattedDate')
      .doc("$currentUser")
      .set({"$formattedTime": message}, SetOptions(merge: true)).then((res) {
    print("created");
  });
}

dynamic updateChat(currentUser, receiveUser, message) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DateTime now = DateTime.now();
  final formattedDate = dateFormatter.format(now);
  final formattedTime = timeFormatter.format(now);
  _firestore.collection('chatAvailable').doc('$currentUser').set({
    "$receiveUser": {
      'message': message,
      'time': formattedTime,
      'date': formattedDate
    }
  }, SetOptions(merge: true));
}

dynamic getUsers(currentuser) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  dynamic userentries =
      await _firestore.collection('chatAvailable').doc('$currentuser').get();
  print("hello");
  print(userentries.runtimeType);
  dynamic user = userentries
      .data()
      .entries
      .map((entry) => [entry.key, entry.value])
      .toList();
  int serenityIndex = 0;
  for (var it = 0; it < user.length; it++) {
    if (user[it][0] == 'Serenity') serenityIndex = it;
  }
  var temp = user[0];
  user[0] = user[serenityIndex];
  user[serenityIndex] = temp;
  print(user);
  dynamic community = await _firestore.collection('community').get();
  print(community.docs[1]['description']);
  dynamic activity = await _firestore.collection('activity').get();
  Map<String, String> distinctTimestamps = {};
  List<List<String>> pairList = [];
  String chatroomid = currentuser + "_" + "Serenity";
  QuerySnapshot querySnapshot = await _firestore
      .collection('chat_rooms')
      .doc(chatroomid)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .get();
  print(activity.docs[0]['url']);
  if (querySnapshot.docs.isNotEmpty) {
    distinctTimestamps.clear(); // Clear the existing timestamps
    for (DocumentSnapshot doc in querySnapshot.docs) {
      // Extract the timestamp field from each document and convert it to DateTime
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Check if the 'timestamp' field exists in the data map
      if (data.containsKey('timestamp')) {
        // Extract the 'timestamp' field and convert it to DateTime
        Timestamp timestamp = data['timestamp'] as Timestamp;
        convertedTime newTime = convertedTime(dateTime: timestamp.toDate());
        dynamic msg = newTime.toMap();
        distinctTimestamps[
                '${msg['day']}, ${msg['date']} ${msg['month']} ${msg['year']}'] =
            msg['time'];
      }
    }
    pairList = distinctTimestamps.entries
        .map((entry) => [entry.key, entry.value])
        .toList();
    // Now, distinctTimestamps set contains all the distinct timestamps from Firestore
    print('Distinct Timestamps: $distinctTimestamps');
  } else {
    print('No documents found in Firestore');
  }
  print(pairList);
  querySnapshot = await _firestore.collection('call_history').get();
  List<List<String>> pastCalls = [];
  if (querySnapshot.docs.isNotEmpty) {
    for (DocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final callerId = data['callerId']?.toString() ?? '';
      final calleeId = data['calleeId']?.toString() ?? '';

      if (callerId.isEmpty || calleeId.isEmpty) {
        continue;
      }

      if (callerId == currentuser && calleeId == currentuser) {
        continue;
      }

      if (callerId == currentuser || calleeId == currentuser) {
        final startedAt = data['startedAt'];
        final endedAt = data['endedAt'];
        final otherUser = callerId == currentuser ? calleeId : callerId;
        pastCalls.add([
          otherUser,
          data['roomId']?.toString() ?? '',
          startedAt is Timestamp
              ? DateFormat('EEEE ,d MMMM yyyy').format(startedAt.toDate())
              : '',
          startedAt is Timestamp
              ? DateFormat('HH:mm:ss').format(startedAt.toDate())
              : '',
          endedAt is Timestamp
              ? DateFormat('EEEE ,d MMMM yyyy').format(endedAt.toDate())
              : '',
          endedAt is Timestamp
              ? DateFormat('HH:mm:ss').format(endedAt.toDate())
              : '',
          data['active'] == true ? 'active' : 'ended',
        ]);
      }
    }
  }
  pastCalls.sort((a, b) => b[2].compareTo(a[2]));

  if (pastCalls.isEmpty) {
    pastCalls.add([
      'community',
      'community',
      '',
      '',
      '',
      '',
      'ended',
    ]);
  }
  print(pastCalls);
  var stresshistory = await getStressHistory(currentuser);
  return [
    user,
    community.docs,
    activity.docs,
    pairList,
    pastCalls,
    stresshistory
  ];
}

Future<void> sendmessage(String receiverId, String message, currentid) async {
  // get user info
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var snap = await getData(currentid);
  print(snap['email']);
  print(receiverId);
  // print(receiveremail);
  print(currentid);
  final String currentUserId = currentid;
  final String currentEmailId = snap['email'];
  final timestamp = Timestamp.now();

  // create a new message
  Message newMessage = Message(
    senderEmail: currentEmailId,
    senderid: currentUserId,
    receiverid: receiverId,
    message: message,
    timestamp: timestamp,
  );
  //construct chatroom id for current user id and sender id (sorted to ensure uniqueness)
  List<String> ids = [currentUserId, receiverId];
  ids.sort();
  String chatroomId = ids.join("_");

  //add new message to database
  await _firestore
      .collection('chat_rooms')
      .doc(chatroomId)
      .collection('messages')
      .add(newMessage.toMap());
}

// GET MESSAGES
Stream<QuerySnapshot> getmessages(String userId, String otheruserId) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> ids = [userId, otheruserId];
  ids.sort();
  String chatroomid = ids.join("_");
  return _firestore
      .collection('chat_rooms')
      .doc(chatroomid)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
}

// COMMUNITY DESCRIPTION RETRIEVE DATA
Future<void> sendcommunitymessage(
    String message, currentid, String title) async {
  // get user info
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var snap = await getData(currentid);
  print(snap['email']);
  // print(receiveremail);
  print(currentid);
  final String currentUserId = currentid;
  final String currentEmailId = snap['email'];
  final timestamp = Timestamp.now();

  // create a new message
  groupMessage newMessage = groupMessage(
    senderEmail: currentEmailId,
    senderid: currentUserId,
    message: message,
    timestamp: timestamp,
  );

  //add new message to database
  await _firestore
      .collection('community')
      .doc(title)
      .collection('users')
      .add(newMessage.toMap());
}

// GET COMMUNITY MESSAGES
Stream<QuerySnapshot> getcommunitymessages(String userId, String title) {
  print("userID : " + userId);
  print("title :" + title);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  return _firestore
      .collection('community')
      .doc(title)
      .collection('users')
      .orderBy('timestamp', descending: false)
      .snapshots();
}

// GET COMMUNTIY TITLES
Future<QuerySnapshot<Map<String, dynamic>>> getcommunity() async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  return _firestore.collection('community').get();
}

dynamic getcommunityconstmessages(String userId, String title) async {
  print("userID : " + userId);
  print("title :" + title);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> listOfPeople = {};
  QuerySnapshot querySnapshot = await _firestore
      .collection('community')
      .doc(title)
      .collection('users')
      .orderBy('timestamp', descending: false)
      .get();
  if (querySnapshot.docs.isNotEmpty) {
    for (DocumentSnapshot doc in querySnapshot.docs) {
      // Extract the timestamp field from each document and convert it to DateTime
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Check if the 'timestamp' field exists in the data map
      if (data.containsKey('senderid')) {
        listOfPeople.add(data['senderid']);
      }
    }
    // Now, distinctTimestamps set contains all the distinct timestamps from Firestore
    print('Distinct Senderid: $listOfPeople');
  } else {
    print('No documents found in Firestore');
  }
  return listOfPeople;
}

// ADD FINAL STRESS VALUE
void addStressValue(String userId, String stressValue) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  print(DateTime.now());
  Map<String, dynamic> newStressEntry = {
    'timestamp': DateTime.now(),
    'stressScore': stressValue,
  };
  await _firestore.collection('customers').doc(userId).update({
    'stressHistory': FieldValue.arrayUnion([newStressEntry]),
  }).catchError((error) => print("Failed to update stress history: $error"));
}

// GET THE STRESS HISTORY
Future<List<List<dynamic>>> getStressHistory(String userId) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final snapshot = await _firestore.collection('customers').doc(userId).get();
  if (snapshot.exists) {
    Map<String, dynamic>? data = snapshot.data();
    if (data != null && data.containsKey('stressHistory')) {
      var stressHistory =
          List<Map<String, dynamic>>.from(data['stressHistory']);
      stressHistory.sort((a, b) {
        DateTime dateA = a['timestamp'].toDate();
        DateTime dateB = b['timestamp'].toDate();
        return dateB.compareTo(dateA);
      });
      List<List<dynamic>> convertedStressHistory = stressHistory.map((entry) {
        DateTime dateTime = entry['timestamp'].toDate();
        String formattedTime = DateFormat('HH:mm:ss').format(dateTime);
        String formattedDate = DateFormat('EEEE ,d MMMM yyyy').format(dateTime);
        var stressScore = entry['stressScore'];
        return [formattedDate, formattedTime, stressScore];
      }).toList();
      print(convertedStressHistory);
      return convertedStressHistory;
    } else {
      print('No stress history available.');
      return [[]];
    }
  } else {
    throw Exception('No data available.');
  }
}

void addCall(String userId, String currentUserId, roomId) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  _firestore.collection('calling').doc(userId).set({currentUserId: roomId},
      SetOptions(merge: true)).then((res) => print("created"));
  if (userId != 'Exams' && currentUserId != 'Exams') {
    _firestore.collection('call_history').doc(roomId).set(
      {
        'callerId': currentUserId,
        'calleeId': userId,
        'roomId': roomId,
        'startedAt': Timestamp.now(),
        'endedAt': null,
        'active': true,
      },
      SetOptions(merge: true),
    );
  }
}

void deleteCall(String userId, String currentUserId) {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  if (userId == 'Exams') {
    FirebaseFirestore.instance
        .collection('calling')
        .get()
        .then((querySnapshot) => querySnapshot.docs.forEach((doc) =>
            FirebaseFirestore.instance
                .collection('calling')
                .doc(doc.id)
                .update({'Exams': FieldValue.delete()})))
        .then((_) => print('Field deleted from all documents successfully.'))
        .catchError(
            (error) => print('Error deleting field from documents: $error'));
  } else {
    _firestore
        .collection('calling')
        .doc(userId)
        .update({
          currentUserId: FieldValue.delete(),
        })
        .then((res) => print("deleted"))
        .catchError((error) => print("Error deleting call: $error"));
  }
}

Future<void> completeCallHistory(String roomId) async {
  if (roomId.isEmpty) {
    return;
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  await _firestore.collection('call_history').doc(roomId).set(
    {
      'endedAt': Timestamp.now(),
      'active': false,
    },
    SetOptions(merge: true),
  );
}
