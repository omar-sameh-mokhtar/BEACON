class UserProfile {
  final int id;
  final String deviceId;
  final String name;
  final String phone;
  final String bloodType;
  final String createdAt;
  final String updatedAt;
  final String imagePath;

  UserProfile({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.phone,
    required this.bloodType,
    required this.createdAt,
    required this.updatedAt,
    required this.imagePath,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'device_id': deviceId,
    'name': name,
    'phone': phone,
    'blood_type': bloodType,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'image_path': imagePath,
  };

  UserProfile? copyWith({required String name1, required String phone, required String bloodType, required String updatedAt}) {
    return UserProfile(
      id: id,
      deviceId: deviceId,
      name: name1,
      phone: phone,
      bloodType: bloodType,
      createdAt: createdAt,
      updatedAt: updatedAt,
      imagePath: imagePath
    );
  }



}

