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

  late String _selectedType;

  bool get _isEditing => widget.resource != null;

  final List<String> _types = ['Medical', 'Shelter', 'Food'];

  @override
  void initState() {
    super.initState();

    _selectedType = widget.resource?.resourceType ?? widget.resourceType;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              DropdownButtonFormField<String>(
                value: _selectedType,
                items: _types
                    .map(
                      (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ),
                )
                    .toList(),
                onChanged: _isEditing
                    ? null
                    : (value) => setState(() => _selectedType = value!),
                decoration: const InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[900],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
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
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Enter note' : null,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveResource,
                child: Text(_isEditing ? 'Update Resource' : 'Save Resource'),
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

    if (_isEditing) {
      final updated = Resource(
        id: widget.resource!.id,
        resourceType: _selectedType,
        quantity: int.parse(_quantityController.text),
        note: _noteController.text,
        requesterId: "",
        status: 'available',
        timestamp: DateTime.now().toIso8601String(),
        owner: user?.name ?? "Me",
        isRequested: false,
        isMine: true,
      );

      await _resourceDao.updateResource(updated);
    } else {
      final all = await _resourceDao.getAllResources();
      final newId =
          (all.isNotEmpty ? all.map((e) => e.id).reduce((a, b) => a > b ? a : b) : 0) + 1;

      final resource = Resource(
        id: newId,
        resourceType: _selectedType,
        quantity: int.parse(_quantityController.text),
        note: _noteController.text,
        requesterId: "",
        status: 'available',
        timestamp: DateTime.now().toIso8601String(),
        owner: user?.name ?? "Me",
        isRequested: false,
        isMine: true,
      );

      await _resourceDao.addResource(resource);
    }

    Navigator.pop(context, true);
  }
}
