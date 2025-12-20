import 'package:flutter/material.dart';
import '../model/data/UserProfile.dart';
import '../model/service/user_profile_service.dart';
import '../model/Device.helper.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserProfileDao _dao = UserProfileDao();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String bloodType = 'A+';
  UserProfile? profile;

  bool get hasProfile => profile != null;

  get owner => profile?.name;

  Future<void> loadProfile() async {
    final user = await _dao.getUserProfile();
    if (user != null) {
      profile = user;
      nameController.text = user.name;
      phoneController.text = user.phone;
      bloodType = user.bloodType;
    }
    notifyListeners();
  }

  Future<void> saveProfile() async {
    final now = DateTime.now().toIso8601String();

    if (profile == null) {
      final deviceId = await DeviceIdHelper.getDeviceId();
      profile = UserProfile(
        id: 1,
        deviceId: deviceId,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        bloodType: bloodType,
        imagePath: '',
        createdAt: now,
        updatedAt: now,
      );
      await _dao.insertUserProfile(profile!);
    } else {
      profile = profile!.copyWith(
        name1: nameController.text.trim(),
        phone: phoneController.text.trim(),
        bloodType: bloodType,
        updatedAt: now,
      );
      await _dao.updateUserProfile(profile!);
    }

    notifyListeners();
  }
}
