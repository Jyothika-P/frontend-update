import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psychesail/model/places.dart';
import 'package:psychesail/model/time.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import './button.dart';
import 'package:animations/animations.dart';

Widget HigthlightText(fontsize, minheight, txt) {
  return Container(
    constraints: BoxConstraints(
      minHeight: minheight,
    ),
    alignment: Alignment.center,
    child: Center(
      child: Text(
        txt,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: fontsize,
            fontFamily: 'ABeeZee',
            color: Colors.white.withOpacity(0.6),
            fontStyle: FontStyle.italic),
        overflow: TextOverflow.fade,
      ),
    ),
  );
}

Widget greyText(fontsize, minheight, txt) {
  return Center(
    child: Text(
      txt,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: fontsize,
          fontFamily: 'ABeeZee',
          color: Colors.grey,
          fontStyle: FontStyle.italic),
      overflow: TextOverflow.fade,
    ),
  );
}

Widget divider(constr, greaterwidth, lesswidth, col) {
  return Row(children: [
    Expanded(
      child: new Container(
          margin: EdgeInsets.symmetric(
              horizontal: constr ? greaterwidth : lesswidth),
          child: Divider(
            color: col,
            height: 36,
            thickness: 0.25,
          )),
    ),
    Text("OR",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: col,
          fontSize: 14,
          fontStyle: FontStyle.italic,
          fontFamily: 'ABeeZee',
          fontWeight: FontWeight.w400,
        )),
    Expanded(
      child: new Container(
          margin: EdgeInsets.symmetric(
              horizontal: constr ? greaterwidth : lesswidth),
          child: Divider(
            color: col,
            height: 36,
            thickness: 0.25,
          )),
    ),
  ]);
}

Widget dividervertical(constr, greaterwidth, lesswidth, col) {
  return Column(
    children: [
      Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          color: Colors.grey,
          height: greaterwidth,
          width: 1,
        ),
      ),
      Text("OR",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: col,
            fontSize: 14,
            fontStyle: FontStyle.italic,
            fontFamily: 'ABeeZee',
            fontWeight: FontWeight.w400,
          )),
      Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          color: Colors.grey,
          height: greaterwidth,
          width: 1,
        ),
      ),
    ],
  );
}

InputDecoration logininput(txt, example) {
  return InputDecoration(
      border: UnderlineInputBorder(),
      labelText: txt,
      labelStyle: TextStyle(
          fontStyle: FontStyle.italic,
          fontFamily: 'ABeeZee',
          fontWeight: FontWeight.w400,
          color: Color.fromRGBO(35, 154, 139, 75)),
      helperText: example);
}

Widget textbubble(
    message, timestamp, receiverid, currentid, bgcolor, condition, context) {
  bool constr = (receiverid == currentid);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment:
          (constr) ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          (constr) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
            child: Padding(
          padding: EdgeInsets.all(9.0),
          child: (constr)
              ? Container()
              : RandomAvatar(receiverid,
                  trBackground: false, height: 50, width: 50),
        )),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: bgcolor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment:
                  (constr) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                      color: (constr) ? Colors.white : Colors.black,
                      fontSize: 17),
                ),
                SizedBox(height: 4),
                Text(
                  timestamp,
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget homechatbubble(
    constr, sizeWidth, sizeHeight, user, context, currentUserId) {
  return Column(children: [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              print(user['id']);
              print(user['email']);
              print(currentUserId);
              if (user['id'].toString() == "monkeybot") {
                Navigator.pushNamed(context, '/monkeybot', arguments: {
                  'receiveremail': user['email'],
                  'receiverid': user['id'],
                  'currentid': currentUserId,
                });
              } else {
                Navigator.pushNamed(context, '/chatroom', arguments: {
                  'receiveremail': user['email'],
                  'receiverid': user['id'],
                  'currentid': currentUserId,
                });
              }
            },
            child: Text(
              user['id'],
              style: TextStyle(
                color: Colors.black,
                fontSize: constr ? sizeWidth / 40 : sizeWidth / 20,
                fontStyle: FontStyle.italic,
                fontFamily: 'ABeeZee',
              ),
            ),
          )
        ],
      ),
    ),
  ]);
}

