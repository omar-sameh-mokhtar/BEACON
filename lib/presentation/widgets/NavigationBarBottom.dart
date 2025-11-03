import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

class NavigationBarBottom extends StatelessWidget {
  const NavigationBarBottom({super.key, required this.currentIndex});
  final int currentIndex; 

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Resources',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/dashboard'); 
            break;
          case 1:
            context.go('/profile');
            break;
          case 2:
            context.go('/resources');
            break;
        }
      },
    );
  }
}
