import 'package:flutter/material.dart';
import 'package:beacon/viewmodels/ProfileViewModel.dart';
import 'package:beacon/model/data/UserProfile.dart';

class FakeProfileViewModel extends ChangeNotifier
    implements ProfileViewModel {

  @override
  UserProfile? profile;

  @override
  final nameController = TextEditingController();

  @override
  final phoneController = TextEditingController();

  @override
  String bloodType = 'A+';

  @override
  bool get hasProfile => profile != null;

  @override
  get owner => profile?.name;

  @override
  Future<void> loadProfile() async {

  }

  @override
  Future<void> saveProfile() async {
    profile = UserProfile(
      id: 1,
      deviceId: 'fake-device',
      name: 'Test User',
      phone: '01000000000',
      bloodType: bloodType,
      imagePath: '',
      createdAt: '',
      updatedAt: '',
    );
    notifyListeners();
  }
}
