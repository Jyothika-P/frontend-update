import 'package:flutter/material.dart';

// ignore: unused_import
import 'chat_bloc.dart';
import 'package:psychesail/model/botchatmessagemodel.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

class ChatSuccessState extends ChatState {
  final List<BotChatMessageModel> messages;

  ChatSuccessState({
    required this.messages,
  });
}
