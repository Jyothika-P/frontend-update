import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:psychesail/bloc/chat_bloc.dart';
import 'package:psychesail/bloc/chat_state.dart';
import 'package:psychesail/components/sos_bottom_sheet.dart';
import 'package:psychesail/model/botchatmessagemodel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:psychesail/components/crud.dart';
import 'package:psychesail/components/text.dart';
import 'package:psychesail/model/supportcontactsmodel.dart';
import 'package:psychesail/model/emoji.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/button.dart';
import '../main.dart';

class MonkeyBotChatRoom extends StatefulWidget {
  MonkeyBotChatRoom({
    super.key,
  });

  @override
  State<MonkeyBotChatRoom> createState() => _MonkeyBotChatRoomState();
}

class _MonkeyBotChatRoomState extends State<MonkeyBotChatRoom> with RouteAware {
  final TextEditingController _messageController = TextEditingController();
  final ChatBloc chatbloc = ChatBloc();
  final SupportCircleRepo _supportCircleRepo = SupportCircleRepo();
  List<String> userinputs = [];
  List<List<String>> arr = [
    ["Parks", "assets/park.png"],
    ["Cafe", "assets/cafe.png"],
    ["Museums", "assets/museum.png"]
  ];
  var lastmessage;
  var receiverid;
  bool endchat = false;
  bool suggestplaces = false;
  var currentid;
  bool _isLoading = false;
  String? lastTextSpoken;
  var stressScore = '0';
  var obj = {};
  var url = '';
  bool _supportCallPromptArmed = false;
  bool _supportCallPopupOpen = false;
  FlutterTts flutterTts = FlutterTts();

  bool _looksDistressed(String text) {
    final normalized = text.toLowerCase();
    const distressKeywords = [
      'depressed',
      'alone',
      'lonely',
      'overwhelmed',
      'panic',
      'panicking',
      'nobody understands',
      'nobody gets me',
      'need someone',
      'need human',
      'can’t cope',
      "can't cope",
      'dont want to be alone',
      'do not want to be alone',
      'feel empty',
      'feel lost',
    ];

    return distressKeywords.any(normalized.contains);
  }

  bool _isNegativeAboutCalling(String text) {
    final normalized = text.toLowerCase().trim();
    const negativeSignals = [
      'no',
      'not now',
      'later',
      'maybe later',
      'dont',
      'do not',
      'not really',
      'leave it',
    ];

    return negativeSignals.any(normalized.contains);
  }

  bool _assistantOfferedSupport(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('support circle') ||
        normalized.contains('call or message someone') ||
        normalized.contains('reach out to someone') ||
        normalized.contains('trusted person');
  }

  Future<List<SupportContact>> _loadSupportContacts() async {
    final contacts = await _supportCircleRepo.getContacts(currentid).first;
    return contacts;
  }

