import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:psychesail/bloc/chat_bloc.dart';
import 'package:psychesail/bloc/chat_state.dart';
import 'package:psychesail/components/api.dart';
import 'package:psychesail/model/botchatmessagemodel.dart';
import 'package:psychesail/model/places.dart';
import 'package:psychesail/model/textField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:psychesail/components/crud.dart';
import 'package:psychesail/components/text.dart';
import 'package:psychesail/model/message.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:psychesail/model/emoji.dart';

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
  List<String> userinputs = [];
  List<List<String>> arr = [
    ["Movies", "assets/movie.png"],
    ["Games", "assets/games.png"],
    ["Cafe", "assets/cafe.png"]
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
  FlutterTts flutterTts = FlutterTts();
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

    Future<void> _fetchStressScore(userinputs) async {
      var url = Uri.parse('http://192.168.197.137:8000/process_data');
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

          var decode_score = jsonDecode(response.body);
          var stress_score = decode_score["Final Stress Level"];
          print(stress_score);
          setState(() {
            stressScore = stress_score;
          });

          // update in customers
          addStressValue(currentid, stressScore);
        } else {
          print("Failed to send data. Status code: ${response.statusCode}");
          print("Response body: ${response.body}");
        }
      } catch (e) {
        print("Error sending data: $e");
      }
    }

    dynamic sendMessage(messages) async {
      print("Entered send messages");
      if (_messageController.text.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });
        setState(() {
          userinputs.add(_messageController.text);
        });
        print(userinputs);
        var inputMessage = _messageController.text;
        _messageController.clear();
        await sendmessage(receiverid, inputMessage, currentid);
        setState(() {
          _isLoading = false;
        });
        updateChat(currentid, receiverid,
            messages[messages.length - 1].parts.first.text);
        return;
      }
      return;
    }

    // print(hello)

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
                                                          ? Colors.white
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
                                                            ? Colors.white
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
                                                          setState(() {
                                                            endchat = true;
                                                          });
                                                          print(jsonEncode({
                                                            "inputs": userinputs
                                                          }));
                                                          await _fetchStressScore(
                                                              userinputs);
                                                          print(
                                                              "after sending and fetching response");
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

                                            await sendMessage(messages);
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
                                            await sendMessage(messages);
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

Widget _buildMessageItem(DocumentSnapshot document, currentid) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  // align sender messages => left ; receiver messages => right

  var alignment = (data['senderid'] == currentid)
      ? Alignment.centerRight
      : Alignment.centerLeft;
  var bgcolor = (data['senderid'] == currentid)
      ? Color.fromRGBO(32, 160, 144, 100)
      : Color.fromRGBO(121, 124, 123, 100);
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    bool constr = false;
    if (constraints.maxWidth > 600) constr = true;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: (data['senderid'] == currentid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderid'] == currentid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // Text(data['senderid'],style: const TextStyle(backgroundColor: Colors.transparent,color: Colors.black,fontSize: 15,),),
          textbubble(
              data['message'],
              '${data['timestamp'].toDate().toLocal().hour}:' +
                  '${data['timestamp'].toDate().toLocal().minute.toString().padLeft(2, '0')}',
              data['senderid'],
              currentid,
              bgcolor,
              constr,
              context),
        ],
      ),
    );
  });
}

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
            ),
            SizedBox(
              width: sizeWidth,
              height: sizeHeight / 20,
              child: Container(
                color: Colors.black,
                child: InkWell(
                  onTap: () async {
                    var chatid = await fetchChatId(messages);
                    Navigator.pushNamed(context, '/chatroom', arguments: {
                      'currentuser': currentid,
                      'receiverid': 'Disha',
                      'communityname': 'community',
                      'name': 'Stress $stressScore',
                      'chatId': chatid
                    });
                  },
                  child: Center(
                    child: Text(
                      "Connect & Heal: Join Tailored Stress-Matched Circle",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'AbeeZee',
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
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
