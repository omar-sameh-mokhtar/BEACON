class UserProfile {
  final int id;
  final String deviceId;
  final String name;
  final String phone;
  final String bloodType;
  //final String emergencyContactName;
  //final String emergencyContactPhone;
  final String createdAt;
  final String updatedAt;
  final String imagePath;

  UserProfile({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.phone,
    required this.bloodType,
    //required this.emergencyContactName,
    //required this.emergencyContactPhone,
    required this.createdAt,
    required this.updatedAt,
    required this.imagePath,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'name': name,
      'phone': phone,
      'blood_type': bloodType,
      //additional info???
      //'emergency_contact_name': emergencyContactName,
      //'emergency_contact_phone': emergencyContactPhone,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_path': imagePath,
    };
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, deviceId: $deviceId, name: $name, phone: $phone, '
        'bloodType: $bloodType, '
        //'emergencyContactName: $emergencyContactName, '
        //'emergencyContactPhone: $emergencyContactPhone, '
        'createdAt: $createdAt, updatedAt: $updatedAt}'
        'imagePath: $imagePath}';
  }
}
