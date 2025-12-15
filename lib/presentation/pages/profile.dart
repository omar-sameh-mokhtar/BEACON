import 'dart:io';

import 'package:flutter/material.dart';
import 'package:beacon/model/data/UserProfile.dart';
import 'package:beacon/model/service/user_profile_service.dart';

import '../../model/Device.helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _dao = UserProfileDao();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String bloodType = 'A+';

  bool isEditing = false;
  UserProfile? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final existing = await _dao.getUserProfile();

    if (existing != null) {
      profile = existing;
      nameController.text = existing.name;
      phoneController.text = existing.phone;
      bloodType = existing.bloodType;
    } else {
      final deviceId = await DeviceIdHelper.getDeviceId();
      final now = DateTime.now().toIso8601String();

      profile = UserProfile(
        id: 1,
        deviceId: deviceId,
        name: '',
        phone: '',
        bloodType: 'A+',
        createdAt: now,
        updatedAt: now,
        imagePath: '',
      );

      await _dao.insertUserProfile(profile!);
    }

    setState(() {});
  }

  Future<void> _save() async {
    if (profile == null) return;

    final updated = UserProfile(
      id: profile!.id,
      deviceId: profile!.deviceId,
      name: nameController.text,
      phone: phoneController.text,
      bloodType: bloodType,
      imagePath: profile!.imagePath,
      createdAt: profile!.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _dao.updateUserProfile(updated);
    setState(() {
      isEditing = false;
      profile = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(title: const Text('Profile')),
          body: Center(
            child: SizedBox(
              width: isTablet ? 500 : double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profile!.imagePath.isEmpty
                          ? const AssetImage('assets/pp.png')
                          : FileImage(File(profile!.imagePath))
                      as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Device ID: ${profile!.deviceId}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),

                    _field('Name', nameController),
                    _field('Phone', phoneController),

                    DropdownButtonFormField<String>(
                      value: bloodType,
                      dropdownColor: Colors.grey[900],
                      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style:
                              const TextStyle(color: Colors.white)),
                        ),
                      )
                          .toList(),
                      onChanged:
                      isEditing ? (v) => setState(() => bloodType = v!) : null,
                      decoration: _decoration('Blood Type'),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isEditing
                            ? _save
                            : () => setState(() => isEditing = true),
                        child: Text(isEditing ? 'Save' : 'Edit'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        enabled: isEditing,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder:
      OutlineInputBorder(borderSide: const BorderSide(color: Colors.red)),
      disabledBorder:
      OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }
}
