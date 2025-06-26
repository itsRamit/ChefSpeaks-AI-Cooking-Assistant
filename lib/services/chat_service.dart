import 'package:chefspeaks/models/chat_model.dart';
import 'package:chefspeaks/services/api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  Future<ChatMessage> chat(String userInput, String referenceText) async {
    final response = await _apiService.post(
      baseUrl: '192.168.76.11:3000',
      path: '/api/chat',
      body: {
        'userInput': userInput,
        'referenceText': referenceText,
      },
    );

    return ChatMessage.fromJson(response);
  }
}