Widget settingsContainer(constr, rad, sizeWidth, iconUsed, heading, hint) {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: sizeWidth / 4,
          child: CircleAvatar(
              radius: rad,
              backgroundColor: Colors.grey,
              child: Icon(
                iconUsed,
                size: 25,
                color: Colors.black,
              )),
        ),
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                heading,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: constr ? sizeWidth / 40 : sizeWidth / 20,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'ABeeZee',
                ),
              ),
              Text(
                hint,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: constr ? sizeWidth / 40 : sizeWidth / 20,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'ABeeZee',
                ),
              )
            ],
          ),
        )
      ],
    ),
  );
}

Widget _maptextbubble(size) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container(
        //     child: Padding(
        //   padding: EdgeInsets.all(9.0),
        //   child: RandomAvatar("Serenity",
        //       trBackground: false, height: 50, width: 50),
        // )),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                      minHeight: size.height / 3, minWidth: size.width / 4),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/maps_image.png"),
                    fit: BoxFit.cover,
                  )),
                ),
                // Text(
                //   message,
                //   style: TextStyle(
                //       color: Colors.black,
                //       fontSize: 17),
                // ),
                // SizedBox(height: 4),
                Text(
                  "https://maps.app.goo.gl/smBnLVPhTkBku2uk8",
                  style: TextStyle(color: Colors.black, fontSize: 17),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget communityContainer(sizeWidth, sizeHeight, constr, heading, description,
    imagestring, currentid, context) {
  print("inside container");
  print(currentid);
  // decoration: BoxDecoration(
  //   color: Colors.white.withOpacity(0.9) ,
  //   borderRadius: BorderRadius.all(Radius.circular(20.0),),
  //   boxShadow: [
  //     BoxShadow(
  //       color: (snapshot.data[0][index][0] ==
  //           'Serenity') ? Colors.grey.withOpacity(0.5) :Colors.black26 , // Greyish color with opacity
  //       spreadRadius: 2, // Controls how far the shadow spreads
  //       blurRadius: 3, // Controls the blurriness of the shadow
  //       offset: Offset(0, 1), // Controls the position of the shadow
  //     ),
  //   ],
  // ),
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, '/chatroom', arguments: {
        'currentid': currentid,
        'receiverid': 'Disha',
        'communityname': heading,
      });
    },
    child: Container(
      constraints: BoxConstraints(maxWidth: sizeWidth * 0.5),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Greyish color with opacity
              spreadRadius: 3, // Controls how far the shadow spreads
              blurRadius: 3, // Controls the blurriness of the shadow
              offset: Offset(0, 0), // Controls the position of the shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00005),
        child: Column(
          children: [
            circleButton(constr, sizeWidth / 100, sizeWidth / 50, imagestring),
            Text(
              heading,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: sizeWidth * sizeHeight * 0.00008,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: TextStyle(
                color: Colors.black,
                fontSize: sizeWidth * sizeHeight * 0.00005,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    ),
  );
}

Widget bookContainer(sizeWidth, sizeHeight, constr, heading, description,
    imagestring, previewstring) {
  print("inside container");
  print(description.length);
  return Container(
    constraints: BoxConstraints(maxWidth: sizeWidth * 0.95),
    decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0))),
    child: Padding(
      padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00005),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: sizeHeight * 0.3,
                  child: Image.network(
                    imagestring.toString(),
                    fit: BoxFit.cover, // Adjust the fit as needed
                  ),
                ),
                SizedBox(
                  width: min(12, sizeWidth * 0.05),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(heading,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeWidth * sizeHeight * 0.00007,
                              fontWeight: FontWeight.bold),
                          softWrap: true),
                      SizedBox(
                        height: min(12, sizeHeight * 0.05),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sizeWidth * sizeHeight * 0.00002,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: min(12, sizeHeight * 0.05),
            ),
            InkWell(
                onTap: () => _launchUrl(previewstring),
                child: Text(
                  'Preview the recommended book',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ))
          ],
        ),
      ),
    ),
  );
}

