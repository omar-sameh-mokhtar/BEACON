import 'package:flutter_test/flutter_test.dart';
import 'package:beacon/model/data/UserProfile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('UserProfile object is created correctly', () {
      final profile = UserProfile(
        id: 1,
        deviceId: 'device-123',
        name: 'Ahmed',
        phone: '01000000000',
        bloodType: 'A+',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-01',
        imagePath: '',
      );

      expect(profile.id, 1);
      expect(profile.deviceId, 'device-123');
      expect(profile.name, 'Ahmed');
      expect(profile.phone, '01000000000');
      expect(profile.bloodType, 'A+');
      expect(profile.imagePath, '');
    });

    test('UserProfile.toMap returns correct map structure', () {
      final profile = UserProfile(
        id: 2,
        deviceId: 'device-456',
        name: 'Omar',
        phone: '01111111111',
        bloodType: 'O-',
        createdAt: '2024-02-01',
        updatedAt: '2024-02-02',
        imagePath: '/path/image.png',
      );

      final map = profile.toMap();

      expect(map['id'], 2);
      expect(map['device_id'], 'device-456');
      expect(map['name'], 'Omar');
      expect(map['phone'], '01111111111');
      expect(map['blood_type'], 'O-');
      expect(map['created_at'], '2024-02-01');
      expect(map['updated_at'], '2024-02-02');
      expect(map['image_path'], '/path/image.png');
    });
  });
}
