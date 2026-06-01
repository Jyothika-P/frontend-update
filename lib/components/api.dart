import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:psychesail/utils/constants.dart';

class BookThumbnail {
  final String url;

  BookThumbnail(this.url);
}

class BookItem {
  final String title;
  final String description;
  final List<BookThumbnail> imageLinks;
  final String previewLink;

  BookItem({
    required this.title,
    required this.description,
    required this.imageLinks,
    required this.previewLink,
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
  const booksApiKey = BOOKS_YOUTUBE_API_KEY;
  final booksUri = Uri.parse(
    'https://www.googleapis.com/books/v1/volumes?q=motivation+for+college+kids&maxResults=40&printType=books&orderBy=relevance&key=$booksApiKey',
  );

  List<BookItem> filteredList = [];
  try {
    final booksResponse = await http.get(booksUri);
    if (booksResponse.statusCode == 200) {
      final booksJson = jsonDecode(booksResponse.body) as Map<String, dynamic>;
      final items = (booksJson['items'] as List? ?? []);

      filteredList = items
          .map((item) {
            final volumeInfo =
                item['volumeInfo'] as Map<String, dynamic>? ?? {};
            final title = volumeInfo['title']?.toString() ?? '';
            final description = volumeInfo['description']?.toString() ?? '';
            final imageLinks =
                volumeInfo['imageLinks'] as Map<String, dynamic>?;
            final thumbnail = imageLinks?['thumbnail']?.toString() ?? '';
            final previewLink =
                volumeInfo['previewLink']?.toString() ??
                    volumeInfo['infoLink']?.toString() ??
                    '';

            return BookItem(
              title: title,
              description: description,
              imageLinks:
                  thumbnail.isNotEmpty ? [BookThumbnail(thumbnail)] : [],
              previewLink: previewLink,
            );
          })
          .where((book) => book.title.isNotEmpty && book.imageLinks.isNotEmpty)
          .toList();
    }
  } catch (e) {
    print("Error fetching books: $e");
  }

  if (filteredList.length == 0) print("null");

  const youtubeApiKey = BOOKS_YOUTUBE_API_KEY;
  final searchUri = Uri.parse(
    'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=powerful+leaders+speeches+ted+talks&safeSearch=strict&key=$youtubeApiKey',
  );

  List<dynamic> searchItems = [];
  try {
    final searchResponse = await http.get(searchUri);
    final searchJson = jsonDecode(searchResponse.body) as Map<String, dynamic>;

    if (searchResponse.statusCode == 200) {
      searchItems = (searchJson['items'] as List? ?? []);
    } else {
      final errorMessage =
          (searchJson['error'] is Map &&
                  searchJson['error']['message'] != null)
              ? searchJson['error']['message'].toString()
              : 'Unknown YouTube API error';
      print(
          'YouTube search failed (${searchResponse.statusCode}): $errorMessage');
    }
  } catch (e) {
    print('YouTube search request failed: $e');
  }

  List<String> videoIds = searchItems
      .map((item) => item['id']?['videoId'] as String?)
      .whereType<String>()
      .toList();

  // Fallback to curated IDs when search is blocked/quota-exhausted.
  if (videoIds.isEmpty) {
    videoIds = [
      'w-HYZv6HzAs', // Simon Sinek: Start with Why
      'mgmVOuLgFB0', // Angela Lee Duckworth: Grit
      'UNQhuFL6CWg', // Amy Cuddy: Body language
      'fLJsdqxnZb0', // Carol Dweck: Growth mindset
      'iCvmsMzlF7o', // Tim Urban: Procrastination
    ];
  }

  final videosUri = Uri.parse(
    'https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=${videoIds.join(',')}&key=$youtubeApiKey',
  );

  List<YoutubeVideoItem> listVideo = [];
  try {
    final videosResponse = await http.get(videosUri);
    final videosJson = jsonDecode(videosResponse.body) as Map<String, dynamic>;

    if (videosResponse.statusCode == 200) {
      listVideo = (videosJson['items'] as List? ?? [])
          .whereType<Map>()
          .map((item) {
            final snippet = item['snippet'] as Map<String, dynamic>? ?? {};
            final statistics = item['statistics'] as Map<String, dynamic>? ?? {};
            final id = item['id']?.toString() ?? '';
            final thumbnailUrl =
                snippet['thumbnails']?['high']?['url']?.toString() ??
                    snippet['thumbnails']?['medium']?['url']?.toString() ??
                    snippet['thumbnails']?['default']?['url']?.toString() ??
                    '';

            return YoutubeVideoItem(
              title: snippet['title']?.toString() ?? '',
              views: statistics['viewCount']?.toString() ?? '0',
              thumbnails: [YoutubeThumbnail(thumbnailUrl)],
              videoId: id,
            );
          })
          .where((video) =>
              video.title.isNotEmpty &&
              video.videoId.isNotEmpty &&
              video.thumbnails.first.url.isNotEmpty)
          .toList();
    } else {
      final errorMessage =
          (videosJson['error'] is Map && videosJson['error']['message'] != null)
              ? videosJson['error']['message'].toString()
              : 'Unknown YouTube API error';
      print('YouTube videos failed (${videosResponse.statusCode}): $errorMessage');
    }
  } catch (e) {
    print('YouTube videos request failed: $e');
  }

  if (listVideo.length == 0) print("null");
  return [filteredList, listVideo];
}

// Future<dynamic> fetchChatId(userinputs) async {
//   var url = Uri.parse('http://192.168.197.137:8000/getChatRoomID');
//   try {
//     print("Sending request...");
//     print(jsonEncode({"inputs": userinputs}));
//     var response = await http.post(
//       url,
//       headers: {
//         "content-type": "application/json",
//         "Access-Control-Allow-Origin": "*", // Required for CORS support to work
//         "Access-Control-Allow-Credentials":
//             'true', // Required for cookies, authorization headers with HTTPS
//         "Access-Control-Allow-Headers":
//             "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
//         "Access-Control-Allow-Methods": "GET, POST,OPTIONS"
//       },
//       body: jsonEncode({"inputs": userinputs}),
//     );
//     if (response.statusCode == 200) {
//       print("Data sent successfully");
//       print("Response from server: ${response.body}");
//       return jsonDecode(response.body);
//     } else {
//       print("Failed to send data. Status code: ${response.statusCode}");
//       print("Response body: ${response.body}");
//     }
//   } catch (e) {
//     print("Error sending data: $e");
//   }
// }
