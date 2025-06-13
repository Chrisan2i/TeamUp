import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/core/providers/theme_provider.dart';

class ThemeSelectionView extends StatelessWidget {
  const ThemeSelectionView({super.key});

  static const Color backgroundColor = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Tema',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          RadioListTile<ThemeMode>(
            activeColor: Colors.black,
            title: const Text(
              'Claro',
              style: TextStyle(fontSize: 16),
            ),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (_) => themeProvider.setLightMode(),
          ),
          RadioListTile<ThemeMode>(
            activeColor: Colors.black,
            title: const Text(
              'Oscuro',
              style: TextStyle(fontSize: 16),
            ),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (_) => themeProvider.setDarkMode(),
          ),
        ],
      ),
    );
  }
}