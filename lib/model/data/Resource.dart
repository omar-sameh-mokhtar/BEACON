
class Resource {
  final int id;
  final String resourceType;
  final int quantity;
  final String note;
  final String requesterId;
  final String owner;
  final String status;
  final bool isRequested;
  final bool isMine;
  final String timestamp;

  Resource({
    required this.id,
    required this.resourceType,
    required this.quantity,
    required this.note,
    required this.requesterId,
    required this.owner,
    required this.status,
    required this.isRequested,
    required this.isMine,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'resource_type': resourceType,
      'quantity': quantity,
      'note': note,
      'requester_id': requesterId,
      'owner': owner,
      'status': status,
      'is_requested': isRequested ? 1 : 0,
      'is_mine': isMine ? 1 : 0,
      'timestamp': timestamp,
    };
  }

  factory Resource.fromMap(Map<String, Object?> map) {
    return Resource(
      id: map['id'] as int,
      resourceType: map['resource_type'] as String,
      quantity: map['quantity'] as int,
      note: map['note'] as String,
      requesterId: map['requester_id'] as String,
      owner: map['owner'] as String,
      status: map['status'] as String,
      isRequested: (map['is_requested'] as int) == 1,
      isMine: (map['is_mine'] as int) == 1,
      timestamp: map['timestamp'] as String,
    );
  }

  Resource copyWith({
    int? quantity,
    String? note,
    String? status,
    bool? isRequested,
  }) {
    return Resource(
      id: id,
      resourceType: resourceType,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      requesterId: requesterId,
      owner: owner,
      status: status ?? this.status,
      isRequested: isRequested ?? this.isRequested,
      isMine: isMine,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'resourceType': resourceType,
    'quantity': quantity,
    'note': note,
    'requesterId': requesterId,
    'owner': owner,
    'status': status,
    'isRequested': isRequested,
  };


  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
    id: json['id'],
    resourceType: json['resourceType'],
    quantity: json['quantity'],
    note: json['note'],
    requesterId: json['requesterId'],
    owner: json['owner'],
    status: json['status'],
    isRequested: json['isRequested'], isMine: false, timestamp: '',
  );



}
