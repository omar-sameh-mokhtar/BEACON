
import 'package:beacon/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBarTop extends StatelessWidget implements PreferredSizeWidget{
  AppBarTop({super.key, required this.title, isDarkMode});
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<MyAppState>(context);
    final isDark = themeProvider.isDarkMode;

    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Text(title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: isDark ? Colors.yellow : Colors.black,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
        Icon(Icons.settings, color: Colors.white),
        SizedBox(width: 10),
      ],
    );
  }
}