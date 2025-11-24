import 'package:flutter/foundation.dart';
import 'package:playground/models/meeting.dart';
import 'package:playground/services/api_service.dart';

class ChatService extends ChangeNotifier {
  final int userId;

  final _apiService = ApiService();

  List<ChatRoom> _chatRooms = [];

  List<ChatRoom> get chatRooms => _chatRooms;

  ChatService({required this.userId});

  Future<void> refreshChatRooms() async {
    _apiService.getChatRooms(userId).then((rooms) {
      _chatRooms = rooms
          .map((it) => _apiService.chatRoomReadToChatRoom(it))
          .toList();

      _chatRooms.sort(
        (ChatRoom a, ChatRoom b) =>
            b.lastMessageTime.compareTo(a.lastMessageTime),
      );
    });

    notifyListeners();
  }
}
