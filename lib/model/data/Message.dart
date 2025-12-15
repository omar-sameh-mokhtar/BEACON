class Message {
  final int id;
  final String senderDeviceId;
  final String messageType;
  final String content;
  final String timestamp;
  final int delivered; 

  Message({
    required this.id,
    required this.senderDeviceId,
    required this.messageType,
    required this.content,
    required this.timestamp,
    required this.delivered,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'sender_device_id': senderDeviceId,
      'message_type': messageType,
      'content': content,
      'timestamp': timestamp,
      'delivered': delivered,
    };
  }

  @override
  String toString() {
    return 'Message{id: $id, senderDeviceId: $senderDeviceId, '
        'messageType: $messageType, content: $content, timestamp: $timestamp, delivered: $delivered}';
  }
}
