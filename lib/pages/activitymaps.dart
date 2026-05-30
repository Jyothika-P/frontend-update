import 'dart:math';

import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/button.dart';
import '../components/text.dart';

class ActivityMaps extends StatefulWidget {
  const ActivityMaps({super.key});

  @override
  State<ActivityMaps> createState() => _ActivityMapsState();
}

class _ActivityMapsState extends State<ActivityMaps> {
  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    var imagestring = '';
    // var places = Map<String, dynamic>;
    var currentUserId = '';
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Access individual parameters
    imagestring = args?['imagestring'] ?? "";
    // places = args?['places']?? [].asMap();
    final Map<String, dynamic> places =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    currentUserId = args?['currentUserId'] ?? '';

    print(places);
    print(imagestring);
    print(currentUserId);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      bool constr = false;
      if (constraints.maxWidth > 600) constr = true;

      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Activity-Maps"),
          ),
          body: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0))),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: sizeWidth / 2.3),
                          child: Divider(
                            color: const Color.fromARGB(255, 201, 195, 195),
                            height: 36,
                            thickness: 3,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    activitymaps(sizeWidth, sizeHeight, constr,
                                        places, imagestring)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ]))));
    });
  }

  Widget activitymaps(
    sizeWidth,
    sizeHeight,
    constr,
    places,
    imagestring,
  ) {
    final features = places['features'] ?? [];

    return Wrap(
      spacing: 20,
      runSpacing: min(20, sizeWidth * 0.0006),
      children: [
        SizedBox(
          height: sizeHeight * 0.01,
        ),
        SizedBox(
          height: sizeHeight * 0.77,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: features.length,
            itemBuilder: (context, index) {
              final props = features[index]['properties'];

              final name =
                  props['name'] ?? props['formatted'] ?? "Unknown Place";

              final lat = props['lat'];
              final lon = props['lon'];
              print("lat: $lat, lon: $lon");
              final mapsUrl =
                  "https://www.google.com/maps/search/?api=1&query=$lat,$lon";

              return communitycontainer(
                sizeWidth,
                sizeHeight,
                constr,
                name.length > 20 ? name.substring(0, 20) : name,
                mapsUrl,
                imagestring,
              );
            },
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                width: min(sizeWidth * 0.05, 30),
              ),
            ),
          ),
        ),
      ],
    );
  }

// Widget activitymaps(sizeWidth, sizeHeight, constr, places, imagestring) {
//     print(places['places']);
//     return Wrap(
//       spacing: 20,
//       runSpacing: min(20, sizeWidth * 0.0006),
//       children: [
//         SizedBox(
//           height: sizeHeight * 0.01,
//         ),
//         SizedBox(
//           height: sizeHeight *0.77,
//           child: ListView.separated(
//             reverse: false,
//             scrollDirection: Axis.vertical,
//             shrinkWrap: true,
//             itemCount: places['places']['places'].length,
//             itemBuilder: (context, index) {
//               return communitycontainer(
//                   sizeWidth,
//                   sizeHeight,
//                   constr,
//                   places['places'][index]['displayName']['text'].length > 20 ?  places['places'][index]['displayName']['text'].substring(0,20) :  places['places'][index]['displayName']['text'],
//                   places['places'][index]['googleMapsUri'],
//                   imagestring);
//             },
//             separatorBuilder: ((context, index) => Padding(
//               padding: const EdgeInsets.all(10),
//               child: SizedBox(
//                 width: min(sizeWidth * 0.05, 30),
//               ),
//             )),
//           ),
//         )
//       ],
//     );
//   }
// }
  Widget communitycontainer(
      sizeWidth, sizeHeight, constr, heading, googlemapsuri, imagestring) {
    return Container(
      constraints: BoxConstraints(maxWidth: sizeWidth * 0.8),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
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
}
