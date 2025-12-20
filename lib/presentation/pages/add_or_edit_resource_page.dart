import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/data/Resource.dart';
import '../../viewmodels/add_edit_resource_viewmodel.dart';
import '../../viewmodels/p2p_viewmodel.dart';

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

  late String _selectedType;
  bool get _isEditing => widget.resource != null;
  final List<String> _types = ['Medical', 'Shelter', 'Food'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.resource?.resourceType ?? widget.resourceType;
    if (_isEditing) {
      _quantityController.text = widget.resource!.quantity.toString();
      _noteController.text = widget.resource!.note;
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.red),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AddEditResourceViewModel>();
    final p2pVM = context.read<P2PViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Resource' : 'Add Resource'),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isEditing ? Icons.edit_note : Icons.add_box,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _buildInputDecoration('Resource Type', Icons.category),
                items: _types.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: _isEditing ? null : (value) => setState(() => _selectedType = value!),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Quantity', Icons.inventory_2),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter quantity';
                  if (int.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _noteController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Additional Notes', Icons.description),
                validator: (v) => v == null || v.isEmpty ? 'Enter note' : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: Colors.red.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    await vm.save(
                      isEditing: _isEditing,
                      old: widget.resource,
                      type: _selectedType,
                      quantity: int.parse(_quantityController.text),
                      note: _noteController.text,
                    );
                    await p2pVM.sync_broadcast();

                    if (mounted) Navigator.pop(context, true);
                  },
                  child: Text(
                    _isEditing ? 'UPDATE RESOURCE' : 'SAVE RESOURCE',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}