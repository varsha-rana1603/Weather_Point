import 'package:flutter/material.dart';
import 'package:weather_point/ui/get_started.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {  //StatelessWidget superclass and MyApp is subclass
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Weather Point',
      home: GetStarted(),
      debugShowCheckedModeBanner: false,
    );
  }
}




