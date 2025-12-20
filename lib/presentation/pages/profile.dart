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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title: "User Profile"),
      bottomNavigationBar: const NavigationBarBottom(currentIndex: 1),
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const CircleAvatar(
                  radius: 70,
                  backgroundColor: Color(0xFF1E1E1E),
                  backgroundImage: AssetImage("assets/pp.png"),
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            Text(
              profile.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              "Network Member",
              style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _infoTile(Icons.phone, "Phone", profile.phone),
                  const Divider(color: Colors.white10, height: 1, indent: 50),
                  _infoTile(Icons.bloodtype, "Blood Group", profile.bloodType),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const EditProfileDialog(),
                ),
                label: const Text(
                  "EDIT PROFILE",
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ProfileViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle_outlined, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text("No profile found", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await vm.saveProfile();
            },
            child: const Text("CREATE PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}