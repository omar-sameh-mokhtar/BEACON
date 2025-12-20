class Message {
  final int? id;
  final String senderDeviceId;
  final String receiverDeviceId;
  final String messageType;
  final String content;
  final String timestamp;
  final int delivered; 

  Message({
    this.id,
    required this.senderDeviceId,
    required this.receiverDeviceId,
    required this.messageType,
    required this.content,
    required this.timestamp,
    required this.delivered,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'sender_device_id': senderDeviceId,
      'receiver_device_id': receiverDeviceId,
      'message_type': messageType,
      'content': content,
      'timestamp': timestamp,
      'delivered': delivered,
    };
  }

  factory Message.fromMap(Map<String, Object?> map) {
    return Message(
      id: map['id'] as int,
      senderDeviceId: map['sender_device_id'] as String,
      receiverDeviceId: map['receiver_device_id'] as String,
      messageType: map['message_type'] as String,
      content: map['content'] as String,
      timestamp: map['timestamp'] as String,
      delivered: map['delivered'] as int,
    );
  }

  @override
  String toString() {
    return 'Message{id: $id, senderDeviceId: $senderDeviceId, receiverDeviceId: $receiverDeviceId, '
        'messageType: $messageType, content: $content, timestamp: $timestamp, delivered: $delivered}';
  }
}
