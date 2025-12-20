import 'package:flutter/material.dart';
import '../model/data/Resource.dart';
import '../model/service/resource_service.dart';
import '../model/service/user_profile_service.dart';

class AddEditResourceViewModel extends ChangeNotifier {
  final ResourceDao _resourceDao = ResourceDao();
  final UserProfileDao _userProfileDao = UserProfileDao();

  Future<void> save({
    required bool isEditing,
    Resource? old,
    required String type,
    required int quantity,
    required String note,
  }) async {
    final user = await _userProfileDao.getUserProfile();

    if (isEditing && old != null) {
      await _resourceDao.updateResource(
        old.copyWith(
          quantity: quantity,
          note: note,
          status: 'available',
        ),
      );
    } else {
      final all = await _resourceDao.getAllResources();
      final newId =
          (all.isEmpty ? 0 : all.map((e) => e.id).reduce((a, b) => a > b ? a : b)) + 1;

      final resource = Resource(
        id: newId,
        resourceType: type,
        quantity: quantity,
        note: note,
        requesterId: "",
        owner: user?.name ?? "",
        status: 'available',
        isRequested: false,
        isMine: true,
        timestamp: DateTime.now().toIso8601String(),
      );

      await _resourceDao.addResource(resource);
    }
  }
}