  Future<void> _showCallPopup() async {
    final contacts = await _supportCircleRepo.getContacts(currentid).first;
    print("CURRENT USER ID = $currentid");
    print("CONTACTS FOUND = ${contacts.length}");
    await showSOSSheet(
      context,
      contacts,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    flutterTts.stop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    endchat = false;
    initializeTts();
  }

  Future<void> _fetchStressScore(List<String> userinputs) async {
    print("FETCH STRESS CALLED");
    // Select host depending on platform/emulator
    String host = '127.0.0.1';
    if (Platform.isAndroid) {
      // Android emulator (Android Studio) maps host machine's localhost to 10.0.2.2
      host = '10.0.2.2';
    }
    // Android emulators should use 10.0.2.2 to reach host machine
    try {
      // Debug print
      print("host is" + host);
      print(
          'Calling backend with inputs: ${jsonEncode({"inputs": userinputs})}');
      var url = Uri.parse('http://' + host + ':8000/process_data');
      var response = await http.post(
        url,
        headers: {
          "content-type": "application/json",
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": 'true',
          "Access-Control-Allow-Headers":
              "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
          "Access-Control-Allow-Methods": "GET, POST,OPTIONS"
        },
        body: jsonEncode({"inputs": userinputs}),
      );

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        var decode_score = jsonDecode(response.body);
        var stress_score = decode_score["average_stress"].toString();
        print('Decoded stress: $stress_score');
        setState(() {
          stressScore = stress_score;
        });
        final score = double.tryParse(stress_score) ?? 0;

        if (score >= 8) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showSupportSuggestion();
            }
          });
        }
        addStressValue(currentid, stressScore);
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  void initializeTts() {
    flutterTts.setStartHandler(() {
      print("TTS playback started");
    });
    flutterTts.setCompletionHandler(() {
      print("TTS playback finished");
    });
    flutterTts.setErrorHandler((msg) {
      print("TTS playback error: $msg");
    });
  }

  Future<void> textToSpeech(String text, String lastMessage) async {
    print("SPEAKING");
    var lang = await flutterTts.getVoices;
    print(lang);
    lastTextSpoken = text;
    await flutterTts.setVoice({"name": "en-AU-language", "locale": "en-AU"});
    await flutterTts.setPitch(0.8);
    await flutterTts.speak(text);
  }

  Future<void> _showSupportSuggestion() async {
    if (_supportCallPopupOpen) return;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Need Support?"),
          content: Text(
            "It sounds like you're having a difficult time. Would you like to contact someone from your Support Circle?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Not Now"),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);

                await _showCallPopup();
              },
              child: Text("Contact Someone"),
            ),
          ],
        );
      },
    );
  }

  bool _isPositiveAboutCalling(String text) {
    final normalized = text.toLowerCase().trim();

    const positiveSignals = [
      'yes',
      'yeah',
      'yep',
      'sure',
      'ok',
      'okay',
      'please',
      'call',
      'message',
      'text them',
      'do it',
      'lets call',
      'i want to call',
      'i want to message',
    ];

    return positiveSignals.any(
      (signal) => normalized.contains(signal),
    );
  }

  // dynamic sendMessage(messages, String userText) async {
  //   print("MESSAGE CONTROLLER = ${_messageController.text}");
  //   print("Entered send messages");
  //   if (_messageController.text.isNotEmpty) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     setState(() {
  //       userinputs.add(userText);
  //     });
  //     print(userinputs);
  //     var inputMessage = userText;
  //     _messageController.clear();

  //     if (_supportCallPromptArmed) {
  //       if (_isPositiveAboutCalling(userText)) {
  //         _supportCallPromptArmed = false;
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           _showCallPopup();
  //         });
  //       } else if (_isNegativeAboutCalling(userText)) {
  //         _supportCallPromptArmed = false;
  //       }
  //     }

  //     await sendmessage(receiverid, inputMessage, currentid);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     updateChat(currentid, receiverid,
  //         messages[messages.length - 1].parts.first.text);

  //     if (_looksDistressed(userText)) {
  //       print("DISTRESS DETECTED");
  //       await _showCallPopup();
  //       // showDialog(
  //       //   context: context,
  //       //   builder: (_) {
  //       //     return AlertDialog(
  //       //       title: Text("TEST"),
  //       //       content: Text("Distress detected"),
  //       //     );
  //       //   },
  //       // );
  //       // WidgetsBinding.instance.addPostFrameCallback((_) {
  //       //   if (mounted) {
  //       //     _showSupportSuggestion();
  //       //   }
  //       // });
  //     }

  //     if (_assistantOfferedSupport(
  //         messages[messages.length - 1].parts.first.text)) {
  //       _supportCallPromptArmed = true;
  //     }

  //     return;
  //   }
  //   return;
  // }

  dynamic sendMessage(messages, String userText) async {
    print("Entered send messages");
    print("USER TEXT = $userText");

    if (userText.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    userinputs.add(userText);

    print(userinputs);

    final inputMessage = userText;

    if (_supportCallPromptArmed) {
      if (_isPositiveAboutCalling(userText)) {
        _supportCallPromptArmed = false;

        if (mounted) {
          await _showCallPopup();
        }

        return;
      } else if (_isNegativeAboutCalling(userText)) {
        _supportCallPromptArmed = false;
      }
    }

    await sendmessage(
      receiverid,
      inputMessage,
      currentid,
    );

    setState(() {
      _isLoading = false;
    });

    if (messages.isNotEmpty) {
      updateChat(
        currentid,
        receiverid,
        messages.last.parts.first.text,
      );
    }

    if (_looksDistressed(userText)) {
      print("DISTRESS DETECTED");

      if (mounted) {
        await _showCallPopup();
      }
    }

    if (messages.isNotEmpty &&
        _assistantOfferedSupport(
          messages.last.parts.first.text,
        )) {
      _supportCallPromptArmed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final size = MediaQuery.of(context).size;
    double sizeHeight = MediaQuery.of(context).size.height;
    double sizeWidth = MediaQuery.of(context).size.width;
    // Access individual parameters
    lastmessage = args?['lastmessage'] ?? '';
    receiverid = 'Serenity';
    currentid = args?['currentid'] ?? '';
    obj = args?['obj'] ?? {};
    url = args?['url'] ?? '';
    print(receiverid);
    print(lastmessage);
    print(currentid);

    if (_assistantOfferedSupport(lastmessage)) {
      _supportCallPromptArmed = true;
    }

    // Future<void> _fetchStressScore(userinputs) async {
    //   var url = Uri.parse('http://127.0.0.1:8000/process_data');
    //   try {
    //     print("Sending request...");
    //     print(jsonEncode({"inputs": userinputs}));
    //     var response = await http.post(
    //       url,
    //       headers: {
    //         "content-type": "application/json",
    //         "Access-Control-Allow-Origin":
    //             "*", // Required for CORS support to work
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

    //       var decode_score = jsonDecode(response.body);
    //       var stress_score = decode_score["average_stress"].toString();
    //       print(stress_score);
    //       setState(() {
    //         stressScore = stress_score;
    //       });

    //       // update in customers
    //       addStressValue(currentid, stressScore);
    //     } else {
    //       print("Failed to send data. Status code: ${response.statusCode}");
    //       print("Response body: ${response.body}");
    //     }
    //   } catch (e) {
    //     print("Error sending data: $e");
    //   }
    // }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          title: Center(child: Text(receiverid)),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: size.width / 50),
                child: IconButton(
                    onPressed: () async {
                      await textToSpeech(
                          "CALLING SERENITY", "CALLING SERENITY");
                    },
                    icon: Icon(Icons.call),
                    color: Colors.white))
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/chat_background_1.jpeg"),
                  fit: BoxFit.cover,
                  opacity: 0.92)),
          child: BlocConsumer<ChatBloc, ChatState>(
              bloc: chatbloc,
              listener: (context, state) async {},
              builder: (context, state) {
                List<BotChatMessageModel> messages = chatbloc.messages;

                switch (messages.isNotEmpty) {
                  case true:
                    return Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Container(
                              color: Colors.grey.shade400,
                              height: sizeHeight / 20,
                              child: Center(
                                  child: Text(
                                "Single tap response : Pause",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'AbeeZee',
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic),
                              ))),
                          Expanded(
                            child: ListView.builder(
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  return !(index % 8 == 7)
                                      ? Row(
                                          mainAxisAlignment:
                                              (messages[index].role == "user")
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: InkWell(
                                                onTap: () async {
                                                  print(
                                                      "Pressed Pause- Single");
                                                  await flutterTts.stop();
                                                },
                                                child: Container(
                                                  margin: (messages[index]
                                                              .role ==
                                                          "user")
                                                      ? EdgeInsets.only(
                                                          top: min(12,
                                                              sizeWidth * 0.05),
                                                          bottom: min(12,
                                                              sizeWidth * 0.05),
                                                          right: min(
                                                              sizeHeight * 0.05,
                                                              12),
                                                          left:
                                                              sizeHeight * 0.05,
                                                        )
                                                      : EdgeInsets.only(
                                                          top: min(12,
                                                              sizeWidth * 0.05),
                                                          bottom: min(12,
                                                              sizeWidth * 0.05),
                                                          left: min(
                                                              sizeHeight * 0.05,
                                                              12),
                                                          right:
                                                              sizeHeight * 0.05,
                                                        ),
                                                  padding: EdgeInsets.all(12.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius: (messages[
                                                                    index]
                                                                .role ==
                                                            "user")
                                                        ? BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    12),
                                                            topRight:
                                                                Radius.circular(
                                                                    20),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    12),
                                                          )
                                                        : BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                            topRight:
                                                                Radius.circular(
                                                                    12),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    12),
                                                          ),
                                                    color: (messages[index]
                                                                .role ==
                                                            "user")
                                                        ? Color.fromRGBO(
                                                            32, 160, 144, 100)
                                                        : Colors.grey,
                                                    border: Border.all(
                                                        color: Colors.black),
                                                  ),
                                                  child: Text(
                                                    messages[index]
                                                        .parts
                                                        .first
                                                        .text,
                                                    style: TextStyle(
                                                      color: (messages[index]
                                                                  .role ==
                                                              "user")
                                                          ? Colors.grey[700]
                                                          : Colors.black,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  (messages[index].role ==
                                                          "user")
                                                      ? MainAxisAlignment.end
                                                      : MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    margin: (messages[index]
                                                                .role ==
                                                            "user")
                                                        ? EdgeInsets.only(
                                                            top: min(
                                                                12,
                                                                sizeWidth *
                                                                    0.05),
                                                            bottom: min(
                                                                12,
                                                                sizeWidth *
                                                                    0.05),
                                                            right: min(
                                                                sizeHeight *
                                                                    0.05,
                                                                12),
                                                            left: sizeHeight *
                                                                0.05,
                                                          )
                                                        : EdgeInsets.only(
                                                            top: min(
                                                                12,
                                                                sizeWidth *
                                                                    0.05),
                                                            bottom: min(
                                                                12,
                                                                sizeWidth *
                                                                    0.05),
                                                            left: min(
                                                                sizeHeight *
                                                                    0.05,
                                                                12),
                                                            right: sizeHeight *
                                                                0.05,
                                                          ),
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: (messages[
                                                                      index]
                                                                  .role ==
                                                              "user")
                                                          ? BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(12),
                                                              topRight: Radius
                                                                  .circular(20),
                                                              bottomLeft: Radius
                                                                  .circular(12),
                                                            )
                                                          : BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(20),
                                                              topRight: Radius
                                                                  .circular(12),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                      color: (messages[index]
                                                                  .role ==
                                                              "user")
                                                          ? Color.fromRGBO(
                                                              32, 160, 144, 100)
                                                          : Colors.grey,
                                                      border: Border.all(
                                                          color: Colors.black),
                                                    ),
                                                    child: Text(
                                                      messages[index]
                                                          .parts
                                                          .first
                                                          .text,
                                                      style: TextStyle(
                                                        color: (messages[index]
                                                                    .role ==
                                                                "user")
                                                            ? Colors.grey[700]
                                                            : Colors.black,
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                      top: min(
                                                          12, sizeWidth * 0.05),
                                                      bottom: min(
                                                          12, sizeWidth * 0.05),
                                                      left: min(
                                                          sizeHeight * 0.05,
                                                          12),
                                                      right: sizeHeight * 0.05,
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(12),
                                                        bottomRight:
                                                            Radius.circular(12),
                                                      ),
                                                      color: Colors.grey,
                                                      border: Border.all(
                                                          color: Colors.black),
                                                    ),
                                                    child: Text(
                                                      "Looks like the best way for you to refresh yourself might be some outdoor activities. Here are some suggested activities near you - ",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: min(
                                                      sizeHeight * 0.05, 12),
                                                  vertical: min(
                                                      sizeWidth * 0.05, 12)),
                                              child: activitymaps(sizeWidth,
                                                  sizeHeight, true, obj, url,
                                                  bordercolor: Colors.black),
                                            ),
                                            (!endchat || !suggestplaces)
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          print("hello");
                                                          print(userinputs);
                                                          print(jsonEncode({
                                                            "inputs": userinputs
                                                          }));
                                                          print(
                                                              "END CHAT CLICKED");
                                                          print(userinputs);

                                                          print(
                                                              "FETCH COMPLETE");

                                                          await _fetchStressScore(
                                                              userinputs);
                                                          print(
                                                              "Stress Score FETCH COMPLETE");
                                                          print(
                                                              "after sending and fetching response");
                                                          setState(() {
                                                            endchat = true;
                                                          });
                                                        },
                                                        child: (!endchat &&
                                                                !suggestplaces)
                                                            ? Container(
                                                                width:
                                                                    sizeWidth /
                                                                        3,
                                                                height:
                                                                    sizeHeight /
                                                                        25,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                child: Center(
                                                                    child: Text(
                                                                        "End chat")),
                                                              )
                                                            : (endchat)
                                                                ? Container(
                                                                    width:
                                                                        sizeWidth,
                                                                    height:
                                                                        sizeHeight /
                                                                            25,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .transparent,
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                            "CHAT ENDED",
                                                                            style:
                                                                                TextStyle(color: Colors.black))),
                                                                  )
                                                                : SizedBox(),
                                                      ),
                                                      InkWell(
                                                        onTap: () => {
                                                          setState(() {
                                                            suggestplaces =
                                                                true;
                                                          }),
                                                        },
                                                        child: (!suggestplaces &&
                                                                !endchat)
                                                            ? Container(
                                                                width:
                                                                    sizeWidth /
                                                                        3,
                                                                height:
                                                                    sizeHeight /
                                                                        25,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                child: Center(
                                                                    child: Text(
                                                                        "Suggest Places")),
                                                              )
                                                            : (suggestplaces)
                                                                ? Container(
                                                                    width:
                                                                        sizeWidth,
                                                                    height:
                                                                        sizeHeight /
                                                                            25,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border(
                                                                        top:
                                                                            BorderSide(
                                                                          color:
                                                                              Colors.black38, // Color of the top border
                                                                          width:
                                                                              1.5, // Width of the top border
                                                                        ),
                                                                      ),
                                                                      color: Colors
                                                                          .transparent,
                                                                    ),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "CHAT ENDED ... SUGGESTING PLACES",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black),
                                                                    )),
                                                                  )
                                                                : SizedBox(),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                          ],
                                        );
                                }),
                          ),
                          if (suggestplaces)
                            Row(
                              children: [
                                Wrap(
                                  spacing: 20,
                                  runSpacing: min(20, sizeWidth * 0.0006),
                                  children: [
                                    SizedBox(
                                      height: sizeHeight * 0.01,
                                    ),
                                    SizedBox(
                                      height: sizeHeight * 0.15,
                                      child: ListView.separated(
                                        reverse: false,
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: arr.length,
                                        itemBuilder: (context, index) {
                                          return _suggestplaces(
                                              sizeHeight,
                                              sizeWidth,
                                              arr[arr.length - 1 - index][0],
                                              arr[arr.length - 1 - index][1],
                                              true);
                                        },
                                        separatorBuilder: ((context, index) =>
                                            SizedBox(
                                              width: min(sizeWidth * 0.05, 30),
                                            )),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          if (endchat)
                            _endchat(stressScore, sizeWidth, sizeHeight,
                                currentid, context, messages),
                          (!endchat && !suggestplaces)
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 10),
                                  height: 120,
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      _chatField(_messageController),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (_messageController
                                              .text.isNotEmpty) {
                                            print(_messageController.text);
                                            var userInput =
                                                _messageController.text;
                                            _messageController.clear();
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            print(
                                                ChatGenerateNewTextMessageEvent(
                                                    inputMessage: userInput));
                                            print(await chatbloc
                                                .chatGenerateNewTextMessageEvent(
                                                    ChatGenerateNewTextMessageEvent(
                                                        inputMessage:
                                                            userInput)));
                                            setState(() {
                                              _isLoading = false;
                                              userinputs.add(userInput);
                                            });

                                            await sendMessage(
                                                messages, userInput);
                                            await textToSpeech(
                                                messages[messages.length - 1]
                                                    .parts
                                                    .first
                                                    .text,
                                                messages[messages.length - 1]
                                                    .parts
                                                    .first
                                                    .text);
                                            print(userinputs);
                                          }
                                        },
                                        child: ((!endchat))
                                            ? (_isLoading)
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            color:
                                                                Colors.black),
                                                  )
                                                : CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Color.fromRGBO(
                                                            32, 160, 144, 100),
                                                    child: Icon(
                                                      Icons.send,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                            : _endchat(
                                                stressScore,
                                                sizeWidth,
                                                sizeHeight,
                                                currentid,
                                                context,
                                                messages),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    );
                  default:
                    return Column(children: [
                      Container(
                          color: Colors.grey.shade400,
                          height: sizeHeight / 20,
                          child: Center(
                              child: Text(
                            "Single tap response : Pause, Double Tap response : Play",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'AbeeZee',
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          ))),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 9),
                        height: sizeHeight / 4,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () => {
                                    _messageController.text =
                                        "I don't feel well"
                                  },
                                  child: Container(
                                    width: sizeWidth / 3,
                                    height: sizeHeight / 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey,
                                    ),
                                    child: Center(
                                        child: Text("I don't feel well")),
                                  ),
                                ),
                                InkWell(
                                    onTap: () => {
                                          _messageController.text =
                                              "Help me! I am stressed!"
                                        },
                                    child: Container(
                                      width: sizeWidth / 2,
                                      height: sizeHeight / 25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey,
                                      ),
                                      child: Center(
                                          child:
                                              Text("Help me! I am stressed!")),
                                    ))
                              ],
                            ),
                            (!endchat && !suggestplaces)
                                ? Row(
                                    children: [
                                      _chatField(_messageController),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (_messageController
                                              .text.isNotEmpty) {
                                            print(_messageController.text);
                                            var userInput =
                                                _messageController.text;
                                            _messageController.clear();
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            print(
                                                ChatGenerateNewTextMessageEvent(
                                                    inputMessage: userInput));
                                            print(await chatbloc
                                                .chatGenerateNewTextMessageEvent(
                                                    ChatGenerateNewTextMessageEvent(
                                                        inputMessage:
                                                            userInput)));
                                            // print(chatbloc.messages.length);
                                            setState(() {
                                              _isLoading = false;
                                            });
                                            await sendMessage(
                                                messages, userInput);
                                            await textToSpeech(
                                                messages[messages.length - 1]
                                                    .parts
                                                    .first
                                                    .text,
                                                messages[messages.length - 1]
                                                    .parts
                                                    .first
                                                    .text);
                                            // _messageController.clear();
                                          }
                                        },
                                        child: (_isLoading)
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.black),
                                              )
                                            : CircleAvatar(
                                                radius: 31,
                                                backgroundColor: Color.fromRGBO(
                                                    32, 160, 144, 100),
                                                child: Icon(
                                                  Icons.send,
                                                  color: Colors.black,
                                                ),
                                              ),
                                      ),
                                    ],
                                  )
                                : _endchat(stressScore, sizeWidth, sizeHeight,
                                    currentid, context, messages),
                          ],
                        ),
                      )
                    ]);
                }
              }),
        ));
  }

