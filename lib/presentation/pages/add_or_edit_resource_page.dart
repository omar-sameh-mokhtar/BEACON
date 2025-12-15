import 'package:flutter/material.dart';
import 'package:beacon/model/data/Resource.dart';
import 'package:beacon/model/service/resource_service.dart';
import 'package:beacon/model/service/user_profile_service.dart';

class AddOrEditResourcePage extends StatefulWidget {
  final String resourceType;
  final Resource? resource;

  const AddOrEditResourcePage({
    super.key,
    required this.resourceType,
    this.resource,
  });

  @override
  State<AddOrEditResourcePage> createState() => _AddOrEditResourcePageState();
}

class _AddOrEditResourcePageState extends State<AddOrEditResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  final _resourceDao = ResourceDao();
  final _userProfileDao = UserProfileDao();

  bool get _isEditing => widget.resource != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _quantityController.text =
          widget.resource!.quantity.toString();
      _noteController.text = widget.resource!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Resource' : 'Add Resource'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter quantity';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Enter note' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                ),
                onPressed: _saveResource,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveResource() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await _userProfileDao.getUserProfile();
    if (user == null) return;

    if (_isEditing) {
      final updated = Resource(
        id: widget.resource!.id,
        resourceType: widget.resourceType,
        quantity: int.parse(_quantityController.text),
        note: _noteController.text,
        requesterId: widget.resource!.requesterId,
        status: widget.resource!.status,
        timestamp: DateTime.now().toIso8601String(),
        owner: "me",
        isRequested: false,
        isMine: true,
      );

      await _resourceDao.updateResource(updated);
    } else {
      final all = await _resourceDao.getAllResources();
      final newId =
          (all.isNotEmpty ? all.map((e) => e.id).reduce((a, b) => a > b ? a : b) : 0) +
              1;

      final resource = Resource(
        id: newId,
        resourceType: widget.resourceType,
        quantity: int.parse(_quantityController.text),
        note: _noteController.text,
        requesterId: user.deviceId,
        status: 'available',
        timestamp: DateTime.now().toIso8601String(),
        owner: "me",
        isRequested: false,
        isMine: true,
      );

      await _resourceDao.addResource(resource);
    }

    Navigator.pop(context, true);
  }
}