Widget callingContainer(sizeWidth, sizeHeight, constr, user) {
  List<String> callQuote = [
    "Answer with kindness.",
    "Speak with purpose.",
    "Listen to understand.",
    "Communicate with empathy.",
    "Connect through words."
  ];
  Random random = Random();
  return Container(
    constraints: BoxConstraints(maxWidth: sizeWidth * 0.5),
    decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0))),
    child: Padding(
      padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00005),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.call, color: Color.fromRGBO(35, 154, 139, 75)),
              SizedBox(width: sizeWidth * 0.01),
              Text(
                "Calling ...",
                style: TextStyle(
                    color: Color.fromRGBO(35, 154, 139, 75),
                    fontSize: sizeWidth * sizeHeight * 0.00005,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          RandomAvatar(user, trBackground: false, height: 50, width: 50),
          Text(
            user,
            style: TextStyle(
                color: Colors.black,
                fontSize: sizeWidth * sizeHeight * 0.00008,
                fontWeight: FontWeight.bold),
          ),
          Text(
            callQuote[random.nextInt(callQuote.length)],
            style: TextStyle(
              color: Colors.black,
              fontSize: sizeWidth * sizeHeight * 0.00005,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget activityContainer(context, sizeWidth, sizeHeight, constr, heading,
    imagestring, pos, currentUserId, Places place) {
  print(pos);
  var response;

  return GestureDetector(
    onTap: () async {
      place.setPlace(heading);
      place.setImagestring(imagestring);
      // print(hello)
      response = await searchNearbyPlaces(place.getPlace(), pos);
      // print("take me to hell");
      print(response);
      place.setObject(response);
      place.setremove(true);
      print(place.getObject());
    },
    child: Container(
      constraints: BoxConstraints(maxWidth: sizeWidth * 0.5),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00005),
        child: Column(
          children: [
            circleButton(constr, sizeWidth / 120, sizeWidth / 100, imagestring),
            Text(
              heading,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: sizeWidth * sizeHeight * 0.00005,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget historyContainer(
    sizeWidth, sizeHeight, constr, date, time, stressEmoji, seeall) {
  return Container(
    constraints: BoxConstraints(minWidth: sizeWidth * 0.7, maxWidth: sizeWidth),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: Colors.grey.shade300,
      ),
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    child: Padding(
      padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00005),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.fromSize(
            size: Size.fromHeight(sizeHeight * 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Color.fromRGBO(35, 154, 139, 75)),
                        SizedBox(width: sizeWidth * 0.02),
                        Text(
                          date,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: sizeWidth * sizeHeight * 0.000045,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    SizedBox(height: sizeHeight * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.schedule,
                            color: Color.fromRGBO(35, 154, 139, 75)),
                        SizedBox(width: sizeWidth * 0.02),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: sizeWidth * sizeHeight * 0.000045,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                circleButton(
                    constr, sizeWidth / 100, sizeWidth / 50, stressEmoji[0]),
              ],
            ),
          ),
          SizedBox(height: sizeHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: sizeWidth * 0.15),
              AnimatedContainer(
                duration: Duration(milliseconds: 5000),
                curve: Curves.linear,
                child: Text(
                  stressEmoji[1],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: stressEmoji[2],
                    fontSize: sizeWidth * sizeHeight * 0.000055,
                  ),
                ),
              ),
              SizedBox(width: sizeWidth * 0.05),
            ],
          ),
          SizedBox(height: sizeHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: sizeWidth * 0.8),
              Text(
                "More",
                style: TextStyle(
                    color: (seeall) ? Colors.white : Colors.black,
                    fontSize: sizeWidth * sizeHeight * 0.000025,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: sizeWidth * 0.0003),
              Icon(Icons.arrow_forward_rounded,
                  color: (seeall) ? Colors.white : Colors.black,
                  size: sizeWidth * sizeHeight * 0.000015)
            ],
          )
        ],
      ),
    ),
  );
}

