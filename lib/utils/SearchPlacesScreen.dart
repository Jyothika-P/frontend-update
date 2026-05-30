import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class SearchPlacesScreen extends StatelessWidget {
  SearchPlacesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    Position pos = args?['pos'];
    final List<String> places = List<String>.from(args?['place'] ?? <String>[]);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Google Search Places"),
        ),
        body: ElevatedButton(
            onPressed: () {
              searchNearbyPlaces(places, pos as List);
            },
            child: const Text("Search Places")));
  }
}

Future<dynamic> searchNearbyPlaces(
  List<String> placesType,
  List<dynamic> pos,
) async {
  final latitude = pos[1];
  final longitude = pos[0];

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
  } else if (placesType.contains("tourist_attraction")) {
    category = "tourism";
  } else if (placesType.contains("park")) {
    category = "leisure.park";
  }

  const apiKey = "YOUR_GEOAPIFY_KEY";

  final uri = Uri.parse(
    "https://api.geoapify.com/v2/places"
    "?categories=$category"
    "&filter=circle:$longitude,$latitude,3000"
    "&limit=5"
    "&apiKey=$apiKey",
  );

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {"features": []};
  } catch (e) {
    print(e);
    return {"features": []};
  }
}
