class ChatMessage {
  final String status;
  final String response;

  ChatMessage({required this.status, required this.response});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      status: json['status'] ?? 'error',
      response: json['response'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'response': response,
    };
  }
}
