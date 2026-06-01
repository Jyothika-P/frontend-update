import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:psychesail/components/activity_widget.dart';
import 'package:psychesail/components/api.dart';
import 'package:psychesail/components/crud.dart';
import 'package:psychesail/components/text.dart';
import 'package:psychesail/components/vertical_scroll.dart';
import 'package:psychesail/model/places.dart';
import 'package:psychesail/pages/chats.dart';
import 'package:psychesail/pages/past_calls.dart';
import 'package:random_avatar/random_avatar.dart';
import '../components/button.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class User {
  final String name;
  final String email;
  User(this.name, this.email);
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}

class home extends StatefulWidget {
  const home({
    super.key,
  });

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  ScrollController _scrollController = ScrollController();
  bool _showTopContainer = true;
  bool _showBottomContainer = false;
  bool flag = true;
  int _selectedTab = 0;
  late Future<Position> _currentPositionFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _currentPositionFuture = _determinePosition();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      setState(() {
        _showTopContainer = true;
        flag = false;
        _showBottomContainer = false;
      });
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      setState(() {
        _showTopContainer = false;
        _showBottomContainer = true;
      });
    }
  }

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

  List<List<dynamic>> _homeChatPreview(List<List<dynamic>> allChats) {
    if (allChats.isEmpty) {
      return [];
    }

    final preview = <List<dynamic>>[];
    final serenity = allChats.firstWhere(
      (chat) => chat.isNotEmpty && chat[0] == 'Serenity',
      orElse: () => [],
    );

    if (serenity.isNotEmpty) {
      preview.add(serenity);
    }

    final latestFriendChat = allChats.firstWhere(
      (chat) => chat.isNotEmpty && chat[0] != 'Serenity',
      orElse: () => [],
    );

    if (latestFriendChat.isNotEmpty) {
      preview.add(latestFriendChat);
    }

    if (preview.isEmpty) {
      preview.add(allChats.first);
    }

    return preview;
  }

  void _openChatFromHome(BuildContext context, List<dynamic> chat,
      String currentUserId, Places place) {
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

  //var position = null ;
  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    var currentUserId = '';
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Access individual parameters

    currentUserId = args?['currentuser'] ?? "";
    _selectedTab = args?['selectedTab'] ?? _selectedTab;
    Places place = Provider.of<Places>(context);
    print(place.getPlace());
    place.setPlace('Games');
    place.setImagestring('assets/games.png');

    // List<List<dynamic>> stressHistory = getStressHistory();
    // var stressHistory = (getStressHistory(currentUserId)==[])? getStressHistory(currentUserId):[['yyyy-mm-dd','hh:mm:ss','5']];

    return FutureBuilder<Position>(
        future: _currentPositionFuture,
        builder: (context, locationSnapshot) {
          final double positionLong = locationSnapshot.data?.longitude ??
              ((args?['positionLong'] ?? 0).toDouble());
          final double positionLat = locationSnapshot.data?.latitude ??
              ((args?['positionLat'] ?? 0).toDouble());

          print("position Longitude: ");
          print(positionLong);
          print("position Latitude: ");
          print(positionLat);

          if (locationSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Text(
                  'Fetching current location...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }

          if (locationSnapshot.hasError) {
            print('Location fetch failed: ${locationSnapshot.error}');
          }

          return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            bool constr = false;
            if (constraints.maxWidth > 600) constr = true;
            return Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  centerTitle: true,
                  title: Text("Home"),
                  actions: [
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: sizeWidth / 20),
                        child: RandomAvatar(
                          currentUserId,
                          trBackground: false,
                          height: 50,
                          width: 50,
                        )),
                  ],
                ),
                body: _selectedTab == 1
                    ? ChatsContent(
                        currentUserId: currentUserId,
                        place: place,
                      )
                    : _selectedTab == 2
                        ? PastCallsContent(currentUserId: currentUserId)
                        : CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: AnimatedOpacity(
                                  opacity: _showTopContainer ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 200),
                                  child: Container(
                                    height: sizeHeight * 0.7,
                                    color: Colors.transparent,
                                    child: Container(
                                      height: sizeHeight * 0.7,
                                      child: SingleChildScrollView(
                                        child: FutureBuilder<dynamic>(
                                            future: buildAPI(), // async work
                                            builder: (BuildContext context,
                                                AsyncSnapshot<dynamic>
                                                    snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  return Center(
                                                    child: Text(
                                                      'Loading....',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  );
                                                default:
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          bookscroll(
                                                              sizeWidth,
                                                              sizeHeight,
                                                              constr,
                                                              "Books",
                                                              snapshot.data[0],
                                                              currentUserId,
                                                              context),
                                                          SizedBox(
                                                            height: sizeHeight *
                                                                0.03,
                                                          ),
                                                          youtubescroll(
                                                              sizeWidth,
                                                              sizeHeight,
                                                              constr,
                                                              "YouTube",
                                                              snapshot.data[1],
                                                              currentUserId,
                                                              context),
                                                          SizedBox(
                                                            height: sizeHeight *
                                                                0.03,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                              }
                                            }),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Container(
                                        height: sizeHeight * 0.73,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(50.0),
                                                topRight:
                                                    Radius.circular(50.0))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: sizeWidth / 2.3),
                                              child: Divider(
                                                color: const Color.fromARGB(
                                                    255, 201, 195, 195),
                                                height: 36,
                                                thickness: 3,
                                              ),
                                            ),
                                            AnimatedOpacity(
                                              opacity: _showBottomContainer
                                                  ? 1.0
                                                  : 0.0,
                                              duration:
                                                  Duration(milliseconds: 200),
                                              child: Container(
                                                height: sizeHeight * 0.68,
                                                child: SingleChildScrollView(
                                                  child: FutureBuilder<dynamic>(
                                                      future: getDataFuture(
                                                          currentUserId,
                                                          place, [
                                                        positionLong,
                                                        positionLat
                                                      ]), // async work
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                        switch (snapshot
                                                            .connectionState) {
                                                          case ConnectionState
                                                                .waiting:
                                                            return Text(
                                                              'Loading....',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            );
                                                          default:
                                                            if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error: ${snapshot.error}');
                                                            } else {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16.0),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    Builder(builder:
                                                                        (context) {
                                                                      final allChats =
                                                                          _sortedChats(
                                                                              snapshot.data[0]);
                                                                      final homeChats =
                                                                          _homeChatPreview(
                                                                              allChats);

                                                                      return ListView.builder(
                                                                          scrollDirection: Axis.vertical,
                                                                          shrinkWrap: true,
                                                                          itemCount: homeChats.length,
                                                                          itemBuilder: (BuildContext context, int index) {
                                                                            final chat =
                                                                                homeChats[index];
                                                                            final receiverId =
                                                                                chat[0].toString();
                                                                            final chatMeta = chat.length > 1 && chat[1] is Map
                                                                                ? Map<String, dynamic>.from(chat[1] as Map)
                                                                                : <String, dynamic>{};
                                                                            final DateTime
                                                                                now =
                                                                                DateTime.now();
                                                                            final formattedDate =
                                                                                dateFormatter.format(now);
                                                                            return Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                              child: InkWell(
                                                                                onTap: () => _openChatFromHome(context, chat, currentUserId, place),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.white.withOpacity(0.9),
                                                                                    borderRadius: BorderRadius.all(
                                                                                      Radius.circular(20.0),
                                                                                    ),
                                                                                    boxShadow: [
                                                                                      BoxShadow(
                                                                                        color: (receiverId == 'Serenity') ? Colors.grey.withOpacity(0.5) : Colors.black26, // Greyish color with opacity
                                                                                        spreadRadius: 2, // Controls how far the shadow spreads
                                                                                        blurRadius: 3, // Controls the blurriness of the shadow
                                                                                        offset: Offset(0, 1), // Controls the position of the shadow
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: (receiverId == 'Serenity') ? 8.0 : 6.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                      children: [
                                                                                        Container(
                                                                                          width: sizeWidth / 5,
                                                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                                                                                          child: !(receiverId == "Serenity") ? RandomAvatar(receiverId, trBackground: false, height: 50, width: 50) : circleButton(constr, sizeWidth / 150, sizeWidth / 45, "assets/serenity_1.png", borderneed: false),
                                                                                        ),
                                                                                        Container(
                                                                                          width: sizeWidth / 2.6,
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            children: [
                                                                                              Text(
                                                                                                receiverId,
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black,
                                                                                                  fontSize: constr ? sizeWidth / 40 : sizeWidth / 20,
                                                                                                  fontStyle: FontStyle.italic,
                                                                                                  fontFamily: 'ABeeZee',
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                (receiverId == 'Serenity')
                                                                                                    ? "There for u 😇"
                                                                                                    : (chatMeta['message']?.toString() ?? '').length < 20
                                                                                                        ? (chatMeta['message']?.toString() ?? '')
                                                                                                        : (chatMeta['message']?.toString() ?? '').substring(0, 20),
                                                                                                style: TextStyle(color: (receiverId == 'Serenity') ? Color.fromRGBO(35, 154, 139, 75) : Colors.grey, fontFamily: 'AbeeZee'),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          width: sizeWidth / 4,
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                            children: [
                                                                                              Text(
                                                                                                (() {
                                                                                                  final msgDate = chatMeta['date'] ?? '';
                                                                                                  final msgTimeStr = chatMeta['time'] ?? '';
                                                                                                  if (msgDate == formattedDate) {
                                                                                                    try {
                                                                                                      final parsedTime = DateFormat('hh:mm:ss').parse(msgTimeStr);
                                                                                                      return DateFormat('hh:mm a').format(parsedTime);
                                                                                                    } catch (_) {
                                                                                                      return msgTimeStr;
                                                                                                    }
                                                                                                  } else {
                                                                                                    return msgDate;
                                                                                                  }
                                                                                                })(),
                                                                                                style: TextStyle(
                                                                                                  color: (receiverId == 'Serenity') ? Color.fromRGBO(35, 154, 139, 75) : Colors.grey,
                                                                                                  fontStyle: FontStyle.italic,
                                                                                                  fontFamily: 'ABeeZee',
                                                                                                ),
                                                                                              ),
                                                                                              CircleAvatar(
                                                                                                  maxRadius: constr ? sizeWidth / 65 : sizeWidth / 40,
                                                                                                  backgroundColor: Colors.transparent,
                                                                                                  child: Text(
                                                                                                    "",
                                                                                                    style: TextStyle(fontSize: sizeWidth / 50),
                                                                                                  )),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          });
                                                                    }),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _selectedTab =
                                                                                1;
                                                                          });
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              top: 6.0,
                                                                              right: 6.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: const [
                                                                              Text(
                                                                                'More',
                                                                                style: TextStyle(
                                                                                  color: Colors.black54,
                                                                                  fontSize: 12,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 3),
                                                                              Icon(
                                                                                Icons.arrow_forward_rounded,
                                                                                color: Colors.black54,
                                                                                size: 14,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          sizeHeight *
                                                                              0.03,
                                                                    ),
                                                                    historyscroll(
                                                                        sizeWidth,
                                                                        sizeHeight,
                                                                        constr,
                                                                        "History",
                                                                        snapshot
                                                                            .data[5],
                                                                        context,
                                                                        currentUserId),
                                                                    SizedBox(
                                                                      height:
                                                                          sizeHeight *
                                                                              0.03,
                                                                    ),
                                                                    communityscroll(
                                                                        sizeWidth,
                                                                        sizeHeight,
                                                                        constr,
                                                                        "Community Discussions",
                                                                        snapshot
                                                                            .data[1],
                                                                        currentUserId,
                                                                        context),
                                                                    SizedBox(
                                                                      height:
                                                                          sizeHeight *
                                                                              0.03,
                                                                    ),
                                                                    ActivityMapsWidget(
                                                                      sizeWidth:
                                                                          sizeWidth,
                                                                      sizeHeight:
                                                                          sizeHeight,
                                                                      constr:
                                                                          constr,
                                                                      pos: [
                                                                        positionLong,
                                                                        positionLat
                                                                      ],
                                                                      con:
                                                                          context,
                                                                      activityString:
                                                                          "Stress Busting Activities",
                                                                      currentUserId:
                                                                          currentUserId,
                                                                      arr: snapshot
                                                                          .data[2],
                                                                    ),
                                                                    callingscroll(
                                                                        context,
                                                                        sizeWidth,
                                                                        sizeHeight,
                                                                        constr,
                                                                        "Calls",
                                                                        snapshot.data[
                                                                            4],
                                                                        currentUserId,
                                                                        onSeeAllTap:
                                                                            () {
                                                                      setState(
                                                                          () {
                                                                        _selectedTab =
                                                                            2;
                                                                      });
                                                                    }),
                                                                    SizedBox(
                                                                      height:
                                                                          sizeHeight *
                                                                              0.03,
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                        }
                                                      }),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ));
                                  },
                                  childCount: 1,
                                ),
                              )
                            ],
                          ),
                bottomNavigationBar: BottomNavigationBar(
                    currentIndex: _selectedTab,
                    onTap: (int index) async {
                      if (index == 0 || index == 1 || index == 2) {
                        setState(() {
                          _selectedTab = index;
                        });
                      } else if (index == 3) {
                        final result = await Navigator.pushNamed(
                            context, '/settings',
                            arguments: {'currentid': currentUserId});
                        if (result is int) {
                          setState(() {
                            _selectedTab = result;
                          });
                        }
                      }
                    },
                    unselectedItemColor: Color.fromRGBO(35, 154, 139, 75),
                    fixedColor: Color.fromRGBO(35, 154, 139, 75),
                    backgroundColor: Colors.white,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.message),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat_bubble_outline),
                        label: "Chats",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.call),
                        label: "Calls",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings),
                        label: "Settings",
                      ),
                    ]));
          });
        });
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled');
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return Future.error('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied');
  }

  return Geolocator.getCurrentPosition();
}

getDataFuture(String currentUserId, place, pos) async {
  var data = getUsers(currentUserId);
  if (!place.getval()) {
    var response = await searchNearbyPlaces(place.getPlace(), pos);

    // print("take me to hell");
    print(response);
    place.setObject(response);
    place.setval();
    place.setremove(false);
  }

  return data;
}

format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
