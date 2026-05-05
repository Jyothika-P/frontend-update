import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:psychesail/components/activity_widget.dart';
import 'package:psychesail/components/api.dart';
import 'package:psychesail/components/crud.dart';
import 'package:psychesail/components/text.dart';
import 'package:psychesail/components/vertical_scroll.dart';
import 'package:psychesail/model/places.dart';
import 'package:random_avatar/random_avatar.dart';
import '../components/button.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      setState(() {
        _showTopContainer = true;
        flag = false;
        _showBottomContainer = false;
      });
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() {
        _showTopContainer = false;
        _showBottomContainer = true;
      });
    }
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
    var positionLong = args?['positionLong'] ?? 0;
    var positionLat = args?['positionLat'] ?? 0;
    print("position Longitude: ");
    print(positionLong);
    print("position Latitude: ");
    print(positionLat);
    Places place = Provider.of<Places>(context);
    print(place.getPlace());
    place.setPlace('Games');
    place.setImagestring('assets/games.png');

    // List<List<dynamic>> stressHistory = getStressHistory();
    // var stressHistory = (getStressHistory(currentUserId)==[])? getStressHistory(currentUserId):[['yyyy-mm-dd','hh:mm:ss','5']];

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
                      padding: EdgeInsets.symmetric(horizontal: sizeWidth / 20),
                      child: RandomAvatar(
                        currentUserId,
                        trBackground: false,
                        height: 50,
                        width: 50,
                      )),
                ],
              ),
              body: CustomScrollView(
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
                                    AsyncSnapshot<dynamic> snapshot) {
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
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
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
                                                height: sizeHeight * 0.03,
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
                                                height: sizeHeight * 0.03,
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
                                    topRight: Radius.circular(50.0))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: sizeWidth / 2.3),
                                  child: Divider(
                                    color: const Color.fromARGB(255, 201, 195, 195),
                                    height: 36,
                                    thickness: 3,
                                  ),
                                ),
                                AnimatedOpacity(
                                  opacity: _showBottomContainer ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 200),
                                  child: Container(
                                    height: sizeHeight * 0.68,
                                    child: SingleChildScrollView(
                                      child: FutureBuilder<dynamic>(
                                          future: getDataFuture(currentUserId,place,[positionLong, positionLat]),  // async work
                                          builder: (BuildContext context,
                                              AsyncSnapshot<dynamic> snapshot) {
                                            switch (snapshot.connectionState) {
                                              case ConnectionState.waiting:
                                                return Text(
                                                  'Loading....',
                                                  style: TextStyle(color: Colors.black),
                                                );
                                              default:
                                                if (snapshot.hasError) {
                                                  return Text('Error: ${snapshot.error}');
                                                } else {
                                                  return Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.spaceAround,
                                                      children: [
                                                        ListView.builder(
                                                            scrollDirection: Axis.vertical,
                                                            shrinkWrap: true,
                                                            itemCount:
                                                            snapshot.data[0].length,
                                                            itemBuilder:
                                                                (BuildContext context,
                                                                int index) {
                                                              final DateTime now =
                                                              DateTime.now();
                                                              final formattedDate =
                                                              dateFormatter.format(now);
                                                              final formattedTime =
                                                              timeFormatter.format(now);

                                                              DateTime checkTime =
                                                              DateFormat("hh:mm:ss")
                                                                  .parse(formattedTime);
                                                              final diffTime = checkTime
                                                                  .difference(DateFormat(
                                                                  "hh:mm:ss")
                                                                  .parse(snapshot
                                                                  .data[0][index][1][
                                                              'time']));
                                                              return Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(vertical: 8.0),
                                                                child: InkWell(
                                                                  onTap: () => {
                                                                    if (snapshot.data[0][index][0] ==
                                                                        'Serenity')
                                                                      {
                                                                        Navigator.pushNamed(
                                                                            context,
                                                                            '/monkeybot',
                                                                            arguments: {
                                                                              'receiverid': snapshot
                                                                                  .data[0]
                                                                              [index][0],
                                                                              'currentid':
                                                                              currentUserId,
                                                                              'lastmessage': snapshot
                                                                                  .data[0]
                                                                              [index][1][
                                                                              'message'],
                                                                              'obj': place.getObject(),
                                                                              'url' : place.getImagestring()

                                                                            })
                                                                      }
                                                                    else
                                                                      {
                                                                        Navigator.pushNamed(
                                                                            context,
                                                                            '/chatroom',
                                                                            arguments: {
                                                                              'receiverid': snapshot
                                                                                  .data[0]
                                                                              [index][0],
                                                                              'currentid':
                                                                              currentUserId,
                                                                              'receiveremail':
                                                                              'gaand_maarao'
                                                                            })
                                                                      }
                                                                  },
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white.withOpacity(0.9) ,
                                                                      borderRadius: BorderRadius.all(Radius.circular(20.0),),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: (snapshot.data[0][index][0] ==
                                                                              'Serenity') ? Colors.grey.withOpacity(0.5) :Colors.black26 , // Greyish color with opacity
                                                                          spreadRadius: 2, // Controls how far the shadow spreads
                                                                          blurRadius: 3, // Controls the blurriness of the shadow
                                                                          offset: Offset(0, 1), // Controls the position of the shadow
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    child: Padding(
                                                                      padding:
                                                                      EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                          9.0, vertical: (snapshot.data[0][index][0] ==
                                                                          'Serenity') ? 8.0 : 6.0),
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                            sizeWidth / 5,
                                                                            decoration: BoxDecoration(
                                                                                borderRadius:
                                                                                BorderRadius
                                                                                    .circular(
                                                                                    5)),
                                                                            child: !(snapshot
                                                                                .data[
                                                                            0]
                                                                            [index][0] ==
                                                                                "Serenity")
                                                                                ? RandomAvatar(
                                                                                snapshot
                                                                                    .data[
                                                                                0]
                                                                                [index][0],
                                                                                trBackground:
                                                                                false,
                                                                                height:
                                                                                50,
                                                                                width: 50)
                                                                                : circleButton(
                                                                                constr,
                                                                                sizeWidth /
                                                                                    150,
                                                                                sizeWidth /
                                                                                    45,
                                                                                "assets/serenity_1.png",borderneed : false),
                                                                          ),
                                                                          Container(
                                                                            width: sizeWidth /
                                                                                2.6,
                                                                            child: Column(
                                                                              crossAxisAlignment:
                                                                              CrossAxisAlignment
                                                                                  .center,
                                                                              children: [
                                                                                Text(
                                                                                  snapshot
                                                                                      .data[0]
                                                                                  [index][0],
                                                                                  style:
                                                                                  TextStyle(
                                                                                    color: Colors
                                                                                        .black,
                                                                                    fontSize: constr
                                                                                        ? sizeWidth /
                                                                                        40
                                                                                        : sizeWidth /
                                                                                        20,
                                                                                    fontStyle:
                                                                                    FontStyle
                                                                                        .italic,
                                                                                    fontFamily:
                                                                                    'ABeeZee',
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  (snapshot.data[0][index][0] ==
                                                                                      'Serenity') ?"There for u 😇" : snapshot.data[0][index][1]['message'].length <
                                                                                      20
                                                                                      ? snapshot.data[0][index][1][
                                                                                  'message']
                                                                                      : snapshot
                                                                                      .data[
                                                                                  0]
                                                                                  [index][1][
                                                                                  'message']
                                                                                      .substring(0,
                                                                                      20) ,
                                                                                  style:
                                                                                  TextStyle(
                                                                                    color:  (snapshot.data[0][index][0] ==
                                                                                        'Serenity') ?Color.fromRGBO(35, 154, 139, 75) :Colors
                                                                                        .grey,
                                                                                    fontFamily: 'AbeeZee'
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                            sizeWidth / 4,
                                                                            child: Column(
                                                                              crossAxisAlignment:
                                                                              CrossAxisAlignment
                                                                                  .center,
                                                                              mainAxisAlignment:
                                                                              MainAxisAlignment
                                                                                  .spaceAround,
                                                                              children: [
                                                                                Text(
                                                                                  formattedDate ==
                                                                                      snapshot.data[0][index][1][
                                                                                      'date']
                                                                                      ? diffTime.inHours ==
                                                                                      00
                                                                                      ? diffTime.inMinutes ==
                                                                                      00
                                                                                      ? "${diffTime.inSeconds.toString()} sec"
                                                                                      : "${diffTime.inMinutes.toString()} mins"
                                                                                      : "${diffTime.inHours.toString()} hours"
                                                                                      : snapshot
                                                                                      .data[0]
                                                                                  [index][1]['date'],
                                                                                  style:
                                                                                  TextStyle(
                                                                                    color: (snapshot.data[0][index][0] ==
                                                                                        'Serenity') ?Color.fromRGBO(35, 154, 139, 75) :Colors
                                                                                        .grey,
                                                                                    fontStyle:
                                                                                    FontStyle
                                                                                        .italic,
                                                                                    fontFamily:
                                                                                    'ABeeZee',
                                                                                  ),
                                                                                ),
                                                                                CircleAvatar(
                                                                                    maxRadius: constr
                                                                                        ? sizeWidth /
                                                                                        65
                                                                                        : sizeWidth /
                                                                                        40,
                                                                                    backgroundColor:
                                                                                    Colors
                                                                                        .transparent,
                                                                                    child:
                                                                                    Text(
                                                                                      "",
                                                                                      style: TextStyle(
                                                                                          fontSize:
                                                                                          sizeWidth / 50),
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
                                                            }),
                                                        SizedBox(
                                                          height: sizeHeight * 0.03,
                                                        ),
                                                        historyscroll(
                                                            sizeWidth,
                                                            sizeHeight,
                                                            constr,
                                                            "History",
                                                            snapshot.data[5],
                                                            context,
                                                            currentUserId),
                                                        SizedBox(
                                                          height: sizeHeight * 0.03,
                                                        ),
                                                        communityscroll(
                                                            sizeWidth,
                                                            sizeHeight,
                                                            constr,
                                                            "Community Discussions",
                                                            snapshot.data[1],
                                                            currentUserId,
                                                            context),
                                                        SizedBox(
                                                          height: sizeHeight * 0.03,
                                                        ),

                                                        ActivityMapsWidget(
                                                          sizeWidth: sizeWidth,
                                                          sizeHeight: sizeHeight,
                                                          constr: constr,
                                                          pos: [positionLong, positionLat],
                                                          con:context,
                                                          activityString: "Stress Busting Activities",
                                                          currentUserId : currentUserId,
                                                          arr: snapshot.data[2],
                                                        ),
                                                        callingscroll(
                                                            sizeWidth,
                                                            sizeHeight,
                                                            constr,
                                                            "Calls",
                                                            snapshot.data[4],
                                                            currentUserId),
                                                        SizedBox(
                                                          height: sizeHeight * 0.03,
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
                      },childCount: 1,
                    ),
                  )],
              ),
              bottomNavigationBar: BottomNavigationBar(
                  onTap: (int index) {
                    if(index == 1) {
                      Navigator.pushNamed(context, '/video',
                          arguments: {'currentid': currentUserId, 'senderid' : "Joe"}
                      );
                    } else
                    if (index == 2) {
                      Navigator.pushNamed(context, '/settings',
                          arguments: {'currentid': currentUserId});
                    }
                  },
                  unselectedItemColor: Color.fromRGBO(35, 154, 139, 75),
                  fixedColor: Color.fromRGBO(35, 154, 139, 75),
                  backgroundColor: Colors.white,

                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.message,
                        color: Color.fromRGBO(35, 154, 139, 75),
                      ),
                      label: "Message",
                    ),
                    BottomNavigationBarItem(
                      icon:
                      Icon(Icons.call, color: Color.fromRGBO(35, 154, 139, 75)),
                      label: "Calls",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings,
                          color: Color.fromRGBO(35, 154, 139, 75)),
                      label: "Settings",
                    ),
                  ]));
        });
  }
}

getDataFuture(String currentUserId,place,pos) async {
  var data = getUsers(currentUserId);
  if(!place.getval()) {
    var response = await searchNearbyPlaces(place.getPlace(), pos);

    // print("take me to hell");
    print(response);
    place.setObject(response);
    place.setval();
    place.setremove(false);

  }

  return data;
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
      return Future.error("Location permission denied");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied');
  }

  Position position = await Geolocator.getCurrentPosition();

  return position;
}

format(Duration d) => d.toString().split('.').first.padLeft(8, "0");