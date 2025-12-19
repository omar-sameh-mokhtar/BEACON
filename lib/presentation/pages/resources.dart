import 'package:flutter/material.dart';
import 'package:beacon/model/data/Resource.dart';
import 'package:beacon/model/service/resource_service.dart';
import 'package:beacon/model/service/user_profile_service.dart';
import 'package:beacon/presentation/pages/add_or_edit_resource_page.dart';
import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/resources_viewmodel.dart';
class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourcesViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResourcesViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title: "Resources"),
      bottomNavigationBar: const NavigationBarBottom(currentIndex: 2),
      body: Column(
        children: [
          _buildTabs(vm),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Resource'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddOrEditResourcePage(
                      resourceType: vm.tabs[vm.currentTab],
                    ),
                  ),
                );
                if (result == true) vm.refresh();
              },
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildList(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(ResourcesViewModel vm) {
    return Container(
      color: Colors.grey[900],
      child: Row(
        children: List.generate(vm.tabs.length, (index) {
          final selected = vm.currentTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => vm.changeTab(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? Colors.red : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _tabIcon(index),
                      color: selected ? Colors.red : Colors.white70,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vm.tabs[index],
                      style: TextStyle(
                        color: selected ? Colors.red : Colors.white70,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildList(ResourcesViewModel vm) {
    if (vm.filteredResources.isEmpty) {
      return const Center(
        child: Text(
          'No resources found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.filteredResources.length,
      itemBuilder: (_, i) {
        final item = vm.filteredResources[i];
        return _buildCard(context, vm, item);
      },
    );
  }

  Widget _buildCard(
      BuildContext context,
      ResourcesViewModel vm,
      Resource item,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.isMine ? Icons.person : Icons.volunteer_activism,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    item.isMine
                        ? 'My Resource'
                        : 'From ${item.owner != null && item.owner!.isNotEmpty ? item.owner! : 'Anonymous'}',
                    style: TextStyle(
                      color: Colors.red ,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (item.isMine)
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddOrEditResourcePage(
                              resourceType: item.resourceType,
                              resource: item,
                            ),
                          ),
                        );
                        if (res == true) vm.refresh();
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                      onPressed: () {
                        vm.deleteResource(item.id);
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.note,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Quantity: ${item.quantity}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (!item.isMine) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
              ),
              onPressed: () {
                // TODO: feature later
              },
              child: const Text('Action'),
            ),
          ]
        ],
      ),
    );
  }

  IconData _tabIcon(int i) {
    if (i == 0) return Icons.medical_services;
    if (i == 1) return Icons.home;
    return Icons.fastfood;
  }
}
