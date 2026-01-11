import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: LoginPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // Application state variables and methods go here
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.local_parking, size: 60, color: Colors.deepPurple),
            ),
            Text('ParkEasy'),
            Text('Pronađite i rezervišite parking mjesto odmah'),
            Card(
              margin: EdgeInsets.fromLTRB(150.0, 20, 150, 100),
              child: GestureDetector(
                onTap: () {
                  // Handle login tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gesture Detected!')));
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.supervised_user_circle_rounded, color: Colors.deepPurple, size: 55),
                      SizedBox(width: 40),
                      Text('Korisnicka prijava', style: TextStyle(color: Colors.black)),
                      Text('Pronadite i rezervisite parking mjesta u blizini', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

