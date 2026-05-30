import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoapifyService {
  static const String apiKey = "953df91797084793a53dcd50f6c66c8f";

  static Future<Map<String, dynamic>> searchNearbyPlaces(
      String category, double latitude, double longitude) async {
    String geoCategory = "leisure.park";

    switch (category.toLowerCase()) {
      case "games":
        geoCategory = "sport";
        break;

      case "cafe":
        geoCategory = "catering.cafe";
        break;

      case "movies":
        geoCategory = "entertainment.cinema";
        break;
    }

    final url = "https://api.geoapify.com/v2/places"
        "?categories=$geoCategory"
        "&filter=circle:$longitude,$latitude,5000"
        "&limit=20"
        "&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }
}
