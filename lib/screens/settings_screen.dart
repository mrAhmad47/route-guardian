import 'package:flutter/material.dart';
import '../components/app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: Center(child: Text('Settings Screen')),
    );
  }
}