//   // build message input
//   Widget _buildMessageInput(messages) {
//     return Row(
//       children: [
//         //textfield
//         Expanded(
//           child: MyTextField(
//             controller: _messageController,
//             hinttext: 'Enter message...',
//             obscureText: false,
//           ),
//         ),
//
//         // send button
//         InkWell(
//             onTap: () async {
//               print(ChatSuccessState(messages: messages).toString());
//               if (_messageController.text.isNotEmpty) {
//                 var userInput = _messageController.text;
//                 _messageController.clear();
//                 chatbloc.add(ChatGenerateNewTextMessageEvent(
//                     inputMessage: userInput));
//
//
//               }
//             },
//             child: CircleAvatar(
//               radius: 32,
//               backgroundColor: Colors.transparent,
//               child: Icon(
//                 Icons.send,
//                 color: Colors.black,
//               ),
//             ))
//       ],
//     );
//   }
}

// Widget _buildMessageList(receiverid, currentid) {
//   return StreamBuilder(
//       stream: getmessages(receiverid, currentid),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error${snapshot.error}');
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Text('Loading...');
//         }
//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             // Build your message widget based on the data
//             return _buildMessageItem(snapshot.data!.docs[index], currentid);
//           },
//           // children: snapshot.data!.docs.map((document) => _buildMessageItem(document,currentid)).toList(),
//         );
//       });
// }