dynamic searchNearbyPlaces(List<String> places_type, pos) async {
  var responseData;
  print(pos);
  // Define the request body as a JSON object
  var requestBody = {
    "includedTypes": places_type,
    "maxResultCount": 5,
    "locationRestriction": {
      "circle": {
        "center": {"latitude": pos[1], "longitude": pos[0]},
        "radius": 2000.0
      }
    }
  };
  print("hellooo");
  // Encode the request body to JSON
  var requestBodyJson = jsonEncode(requestBody);
  print("hiii");
  // Define the headers
  var headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key':
        'AIzaSyC1ksDmMNde1jArPaZF1VK-Xad2yFyjjHk', // Replace 'YOUR_API_KEY' with your actual API key
    'X-Goog-FieldMask': 'places.displayName,places.googleMapsUri'
  };
// print("hell");
  try {
    // Make the HTTP POST request
    var response = await http.post(
      Uri.parse('https://places.googleapis.com/v1/places:searchNearby'),
      headers: headers,
      body: requestBodyJson,
    );

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Parse the response body (assuming it's JSON) into a Map
      responseData = jsonDecode(response.body);
      // Process the responseData here
      print(responseData);

      // return responseData;
    } else {
      // Request was not successful
      print('Request failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      responseData = jsonDecode(response.body);
    }
  } catch (e) {
    // Handle any errors that occurred during the HTTP request
    print('Error occurred: $e');
  }
  return responseData;
}

Widget communitycontainer(sizeWidth, sizeHeight, constr, heading, googlemapsuri,
    imagestring, bordercolor) {
  return Container(
    constraints: BoxConstraints(maxWidth: sizeWidth * 0.8),
    decoration: BoxDecoration(
        border: Border.all(
          color: bordercolor,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0))),
    child: Padding(
      padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00004),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          circleButton(constr, sizeWidth / 100, sizeWidth / 50, imagestring),
          Text(
            heading,
            style: TextStyle(
                color: Colors.black,
                fontSize: sizeWidth * sizeHeight * 0.00008,
                fontWeight: FontWeight.bold),
          ),
          InkWell(
              onTap: () => _launchUrl(Uri.parse(googlemapsuri)),
              child: Text(
                'Open in Google Maps',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ))
        ],
      ),
    ),
  );
}

Future<void> _launchUrl(Uri _url) async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
Widget activitymaps(sizeWidth, sizeHeight, constr, places, imagestring,
    {Color bordercolor = Colors.grey}) {
  print(places['places']);
  return Wrap(
    spacing: 20,
    runSpacing: min(20, sizeWidth * 0.0006),
    children: [
      SizedBox(
        height: sizeHeight * 0.01,
      ),
      SizedBox(
        height: sizeHeight * 0.25,
        child: ListView.separated(
          reverse: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: places['places'].length,
          itemBuilder: (context, index) {
            return communitycontainer(
                sizeWidth,
                sizeHeight,
                constr,
                places['places'][index]['displayName']['text'].length > 20
                    ? places['places'][index]['displayName']['text']
                        .substring(0, 20)
                    : places['places'][index]['displayName']['text'],
                places['places'][index]['googleMapsUri'],
                imagestring,
                bordercolor == Colors.grey
                    ? Colors.grey.shade300
                    : bordercolor);
          },
          separatorBuilder: ((context, index) => SizedBox(
                width: min(sizeWidth * 0.05, 30),
              )),
        ),
      )
    ],
  );
}

Widget youtubeContainer(
    sizeWidth, sizeHeight, constr, heading, description, imagestring, videoId) {
  print("inside youtube container");
  print(description.length);
  return Container(
    constraints: BoxConstraints(maxWidth: sizeWidth * 0.9),
    decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0))),
    child: Padding(
      padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00005),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: sizeWidth * 0.8,
              child: Image.network(
                imagestring.toString(),
                fit: BoxFit.cover, // Adjust the fit as needed
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: min(12, sizeWidth * 0.05),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(heading,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: sizeWidth * sizeHeight * 0.00003,
                              fontWeight: FontWeight.bold),
                          softWrap: true),
                      SizedBox(
                        height: min(12, sizeHeight * 0.05),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sizeWidth * sizeHeight * 0.00003,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: min(12, sizeHeight * 0.05),
            ),
            InkWell(
                onTap: () => _launchUrl(
                    Uri.parse('https://www.youtube.com/watch?v=$videoId')),
                child: Text(
                  'Checkout the YouTube video here',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ))
          ],
        ),
      ),
    ),
  );
}
