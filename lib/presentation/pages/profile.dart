import 'dart:io';
import 'package:flutter/material.dart';
import 'package:beacon/model/data/UserProfile.dart';
import 'package:beacon/model/service/user_profile_service.dart';
import '../widgets/AppBarTop.dart';
import '../widgets/FloatingVoiceButton.dart';
import '../widgets/NavigationBarBottom.dart';
import '../../model/Device.helper.dart';

enum ProfileMode { create, view, edit }

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
  ProfileMode mode = ProfileMode.create;
  UserProfile? profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _dao.getUserProfile();

    if (user == null) {
      mode = ProfileMode.create;
    } else {
      profile = user;
      nameController.text = user.name;
      phoneController.text = user.phone;
      bloodType = user.bloodType;
      mode = ProfileMode.view;
    }

    setState(() {});
  }

  bool get isEditable => mode != ProfileMode.view;

  Future<void> _save() async {
    final now = DateTime.now().toIso8601String();

    if (mode == ProfileMode.create) {
      final deviceId = await DeviceIdHelper.getDeviceId();

      final newUser = UserProfile(
        id: 1,
        deviceId: deviceId,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        bloodType: bloodType,
        imagePath: '',
        createdAt: now,
        updatedAt: now,
      );

      await _dao.insertUserProfile(newUser);
      profile = newUser;
      mode = ProfileMode.view;
    } else if (mode == ProfileMode.edit && profile != null) {
      final updated = UserProfile(
        id: profile!.id,
        deviceId: profile!.deviceId,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        bloodType: bloodType,
        imagePath: profile!.imagePath,
        createdAt: profile!.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );


      await _dao.updateUserProfile(updated);
      profile = updated;
      mode = ProfileMode.view;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title: "Profile"),
      bottomNavigationBar: const NavigationBarBottom(currentIndex: 1),
      body: profile == null && mode != ProfileMode.create
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 24),
              _sectionTitle(
                mode == ProfileMode.create
                    ? "Create Profile"
                    : "Personal Information",
              ),
              _field("Name", nameController),
              _field("Phone", phoneController),
              _bloodDropdown(),
              const SizedBox(height: 24),
              _actionButton(),
            ],
          ),
        ),
      ),
      floatingActionButton: Floatingvoicebutton(centre: false),
    );
  }

  /// ---------------- UI ----------------

  Widget _header() {
    if (mode == ProfileMode.create) return const SizedBox();

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: profile!.imagePath.isEmpty
                ? const AssetImage("assets/pp.png")
                : FileImage(File(profile!.imagePath)) as ImageProvider,
          ),
          const SizedBox(height: 8),
          Text(
            "Device ID: ${profile!.deviceId}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (mode == ProfileMode.view)
            TextButton(
              key: const Key('edit_profile_button'),
              onPressed: () => setState(() => mode = ProfileMode.edit),
              child: const Text("Edit", style: TextStyle(color: Colors.red)),
            ),

        ],
      ),
    );

  }

  Widget _actionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style:
        ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: _save,
        child: Text(
          mode == ProfileMode.create
              ? "Create Profile"
              : "Save Changes",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: c,
      enabled: isEditable,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
    ),
  );

  Widget _bloodDropdown() {
    return DropdownButtonFormField<String>(
      value: bloodType,
      dropdownColor: Colors.grey[900],
      decoration: _decoration("Blood Type"),
      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child: Text(e,
              style: const TextStyle(color: Colors.white)),
        ),
      )
          .toList(),
      onChanged: isEditable ? (v) => setState(() => bloodType = v!) : null,
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold),
    ),
  );

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    enabledBorder:
    const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
    disabledBorder:
    const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2)),
  );
}
