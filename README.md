import 'package:flutter/material.dart';
import 'home.dart';
import 'chat_screen.dart';
import 'login.dart';
import 'signup.dart';
import 'chat_rooms.dart';

void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'AI Chat App',
theme: ThemeData(primarySwatch: Colors.blue),
debugShowCheckedModeBanner: false,
initialRoute: '/login',
routes: {
'/login': (context) => LoginScreen(),
'/signup': (context) => SignUpScreen(),
'/home': (context) => HomeScreen(),
'/chat_rooms': (context) => ChatRoomsScreen(),
},
);
}
}
