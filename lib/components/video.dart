import 'dart:convert';
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
    print(json.decode(httpResponse.body));
    return json.decode(httpResponse.body)['roomId'];
  } catch (e) {
    print("Error : ${e}");
  }
  return "";
}
