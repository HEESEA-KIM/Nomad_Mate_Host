import 'package:flutter/material.dart';
import 'package:nomad/app.dart';

void main() {
  runApp(const HostApp());
}

class HostApp extends StatelessWidget {
  const HostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Custom AppBar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HostAppHomePage(),
    );
  }
}

