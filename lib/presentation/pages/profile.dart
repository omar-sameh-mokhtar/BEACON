import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ProfileViewModel.dart';
import '../widgets/AppBarTop.dart';
import '../widgets/NavigationBarBottom.dart';
import '../widgets/FloatingVoiceButton.dart';
import 'EditProfileDialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    context.read<ProfileViewModel>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title: "Profile"),
      bottomNavigationBar:
      const NavigationBarBottom(currentIndex: 1),
      floatingActionButton: Floatingvoicebutton(centre: false),

      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          if (!vm.hasProfile) {
            return _emptyState(vm);
          }
          return _profileView(context, vm);
        },
      ),
    );
  }

  Widget _profileView(BuildContext context, ProfileViewModel vm) {
    final profile = vm.profile!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/pp.png"),
          ),
          const SizedBox(height: 12),

          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.phone,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            "Blood: ${profile.bloodType}",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const EditProfileDialog(),
            ),
            child: const Text("Edit Profile", style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }

  Widget _emptyState(ProfileViewModel vm) {
    return Center(
      child: ElevatedButton(
        style:
        ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await vm.saveProfile();
        },
        child: const Text("Create Profile", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
