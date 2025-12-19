import 'package:flutter/material.dart';
import 'package:beacon/model/data/Resource.dart';
import 'package:beacon/viewmodels/resources_viewmodel.dart';

class FakeResourcesViewModel extends ChangeNotifier
    implements ResourcesViewModel {

  @override
  int currentTab = 0;

  @override
  bool isLoading = false;

  @override
  final List<String> tabs = ['Medical', 'Shelter', 'Food'];

  @override
  List<Resource> get filteredResources => [];

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
