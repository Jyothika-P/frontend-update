import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:psychesail/utils/constants.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import './button.dart';

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
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
      border: const UnderlineInputBorder(),
      labelText: txt,
      labelStyle: const TextStyle(
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
          padding: const EdgeInsets.all(9.0),
          child: (constr)
              ? Container()
              : RandomAvatar(receiverid,
                  trBackground: false, height: 50, width: 50),
        )),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(11),
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
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
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
    padding: const EdgeInsets.all(16.0),
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
              offset: const Offset(0, 0), // Controls the position of the shadow
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(8.0))),
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
        borderRadius: const BorderRadius.all(Radius.circular(8.0))),
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
                child: const Text(
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
        borderRadius: const BorderRadius.all(Radius.circular(8.0))),
    child: Padding(
      padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00005),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.call, color: Color.fromRGBO(35, 154, 139, 75)),
              SizedBox(width: sizeWidth * 0.01),
              Text(
                "Calling ...",
                style: TextStyle(
                    color: const Color.fromRGBO(35, 154, 139, 75),
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

Widget activityContainer(
    context, sizeWidth, sizeHeight, constr, heading, imagestring,
    {required VoidCallback onTap, bool isSelected = false}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      constraints: BoxConstraints(maxWidth: sizeWidth * 0.5),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
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
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
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
                        const Icon(Icons.calendar_month_rounded,
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
                        const Icon(Icons.schedule,
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
                duration: const Duration(milliseconds: 5000),
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
              SizedBox(width: sizeWidth * 0.4),
              Text(
                "More",
                style: TextStyle(
                    color: (!seeall) ? Colors.white : Colors.black,
                    fontSize: sizeWidth * sizeHeight * 0.000035,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: sizeWidth * 0.0002),
              Icon(Icons.arrow_forward_rounded,
                  color: (!seeall) ? Colors.white : Colors.black,
                  size: sizeWidth * sizeHeight * 0.00002)
            ],
          )
        ],
      ),
    ),
  );
}

Future<dynamic> searchNearbyPlaces(
  List<String> placesType,
  List<dynamic> pos,
) async {
  double latitude = pos[1];
  double longitude = pos[0];

  String category = "leisure.park";

  if (placesType.contains("cafe")) {
    category = "catering.cafe";
  } else if (placesType.contains("restaurant")) {
    category = "catering.restaurant";
  } else if (placesType.contains("movie_theater")) {
    category = "entertainment.cinema";
  } else if (placesType.contains("amusement_park") ||
      placesType.contains("amusement_center") ||
      placesType.contains("theme_park")) {
    category = "entertainment";
  } else if (placesType.contains("park")) {
    category = "leisure.park";
  } else if (placesType.contains("garden")) {
    category = "leisure.park";
  } else if (placesType.contains("tourist_attraction")) {
    category = "tourism";
  }

  const apiKey = MAPS_API;

  final url = "https://api.geoapify.com/v2/places"
      "?categories=$category"
      "&filter=circle:$longitude,$latitude,3000"
      "&limit=10"
      "&apiKey=$apiKey";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("Geoapify Response:");
      print(data);

      return data;
    } else {
      print("Error: ${response.statusCode}");
      print(response.body);

      return {"features": []};
    }
  } catch (e) {
    print("Exception: $e");

    return {"features": []};
  }
}

// dynamic searchNearbyPlaces(List<String> places_type, pos) async {
//   var responseData;
//   print(pos);
//   // Define the request body as a JSON object
//   var requestBody = {
//     "includedTypes": places_type,
//     "maxResultCount": 5,
//     "locationRestriction": {
//       "circle": {
//         "center": {"latitude": pos[1], "longitude": pos[0]},
//         "radius": 2000.0
//       }
//     }
//   };
//   // print("hellooo");
//   // Encode the request body to JSON
//   var requestBodyJson = jsonEncode(requestBody);
//   print("searching nearby places");
//   // Define the headers
//   var headers = {
//     'Content-Type': 'application/json',
//     'X-Goog-FieldMask': 'places.displayName,places.googleMapsUri'
//   };
// // print("hell");
//   try {
//     // Make the HTTP POST request
//     // Use the API key as a query parameter. If you have restrictions on the key,
//     // verify them in Google Cloud Console (APIs & Services -> Credentials).
//     final placesApiKey = 'AIzaSyC1ksDmMNde1jArPaZF1VK-Xad2yFyjjHk';
//     var uri = Uri.parse(
//         'https://places.googleapis.com/v1/places:searchNearby?key=$placesApiKey');
//     var response = await http.post(
//       uri,
//       headers: headers,
//       body: requestBodyJson,
//     );

//     // Check if the request was successful (status code 200)
//     if (response.statusCode == 200) {
//       // Parse the response body (assuming it's JSON) into a Map
//       responseData = jsonDecode(response.body);
//       // Process the responseData here
//       print(responseData);

//       // return responseData;
//     } else {
//       // Request was not successful
//       print('Request failed with status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       try {
//         responseData = jsonDecode(response.body);
//       } catch (_) {
//         responseData = {
//           'error': {'code': response.statusCode, 'message': response.body}
//         };
//       }
//       if (response.statusCode == 403) {
//         print(
//             '403 Permission denied from Google Places API. Check API key, billing, and API restrictions in Google Cloud Console.');
//       }
//     }
//   } catch (e) {
//     // Handle any errors that occurred during the HTTP request
//     print('Error occurred: $e');
//   }
//   return responseData;
// }

Widget communitycontainer(sizeWidth, sizeHeight, constr, heading, googlemapsuri,
    imagestring, bordercolor) {
  return Container(
    constraints: BoxConstraints(maxWidth: sizeWidth * 0.8),
    decoration: BoxDecoration(
        border: Border.all(
          color: bordercolor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8.0))),
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
              child: const Text(
                'Open Location',
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
  final dynamic placeList =
      (places is Map) ? (places['places'] ?? places['features']) : null;
  if (placeList == null || placeList is! List) {
    return SizedBox.shrink();
  }
  print(placeList);
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
          itemCount: placeList.length,
          itemBuilder: (context, index) {
            final item = placeList[index] as Map? ?? {};
            final display = (item.containsKey('displayName') &&
                    item['displayName'] is Map &&
                    item['displayName'].containsKey('text'))
                ? item['displayName']['text']
                : (item['properties'] is Map &&
                        item['properties'].containsKey('name'))
                    ? item['properties']['name']
                    : (item['properties'] is Map &&
                            item['properties'].containsKey('formatted'))
                        ? item['properties']['formatted']
                        : 'Unknown Place';
            final googleMapsUri = item.containsKey('googleMapsUri')
                ? item['googleMapsUri']
                : (item['properties'] is Map &&
                        item['properties'].containsKey('osm_url'))
                    ? item['properties']['osm_url']
                    : (item['properties'] is Map &&
                            item['properties'].containsKey('lat') &&
                            item['properties'].containsKey('lon'))
                        ? 'https://www.google.com/maps/search/?api=1&query=${item['properties']['lat']},${item['properties']['lon']}'
                        : '';
            return communitycontainer(
                sizeWidth,
                sizeHeight,
                constr,
                display.length > 20 ? display.substring(0, 20) : display,
                googleMapsUri,
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
        borderRadius: const BorderRadius.all(Radius.circular(8.0))),
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
                child: const Text(
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
