import 'dart:async';

import 'package:bloc/bloc.dart';
// import 'package:psychesail/bloc/chat_event.dart';
import 'package:psychesail/bloc/chat_state.dart';
// import 'package:psychesail/bloc/chat_event.dart';
// import 'package:psychesail/bloc/chat_event.dart';
import 'package:psychesail/model/botchatmessagemodel.dart';
import 'package:meta/meta.dart';
import 'package:psychesail/repo/chatrepo.dart';
part 'chat_event.dart';
// part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatSuccessState(messages: [])) {
    on<ChatGenerateNewTextMessageEvent>(chatGenerateNewTextMessageEvent) {}
  }

  List<BotChatMessageModel> messages = [];
  FutureOr<dynamic> prompting(prompt) async {
    messages.add(BotChatMessageModel(
        role: "user", parts: [ChatPartModel(text: prompt)]));
    var generatedText = await ChatRepo.chatTextGenerationRepo(messages);
    if ((generatedText ?? '').isNotEmpty) {
      messages.add(BotChatMessageModel(
          role: 'model', parts: [ChatPartModel(text: generatedText!)]));
    }
    print(generatedText);
    return;
  }

  FutureOr<dynamic> chatGenerateNewTextMessageEvent(
      ChatGenerateNewTextMessageEvent event) async {
    // await prompting("You are an AI therapist designed to act as a supportive chatbot for a student struggling with academic stress. Your role is to provide empathetic support and motivation to help the student overcome their challenges. Initiate the conversation by asking the student how they're feeling and what's been on their mind lately. Listen carefully to their response, acknowledging their feelings and reassuring them that they're not alone in their struggles. Once they've expressed their concerns, offer a brief motivational message or quote to uplift their spirits. For example, you could say, 'Remember, every successful person has faced setbacks. It's how we respond to them that matters most.' Encourage the student to focus on their strengths and past achievements, reminding them of their capabilities. Keep the conversation light and positive, gently guiding the student towards a more optimistic outlook on their academic journey. Your goal is to provide comfort and encouragement through brief, supportive interactions, helping the student build confidence and resilience over time.");
    // await prompting("can you act like a therapist and talk to the future messages like a therapist. Dont hallucinate, Dont be creative. just act like a helping person and keep the responses short and sweet and helping the person. dont give a dialogue of therapist and future messages. you have to remember you are a therapist and respond to t");
    messages.add(BotChatMessageModel(
        role: "user", parts: [ChatPartModel(text: event.inputMessage)]));

    emit(ChatSuccessState(messages: messages));
    var generatedText = await ChatRepo.chatTextGenerationRepo(messages);
    if ((generatedText ?? '').isNotEmpty) {
      messages.add(BotChatMessageModel(
          role: 'model', parts: [ChatPartModel(text: generatedText!)]));
    }
    return (messages);
  }
}
// ignore: invalid_use_of_visible_for_testing_member
