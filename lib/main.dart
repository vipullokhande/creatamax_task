import 'package:creatamax_task/view/manage_services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creatamax Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromRGBO(34, 1, 82, 1),
          foregroundColor: Colors.white,
        ),
      ),
      home: ManageServices(),
    );
  }
}
