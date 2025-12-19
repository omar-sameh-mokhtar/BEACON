import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/data/Resource.dart';
import '../../viewmodels/add_edit_resource_viewmodel.dart';

class AddOrEditResourcePage extends StatefulWidget {
  final String resourceType;
  final Resource? resource;

  const AddOrEditResourcePage({
    super.key,
    required this.resourceType,
    this.resource,
  });

  @override
  State<AddOrEditResourcePage> createState() =>
      _AddOrEditResourcePageState();
}

class _AddOrEditResourcePageState
    extends State<AddOrEditResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  late String _selectedType;

  bool get _isEditing => widget.resource != null;

  final List<String> _types = ['Medical', 'Shelter', 'Food'];

  @override
  void initState() {
    super.initState();

    _selectedType =
        widget.resource?.resourceType ?? widget.resourceType;

    if (_isEditing) {
      _quantityController.text =
          widget.resource!.quantity.toString();
      _noteController.text = widget.resource!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AddEditResourceViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
        Text(_isEditing ? 'Edit Resource' : 'Add Resource'),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Resource Type
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
                    : (value) =>
                    setState(() => _selectedType = value!),
                decoration: const InputDecoration(
                  labelText: 'Resource Type',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[900],
              ),

              const SizedBox(height: 16),

              /// Quantity
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

              /// Note
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

              /// Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  await vm.save(
                    isEditing: _isEditing,
                    old: widget.resource,
                    type: _selectedType,
                    quantity:
                    int.parse(_quantityController.text),
                    note: _noteController.text,
                  );

                  Navigator.pop(context, true);
                },
                child: Text(
                  _isEditing
                      ? 'Update Resource'
                      : 'Save Resource',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
