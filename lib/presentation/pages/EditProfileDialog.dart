import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ProfileViewModel.dart';

class EditProfileDialog extends StatelessWidget {
  const EditProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white10), 
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),

              _field("Full Name", vm.nameController, Icons.person_outline),
              const SizedBox(height: 12),
              _field("Phone Number", vm.phoneController, Icons.phone_android),
              const SizedBox(height: 12),
              _bloodDropdown(vm),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await vm.saveProfile();
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, IconData icon) => TextField(
        controller: c,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: _decoration(label, icon),
      );

  Widget _bloodDropdown(ProfileViewModel vm) {
    return DropdownButtonFormField<String>(
      value: vm.bloodType,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white, fontSize: 15),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
      decoration: _decoration("Blood Type", Icons.bloodtype_outlined),
      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) vm.bloodType = v;
      },
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.redAccent.withOpacity(0.7), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );
}