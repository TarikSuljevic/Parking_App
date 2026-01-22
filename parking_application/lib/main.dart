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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(

                  margin: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => UserInputPage())
                      );
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
                 Card(
                  margin: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => AdminInputPage())
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.supervised_user_circle_outlined, color: Colors.deepPurple, size: 55),
                          SizedBox(width: 40),
                          Text('Administratorska prijava', style: TextStyle(color: Colors.black)),
                          Text('Upravljajte parking objektima i rezervacijama', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}


class UserInputPage extends StatelessWidget {
class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  State<UserInputPage> createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  late String ime = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 560,vertical: 5),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 100, 12.0, 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: InkWell(
                    child:Row(children: [
         BackButton(
      // child:
    
    
    ),
    Text("Nazad"),
    ],),
                  
                  ),
                ),

                Icon(Icons.supervised_user_circle_rounded, color: Colors.deepPurple, size: 55),
                SizedBox(width: 40),
                Text('Korisnicka prijava', style: TextStyle(color: Colors.black)),
                Text('Unesite vase podatke za nastavak', style: TextStyle(color: Colors.black54)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                        child: Text('Ime'),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Unesite vase ime",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo unesite ime';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          ime = value;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                        child: Text('Email'),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Unesite vas email",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo unesite email';
                          }
                          if (!value.contains('@')) {
                            return 'Molimo unesite @ u email adresu';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                        child: Text('Lozinka'),
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Unesite vasu lozinku",
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo unesite lozinku';
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => HomePage(ime: ime))
                              );
                            }, 
                            child: Text('Prijavi se')),
                        ),
                      ),
                    ]
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}




class AdminInputPage extends StatelessWidget {
  const AdminInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 560,vertical: 5),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 100, 12.0, 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(children: [
         BackButton(
      // child:
    
    
    ),
    Text("Nazad"),
    ],),
                Icon(Icons.supervised_user_circle_outlined, color: Colors.deepPurple, size: 55),

                SizedBox(width: 40),
                Text('Administratorska prijava', style: TextStyle(color: Colors.black)),
                Text('Unesite vase podatke za nastavak', style: TextStyle(color: Colors.black54)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                        child: Text('Ime'),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Unesite vase ime",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                        child: Text('Email'),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Unesite vas email",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                        child: Text('Lozinka'),
                      ),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Unesite vasu lozinku",
                        ),
                      ),
                    ]
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}