Widget _endchat(
    stressScore, sizeWidth, sizeHeight, currentid, context, messages) {
  Emoji stressEmoji = Emoji();
  var displayMood = (stressScore == '0')
      ? ['assets/stress_5.png', 'Therapist needed', Colors.red]
      : stressEmoji.stressEmoji(stressScore);
  // await addStressHistory(currentid, {
  //   "stressScore": stressScore, // Assuming stressScore is a variable holding the score
  //   "timestamp": FieldValue.serverTimestamp() // This will get the current timestamp from the server
  // });
  return (stressScore == '0')
      ? Container(
          height: sizeHeight * 0.15,
          child: Center(
            child: Text(
              "Calculating stress ....",
              style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'AbeeZee'),
            ),
          ))
      : Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 5,
              ),
              height: sizeHeight / 8,
              // color: displayMood[2],
              decoration: BoxDecoration(
                color: displayMood[2], // Assuming displayMood[2] is a Color
                // Define the border for the top side of the Container
                border: Border(
                  top: BorderSide(
                    color: Colors.black38, // Color of the top border
                    width: 1.5, // Width of the top border
                  ),
                  bottom: BorderSide(
                    color: Colors.black38, // Color of the top border
                    width: 1.5, // Width of the top border
                  ),
                ),
              ),
              // decoration: BoxDecoration(
              //   border: Border(top:BorderSide(color: Colors.black, width: 2.0)),
              // ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: sizeWidth / 8,
                            right: sizeWidth / 15,
                            top: sizeHeight / 90,
                            bottom: sizeHeight / 140),
                        child: circleButton(false, sizeWidth / 100,
                            sizeWidth / 50, displayMood[0].toString()),
                      ),
                      Text(
                        "\"" + displayMood[1] + "\"",
                        style: TextStyle(
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                            fontFamily: 'AbeeZee'),
                      ),
                    ],
                  ),
                  Text(
                    "Your Final Stress Score Is : " + stressScore,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'AbeeZee',
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            )
          ],
        );
}

Widget _chatField(_messageController) {
  return Expanded(
    child: Theme(
      data: ThemeData(
        // Set the border color for TextField
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide:
                BorderSide(color: Colors.black), // Set border color here
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(
                color: Colors.black), // Set focused border color here
          ),
        ),
      ),
      child: TextField(
        cursorColor: Colors.black,
        style: TextStyle(
          color: Colors.black,
        ),
        controller: _messageController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(32, 160, 144, 100).withOpacity(0.3),
        ),
      ),
    ),
  );
}

Widget _suggestplaces(sizeHeight, sizeWidth, heading, imagestring, constr) {
  return Container(
    constraints: BoxConstraints(maxWidth: sizeWidth * 0.5),
    decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0))),
    child: Padding(
      padding: EdgeInsets.all(sizeHeight * sizeWidth * 0.00009),
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
  );
}
