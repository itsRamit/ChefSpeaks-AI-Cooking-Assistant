import 'package:chefspeaks/models/chat_model.dart';
import 'package:chefspeaks/services/api_service.dart';
import 'package:chefspeaks/utils/api_constants.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  Future<ChatMessage> chat(String userInput, String referenceText) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      path: ApiConstants.chat,
      body: {
        'userInput': userInput,
        'referenceText': referenceText,
      },
    );

    return ChatMessage.fromJson(response);
  }
}
