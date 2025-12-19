import 'package:flutter/material.dart';
import '../model/data/Resource.dart';
import '../model/service/resource_service.dart';
import '../model/service/user_profile_service.dart';

class ResourcesViewModel extends ChangeNotifier {
  final ResourceDao _resourceDao = ResourceDao();
  final UserProfileDao _userProfileDao = UserProfileDao();

  int currentTab = 0;
  List<Resource> _allResources = [];
  bool isLoading = true;

  final List<String> tabs = ['Medical', 'Shelter', 'Food'];

  List<Resource> get filteredResources =>
      _allResources.where(
            (e) => e.resourceType == tabs[currentTab],
      ).toList();


  List<Resource> get allResources => _allResources;

  void replaceAll(List<Resource> list) {
    _allResources = list;
    notifyListeners();
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await _userProfileDao.getUserProfile();
    _allResources = await _resourceDao.getAllResources();

    isLoading = false;
    notifyListeners();
  }

  void changeTab(int index) {
    currentTab = index;
    notifyListeners();
  }

  Future<void> refresh() async {
    _allResources = await _resourceDao.getAllResources();
    notifyListeners();
  }

  Future<void> requestResource(Resource resource) async {
    await _resourceDao.requestResource(resource);
    await refresh();
  }

  Future<void> deleteResource(int id) async {
    await _resourceDao.deleteResource(id);
    await refresh();
  }
}
