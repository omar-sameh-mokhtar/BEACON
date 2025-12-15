import 'package:beacon/model/data/ResourceRequest.dart';
import 'package:beacon/model/service/resource_request_service.dart';
import 'package:beacon/model/service/user_profile_service.dart';
import 'package:flutter/material.dart';

class AddOrEditResourcePage extends StatefulWidget {
  final String resourceType;
  final ResourceRequest? resourceRequest;

  const AddOrEditResourcePage(
      {super.key, required this.resourceType, this.resourceRequest});

  @override
  _AddOrEditResourcePageState createState() => _AddOrEditResourcePageState();
}

class _AddOrEditResourcePageState extends State<AddOrEditResourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  final _resourceRequestDao = ResourceRequestDao();
  final _userProfileDao = UserProfileDao();

  bool get _isEditing => widget.resourceRequest != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _quantityController.text = widget.resourceRequest!.quantity.toString();
      _noteController.text = widget.resourceRequest!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Request' : 'New Request'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a note';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveResourceRequest,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveResourceRequest() async {
    if (_formKey.currentState!.validate()) {
      final userProfile = await _userProfileDao.getUserProfile();
      if (userProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not identify user.')),
        );
        return;
      }

      if (_isEditing) {
        final updatedRequest = ResourceRequest(
          id: widget.resourceRequest!.id,
          resourceType: widget.resourceType,
          quantity: int.parse(_quantityController.text),
          note: _noteController.text,
          requesterId: widget.resourceRequest!.requesterId,
          status: widget.resourceRequest!.status,
          timestamp: DateTime.now().toIso8601String(),
        );
        await _resourceRequestDao.updateResourceRequest(updatedRequest);
      } else {
        // Creating a new id for the new request, assuming the db will auto-increment it if we pass a specific value or high value
        // The logic for ID generation should be robust, here is a simple example
        final allRequests = await _resourceRequestDao.getAll();
        final newId = (allRequests.isNotEmpty ? allRequests.map((e) => e.id).reduce((a, b) => a > b ? a : b) : 0) + 1;

        final newRequest = ResourceRequest(
          id: newId,
          resourceType: widget.resourceType,
          quantity: int.parse(_quantityController.text),
          note: _noteController.text,
          requesterId: userProfile.deviceId,
          status: 'open',
          timestamp: DateTime.now().toIso8601String(),
        );
        await _resourceRequestDao.insertResourceRequest(newRequest);
      }
      Navigator.pop(context, true); // Return true to indicate success
    }
  }
}
