class ResourceRequest {
  final int id;
  final String resourceType;
  final int quantity;
  final String note;
  final String requesterId;
  final String status; // open, assigned, closed
  final String timestamp;

  ResourceRequest({
    required this.id,
    required this.resourceType,
    required this.quantity,
    required this.note,
    required this.requesterId,
    required this.status,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'resource_type': resourceType,
      'quantity': quantity,
      'note': note,
      'requester_id': requesterId,
      'status': status,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'ResourceRequest{id: $id, resourceType: $resourceType, quantity: $quantity, '
        'note: $note, requesterId: $requesterId, status: $status, '
        'timestamp: $timestamp}';
  }
}
