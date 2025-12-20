import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:beacon/model/data/Resource.dart';
import 'package:beacon/presentation/pages/add_or_edit_resource_page.dart';
import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';

import '../../viewmodels/ProfileViewModel.dart';
import '../../viewmodels/p2p_viewmodel.dart';
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
    final p2pVM = context.watch<P2PViewModel>();

    final bool amIHost = p2pVM.isHost;
    final String networkStatus = p2pVM.connectionStatus;
    final int peerCount = p2pVM.peers.length;

    debugPrint(
      "Status: $networkStatus | isHost: $amIHost | peers: $peerCount",
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title: "Resources"),
      bottomNavigationBar: const NavigationBarBottom(currentIndex: 2),
      floatingActionButton: Floatingvoicebutton(centre: false),

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
      //floatingActionButton: Floatingvoicebutton(centre: false),
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
                        fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
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

    final profile = context.watch<ProfileViewModel>();
    final p2pvm = context.watch<P2PViewModel>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                profile.owner == item.owner
                    ? Icons.person
                    : Icons.volunteer_activism,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  profile.owner == item.owner
                      ? 'My Resource'
                      : 'From ${item.owner?.isNotEmpty == true ? item.owner! : 'Anonymous'}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (profile.owner == item.owner)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.white, size: 20),
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
                    IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.white, size: 20),
                      onPressed: () {
                        vm.deleteResource(item.id);
                        context.read<P2PViewModel>().broadcastDeleteResource(item.id);
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
            style: const TextStyle(color: Colors.white70),
          ),

          if (item.owner!= profile.owner) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.85),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send),
                label: const Text('Request Resource'),
                onPressed: () {
                  p2pvm.requestResource(item, profile.owner ?? "ay7aga");
                  debugPrint("++++++++++++++++++++++++ request resource ${profile.owner} +++++++++++++++++++");
                },
              ),
            ),
          ],
        ],
      ),
    );
  }


  void _showRequestDialog(
      BuildContext context,
      ResourcesViewModel vm,
      Resource resource,
      ) {
    final controller = TextEditingController();
    final p2pVM = Provider.of<P2PViewModel>(context, listen: false);
    final profile = Provider.of<ProfileViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Resource',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  resource.note,
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add a message (optional)',
                    hintStyle: TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side:
                          const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          p2pVM.requestResource(resource, profile.owner);
                          Navigator.pop(context);
                        },
                        child: const Text('Send'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }


  IconData _tabIcon(int i) {
    if (i == 0) return Icons.medical_services;
    if (i == 1) return Icons.home;
    return Icons.fastfood;
  }
}
