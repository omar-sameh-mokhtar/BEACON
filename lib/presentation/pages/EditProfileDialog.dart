import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ProfileViewModel.dart';

class EditProfileDialog extends StatelessWidget {
  const EditProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _field("Name", vm.nameController),
            _field("Phone", vm.phoneController),
            _bloodDropdown(vm),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red),
                    onPressed: () async {
                      await vm.saveProfile();
                      Navigator.pop(context);
                    },
                    child: const Text("Save",style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
    ),
  );

  Widget _bloodDropdown(ProfileViewModel vm) {
    return DropdownButtonFormField<String>(
      value: vm.bloodType,
      dropdownColor: Colors.grey[900],
      decoration: _decoration("Blood Type"),
      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
          .map(
            (e) => DropdownMenuItem(
          value: e,
          child:
          Text(e, style: const TextStyle(color: Colors.white)),
        ),
      )
          .toList(),
      onChanged: (v) => vm.bloodType = v!,
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
  );
}
