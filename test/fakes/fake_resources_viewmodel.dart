import 'package:flutter/material.dart';
import 'package:beacon/model/data/Resource.dart';
import 'package:beacon/viewmodels/resources_viewmodel.dart';

class FakeResourcesViewModel extends ChangeNotifier
    implements ResourcesViewModel {

  @override
  int currentTab = 0;

  @override
  bool isLoading = false;

  List<Resource> _resources = [];

  @override
  final List<String> tabs = ['Medical', 'Shelter', 'Food'];

  // ================= REQUIRED =================

  @override
  List<Resource> get allResources => _resources;

  @override
  List<Resource> get filteredResources => _resources;

  @override
  void replaceAll(List<Resource> list) {
    _resources = list;
    notifyListeners();
  }

  // ================= METHODS =================

  @override
  Future<void> init() async {}

  @override
  void changeTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> deleteResource(int id) async {}

  @override
  Future<void> requestResource(Resource resource) async {}
}
