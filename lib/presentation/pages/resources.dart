import 'package:flutter/material.dart';
import 'package:beacon/model/data/Resource.dart';
import 'package:beacon/model/service/resource_service.dart';
import 'package:beacon/model/service/user_profile_service.dart';
import 'package:beacon/presentation/pages/add_or_edit_resource_page.dart';
import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  int _currentTab = 0;

  final ResourceDao _resourceDao = ResourceDao();
  final UserProfileDao _userProfileDao = UserProfileDao();

  String? _currentUserId;
  Future<List<Resource>>? _resourcesFuture;

  final List<String> _tabs = ['Medical', 'Shelter', 'Food'];

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    final profile = await _userProfileDao.getUserProfile();
    if (profile == null) return;

    setState(() {
      _currentUserId = profile.deviceId;
      _resourcesFuture = _resourceDao.getAllResources();
    });
  }

  void _refresh() {
    setState(() {
      _resourcesFuture = _resourceDao.getAllResources();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title: "Resources"),
      bottomNavigationBar: const NavigationBarBottom(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddOrEditResourcePage(
                resourceType: _tabs[_currentTab],
              ),
            ),
          );
          if (result == true) _refresh();
        },
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }


  Widget _buildTabs() {
    return Container(
      color: Colors.grey[900],
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _currentTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _currentTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.red : Colors.grey,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getTabIcon(index),
                      color: isSelected ? Colors.red : Colors.white70,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.medical_services;
      case 1:
        return Icons.home;
      default:
        return Icons.fastfood;
    }
  }


  Widget _buildContent() {
    if (_resourcesFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Resource>>(
      future: _resourcesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString(),
                style: const TextStyle(color: Colors.white)),
          );
        }

        final resources = snapshot.data ?? [];

        final filtered = resources
            .where((e) => e.resourceType == _tabs[_currentTab])
            .toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Text('No resources found',
                style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (_, index) {
            final item = filtered[index];
            final isMine = item.isMine;
            return _buildResourceCard(item, isMine);
          },
        );
      },
    );
  }


  Widget _buildResourceCard(Resource item, bool isMine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isMine ? Colors.blue : Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isMine ? Icons.person : Icons.volunteer_activism,
                color: isMine ? Colors.blue : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                isMine ? 'My Resource' : 'Resource from ${item.owner}',
                style: TextStyle(
                  color: isMine ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isMine) _buildMenu(item),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.note,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Quantity: ${item.quantity}',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),

          /// REQUEST BUTTON (for others)
          if (!isMine)
            ElevatedButton(
              key: const Key('request_Resource_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                // TODO:
                // request resource logic
                // - update status
                // - broadcast via BLE
                // - notify owner
              },
              child: const Text('Request Resource'),
            ),
        ],
      ),
    );
  }


  Widget _buildMenu(Resource item) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        if (value == 'edit') {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddOrEditResourcePage(
                resourceType: item.resourceType,
                resource: item,
              ),
            ),
          );
          if (result == true) _refresh();
        }

        if (value == 'delete') {
          await _resourceDao.deleteResource(item.id);
          _refresh();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}
