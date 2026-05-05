import 'dart:convert';
import 'package:http/http.dart' as http;

class BookThumbnail {
  final String url;

  BookThumbnail(this.url);
}

class BookItem {
  final String title;
  final String description;
  final List<BookThumbnail> imageLinks;

  BookItem({
    required this.title,
    required this.description,
    required this.imageLinks,
  });
}

class YoutubeThumbnail {
  final String url;

  YoutubeThumbnail(this.url);
}

class YoutubeVideoItem {
  final String title;
  final String views;
  final List<YoutubeThumbnail> thumbnails;
  final String videoId;

  YoutubeVideoItem({
    required this.title,
    required this.views,
    required this.thumbnails,
    required this.videoId,
  });
}

Future<dynamic> buildAPI() async {
  // Fetch books from Google Books API
  const booksApiKey = 'AIzaSyBVOgf5N_kO5_BdX7lZ-DDCRv7bRzYSOOs';
  final booksUri = Uri.parse(
    'https://www.googleapis.com/books/v1/volumes?q=motivation&maxResults=40&printType=books&orderBy=relevance&key=$booksApiKey',
  );
  
  List<BookItem> filteredList = [];
  try {
    final booksResponse = await http.get(booksUri);
    if (booksResponse.statusCode == 200) {
      final booksJson = jsonDecode(booksResponse.body) as Map<String, dynamic>;
      final items = (booksJson['items'] as List? ?? []);
      
      filteredList = items
          .map((item) {
            final volumeInfo = item['volumeInfo'] as Map<String, dynamic>? ?? {};
            final title = volumeInfo['title']?.toString() ?? '';
            final description = volumeInfo['description']?.toString() ?? '';
            final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
            final thumbnail = imageLinks?['thumbnail']?.toString() ?? '';
            
            return BookItem(
              title: title,
              description: description,
              imageLinks: thumbnail.isNotEmpty ? [BookThumbnail(thumbnail)] : [],
            );
          })
          .where((book) =>
              book.description.isNotEmpty &&
              book.description.length <= 214 &&
              book.imageLinks.isNotEmpty &&
              book.title.length <= 20)
          .toList();
    }
  } catch (e) {
    print("Error fetching books: $e");
  }
  
  if (filteredList.length == 0) print("null");

  const youtubeApiKey = 'AIzaSyBVOgf5N_kO5_BdX7lZ-DDCRv7bRzYSOOs';
  final searchUri = Uri.parse(
    'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=motivation&key=$youtubeApiKey',
  );
  final searchResponse = await http.get(searchUri);
  final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;
  final searchItems = (searchJson['items'] as List? ?? []);
  final videoIds = searchItems
      .map((item) => item['id']?['videoId'] as String?)
      .whereType<String>()
      .toList();

  final statisticsById = <String, String>{};
  if (videoIds.isNotEmpty) {
    final statisticsUri = Uri.parse(
      'https://www.googleapis.com/youtube/v3/videos?part=statistics&id=${videoIds.join(',')}&key=$youtubeApiKey',
    );
    final statisticsResponse = await http.get(statisticsUri);
    final statisticsJson = jsonDecode(statisticsResponse.body) as Map<String, dynamic>;
    for (final item in (statisticsJson['items'] as List? ?? [])) {
      final id = item['id'] as String?;
      final views = item['statistics']?['viewCount']?.toString() ?? '0';
      if (id != null) {
        statisticsById[id] = views;
      }
    }
  }

  final List<YoutubeVideoItem> listVideo = searchItems
      .whereType<Map>()
      .map((item) {
        final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
        final id = item['id']?['videoId'] as String? ?? '';
        final thumbnailUrl = snippet['thumbnails']?['high']?['url']?.toString() ??
            snippet['thumbnails']?['medium']?['url']?.toString() ??
            snippet['thumbnails']?['default']?['url']?.toString() ??
            '';
        return YoutubeVideoItem(
          title: snippet['title']?.toString() ?? '',
          views: statisticsById[id] ?? '0',
          thumbnails: [YoutubeThumbnail(thumbnailUrl)],
          videoId: id,
        );
      })
      .where((video) => video.title.isNotEmpty && video.thumbnails.first.url.isNotEmpty)
      .toList();

  if(listVideo.length == 0) print("null");
  return [filteredList, listVideo];
}

Future<dynamic> fetchChatId(userinputs) async {
      var url = Uri.parse('http://192.168.197.137:8000/getChatRoomID');
      try {
        print("Sending request...");
        print(jsonEncode({"inputs": userinputs}));
        var response = await http.post(
          url,
          headers: {
            "content-type": "application/json",
            "Access-Control-Allow-Origin":
                "*", // Required for CORS support to work
            "Access-Control-Allow-Credentials":
                'true', // Required for cookies, authorization headers with HTTPS
            "Access-Control-Allow-Headers":
                "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
            "Access-Control-Allow-Methods": "GET, POST,OPTIONS"
          },
          body: jsonEncode({"inputs": userinputs}),
        );
        if (response.statusCode == 200) {
          print("Data sent successfully");
          print("Response from server: ${response.body}");

          return jsonDecode(response.body);
        } else {
          print("Failed to send data. Status code: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      } catch (e) {
        print("Error sending data: $e");
      }
    }