import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


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
  List<Rezervacija> rezervacije = [];
  Map<String, Set<int>> reservedSpaces = {};
  String? currentUser;

  void setCurrentUser(String name) {
    currentUser = name;
    notifyListeners();
  }

  void dodajRezervaciju(Rezervacija r) {
    rezervacije.add(r);
    notifyListeners();
  }

  void reserveSpace(String parkingName, int mjesto) {
    reservedSpaces.putIfAbsent(parkingName, () => <int>{}).add(mjesto);
    notifyListeners();
  }

  bool isSpaceOccupied(String parkingName, int mjesto) {
    return reservedSpaces[parkingName]?.contains(mjesto) ?? false;
  }

  Rezervacija? aktivnaRezervacija() {
    try {
      return rezervacije.firstWhere((r) => r.status == 'aktivna');
    } catch (e) {
      return null;
    }
  }

  void cancelReservation(Rezervacija r) {
    final idx = rezervacije.indexWhere((x) => x.parkingName == r.parkingName && x.mjestoBroj == r.mjestoBroj && x.datum == r.datum);
    if (idx != -1) {
      rezervacije[idx] = Rezervacija(
        status: 'otkazana',
        datum: r.datum,
        prihod: r.prihod,
        parkingName: r.parkingName,
        mjestoBroj: r.mjestoBroj,
        expiresAt: r.expiresAt,
        arrived: r.arrived,
        durationHours: r.durationHours,
        arrivedUntil: r.arrivedUntil,
        username: r.username,
        cancelledAt: DateTime.now(),
      );
      reservedSpaces[r.parkingName]?.remove(r.mjestoBroj);
      notifyListeners();
    }
  }

  void markArrived(Rezervacija r) {
    final idx = rezervacije.indexWhere((x) => x.parkingName == r.parkingName && x.mjestoBroj == r.mjestoBroj && x.datum == r.datum);
    if (idx != -1) {
      final mins = (r.durationHours * 60).round();
      final arrivalEnd = DateTime.now().add(Duration(minutes: mins));
      rezervacije[idx] = Rezervacija(
        status: r.status,
        datum: r.datum,
        prihod: r.prihod,
        parkingName: r.parkingName,
        mjestoBroj: r.mjestoBroj,
        expiresAt: r.expiresAt,
        arrived: true,
        durationHours: r.durationHours,
        arrivedUntil: arrivalEnd,
        username: r.username,
        cancelledAt: r.cancelledAt,
      );
      notifyListeners();
    }
  }

  void finishReservation(Rezervacija r) {
    final idx = rezervacije.indexWhere((x) => x.parkingName == r.parkingName && x.mjestoBroj == r.mjestoBroj && x.datum == r.datum);
    if (idx != -1) {
      rezervacije[idx] = Rezervacija(
        status: 'zavrsena',
        datum: r.datum,
        prihod: r.prihod,
        parkingName: r.parkingName,
        mjestoBroj: r.mjestoBroj,
        expiresAt: r.expiresAt,
        arrived: r.arrived,
        durationHours: r.durationHours,
        arrivedUntil: r.arrivedUntil,
        username: r.username,
        cancelledAt: r.cancelledAt,
      );
      reservedSpaces[r.parkingName]?.remove(r.mjestoBroj);
      notifyListeners();
    }
  }

  int get aktivnoSada {
    return rezervacije.where((r) => r.status == "aktivna").length;
  }

  int get danas {
    final danasnjiDatum = DateTime.now();
    return rezervacije
        .where(
          (r) =>
              r.datum.year == danasnjiDatum.year &&
              r.datum.month == danasnjiDatum.month &&
              r.datum.day == danasnjiDatum.day,
        )
        .length;
  }

  int get zavrseno {
    return 0;
  }

  double get prihod {
    double total = 0;
    for (var r in rezervacije) {
      total += r.prihod;
    }
    return total;
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(0.1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepPurple,
                  width: 3,
                ), // boja i debljina border-a
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: Icon(
                  Icons.local_parking_rounded,
                  size: 60,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Text('ParkEasy'),
            Text('Pronađite i rezervišite parking mjesto odmah'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => UserInputPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12.0,
                        12.0,
                        12.0,
                        12.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.supervised_user_circle_rounded,
                            color: Colors.deepPurple,
                            size: 55,
                          ),
                          SizedBox(width: 40),
                          Text(
                            'Korisnicka prijava',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Pronadite i rezervisite parking mjesta u blizini',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => AdminInputPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        12.0,
                        12.0,
                        12.0,
                        12.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.supervised_user_circle_outlined,
                            color: Colors.deepPurple,
                            size: 55,
                          ),
                          SizedBox(width: 40),
                          Text(
                            'Administratorska prijava',
                            style: TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Upravljajte parking objektima i rezervacijama',
                            style: TextStyle(color: Colors.black54),
                          ),
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

class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  State<UserInputPage> createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage> {
  late String ime = '';
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 560, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 100.0, 12.0, 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BackButton(
                        // child:
                      ),
                      Text("Nazad"),
                    ],
                  ),
                  Icon(
                    Icons.supervised_user_circle_rounded,
                    color: Colors.deepPurple,
                    size: 55,
                  ),
                  SizedBox(width: 40),
                  Text(
                    'Korisnicka prijava',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Unesite vase podatke za nastavak',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            0.0,
                            0.0,
                            8.0,
                          ),
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
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(ime: ime),
                                ),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            8.0,
                            0.0,
                            8.0,
                          ),
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
                            int indexOf = value.indexOf(("@"));
                            if (indexOf == -1) {
                              return "Email mora sadržavati @";
                            }
                            if (indexOf == value.length - 1) {
                              return "Molimo unesite znak nakon @";
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(ime: ime),
                                ),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            8.0,
                            0.0,
                            8.0,
                          ),
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
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(ime: ime),
                                ),
                              );
                            }
                          },
                        ),
                        // builder: (context) => HomePage(ime: ime))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            20.0,
                            0.0,
                            0.0,
                          ),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => HomePage(ime: ime),
                                    ),
                                  );
                                }
                              },

                              child: Text('Prijavi se'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminInputPage extends StatefulWidget {
  const AdminInputPage({super.key});

  @override
  State<AdminInputPage> createState() => _AdminInputPageState();
}

String ime = '';

class _AdminInputPageState extends State<AdminInputPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 560, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 100, 12.0, 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BackButton(
                        // child:
                      ),
                      Text("Nazad"),
                    ],
                  ),
                  Icon(
                    Icons.supervised_user_circle_outlined,
                    color: Colors.deepPurple,
                    size: 55,
                  ),

                  SizedBox(width: 40),
                  Text(
                    'Administratorska prijava',
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Unesite vase podatke za nastavak',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            0.0,
                            0.0,
                            8.0,
                          ),
                          child: Text('Ime'),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Unesite vase ime",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Molimo unesite ime";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            ime = value;
                          },

                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminPage(ime: ime),
                                ),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            8.0,
                            0.0,
                            8.0,
                          ),
                          child: Text('Email'),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Unesite vas email",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Molimo unesite email";
                            }
                            int indexOf = value.indexOf(("@"));
                            if (indexOf == -1) {
                              return "Email mora sadržavati @";
                            }
                            if (indexOf == value.length - 1) {
                              return "Molimo unesite znak nakon @";
                            }

                            return null;
                          },
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminPage(ime: ime),
                                ),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            8.0,
                            0.0,
                            8.0,
                          ),
                          child: Text('Lozinka'),
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Unesite vasu lozinku",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Molimo unesite lozinku";
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminPage(ime: ime),
                                ),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0.0,
                            20.0,
                            0.0,
                            0.0,
                          ),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (context) => AdminPage(ime: ime),
                                    ),
                                  );
                                }
                              },
                              child: Text('Prijavi se'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Rezervacija {
  final String status; // "aktivna", "otkazana", "zavrsena"
  final DateTime datum;
  final double prihod;
  final String parkingName;
  final int mjestoBroj;
  final DateTime expiresAt;
  final bool arrived;
  final double durationHours;
  final DateTime? arrivedUntil;
  final String username;
  final DateTime? cancelledAt;
  

  Rezervacija({
    required this.status,
    required this.datum,
    required this.prihod,
    required this.parkingName,
    required this.mjestoBroj,
    required this.expiresAt,
    this.arrived = false,
    required this.durationHours,
    this.arrivedUntil,
    required this.username,
    this.cancelledAt,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.ime});

  final String ime;
  @override
  State<HomePage> createState() => _HomePageState();
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key, required this.ime});
  final String ime;
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String selectedTab = 'pregled';

  final List<ParkingListing> parkings = [
    ParkingListing(
      name: 'Tržni Centar Parking',
      address: '180/300 zauzeto',
      features: ['Pokriveno', 'EV Punjenje', '24/7 Obezbedjenje'],
      available: '180/300',
      pricePerHour: 12.0,
    ),
    ParkingListing(
      name: 'Gradska Garaža',
      address: '138/150 zauzeto',
      features: ['Pokriveno', 'Valet Usluga', 'Autopraonica'],
      available: '138/150',
      pricePerHour: 13.38,
    ),
    ParkingListing(
      name: 'Parking Centar Grada',
      address: '155/200 zauzeto',
      features: ['Na otvorenom', 'Video nadzor'],
      available: '155/200',
      pricePerHour: 8.07,
    ),
    ParkingListing(
      name: 'Metro Stanica Parking',
      address: '75/80 zauzeto',
      features: ['Pokriveno', 'WC', 'Kafić'],
      available: '75/80',
      pricePerHour: 12.27,
    ),
    ParkingListing(
      name: 'Parking kod Rijeke',
      address: '22/100 zauzeto',
      features: ['Na otvorenom', 'Roštilj'],
      available: '22/100',
      pricePerHour: 17.52,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7C3AED),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ParkEasy Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Dobrodošli nazad, ${widget.ime}',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.brightness_4, color: Colors.white),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: Icon(Icons.logout, size: 16),
                  label: Text('Odjavi se'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<MyAppState>(
        builder: (context, state, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards
                Container(
                  color: Color(0xFF7C3AED),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildCard('Aktivno Sada', state.aktivnoSada.toString(), Icons.people),
                      buildCard('Danas', state.danas.toString(), Icons.calendar_today),
                      buildCard('Završeno', '0', Icons.check_circle),
                      buildCard('Prihod', '\$${state.prihod.toStringAsFixed(2)}', Icons.attach_money),
                    ],
                  ),
                ),

                // Tabs
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _buildTab('Pregled', 'pregled'),
                      SizedBox(width: 8),
                      _buildTab('Rezervacije', 'rezervacije'),
                      SizedBox(width: 8),
                      _buildTab('Parking Objekti', 'parking'),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: selectedTab == 'pregled' ? _buildPregledTab(state) : _buildRezervacijeTab(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedTab = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTab == value ? Color(0xFF7C3AED) : Colors.grey.shade300,
        foregroundColor: selectedTab == value ? Colors.white : Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildPregledTab(MyAppState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nedavne Aktivnosti
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nedavne Aktivnosti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              if (state.rezervacije.isEmpty)
                Text('Nema nedavnih aktivnosti')
              else
                ...state.rezervacije.take(5).map((r) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r.parkingName} - Mjesto #${r.mjestoBroj}', 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 4),
                              Text(r.datum.toLocal().toString(), 
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: r.status == 'aktivna' ? Colors.green.shade200 : 
                                   r.status == 'zavrsena' ? Colors.blue.shade200 :
                                   Colors.red.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(r.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: r.status == 'aktivna' ? Colors.green.shade800 :
                                     r.status == 'zavrsena' ? Colors.blue.shade800 :
                                     Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        ),
        SizedBox(width: 24),
        // Najbolje Lokacije
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Najbolje Lokacije', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              ...parkings.map((parking) => Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(parking.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(parking.address, style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Text(
                        '\$${(double.parse(parking.available.split('/')[0]) * parking.pricePerHour).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRezervacijeTab(MyAppState state) {
    final sve = state.rezervacije;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sve Rezervacije', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        if (sve.isEmpty)
          Text('Nema rezervacija')
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // show count for clarity
        
                SizedBox(height: 12),
                // header row
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 140, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text('Lokacija', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 180, child: Text('Početak', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 80, child: Text('Trajanje', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 100, child: Text('Iznos', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(width: 100, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                Divider(),
                // list of reservations
                ...sve.map((r) {
                  final idNumber = r.datum.year.toString() +
                      r.datum.month.toString().padLeft(2, '0') +
                      r.datum.day.toString().padLeft(2, '0') +
                      r.mjestoBroj.toString().padLeft(3, '0');
                  final dateLocal = r.datum.toLocal();
                  final month = dateLocal.month;
                  final day = dateLocal.day;
                  final year = dateLocal.year;
                  final hour = dateLocal.hour;
                  final minute = dateLocal.minute.toString().padLeft(2, '0');
                  final second = dateLocal.second.toString().padLeft(2, '0');
                  final ampm = hour >= 12 ? 'PM' : 'AM';
                  final display12Hour = (hour % 12 == 0 ? 12 : hour % 12).toString();
                  final formattedTime = '$month/$day/$year, $display12Hour:$minute:$second $ampm';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text('#$idNumber', maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
                          ),
                          Expanded(child: Text('${r.parkingName} - Mjesto #${r.mjestoBroj}')),
                          SizedBox(width: 180, child: Text(formattedTime)),
                          SizedBox(width: 80, child: Text('${r.durationHours.toStringAsFixed(0)}h')),
                          SizedBox(width: 100, child: Text('\$${r.prihod.toStringAsFixed(2)}')),
                          SizedBox(
                            width: 100,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: r.status == 'aktivna'
                                    ? Colors.green.shade100
                                    : r.status == 'zavrsena'
                                        ? Colors.blue.shade100
                                        : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  r.status[0].toUpperCase() + r.status.substring(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: r.status == 'aktivna'
                                        ? Colors.green.shade800
                                        : r.status == 'zavrsena'
                                            ? Colors.blue.shade800
                                            : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }
}

Widget buildCard(String title, String value, IconData icon) {
    return Container(
      width: 250,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }


class _HomePageState extends State<HomePage> {
  String selectedTab = 'search';
  String sortBy = 'Udaljenost';




  final List<ParkingListing> parkings = [
    ParkingListing(
      name: 'Parking Centar Grada',
      address: 'Ulica Maršala Tita 123, Centar',
      features: ['Pokriveno', 'EV Punjenje', '24/7 Obezbedjenje'],
      available: '45/200',
      pricePerHour: 5.0,
    ),
    ParkingListing(
      name: 'Gradska Garaža',
      address: 'Trg Slobode 456, Centar',
      features: ['Pokriveno', 'Valet Usluga', 'Autopraonica'],
      available: '12/150',
      pricePerHour: 6.5,
    ),
    ParkingListing(
      name: 'Parking kod Rijeke',
      address: 'Riječna Obala 789, Riverside',
      features: ['Na otvorenom', 'Video nadzor'],
      available: '78/100',
      pricePerHour: 3.5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'ParkEasy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Dobrodošli, ${widget.ime}',
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Odjavi se',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active reservation banner
            Consumer<MyAppState>(builder: (context, state, child) {
              final rez = state.aktivnaRezervacija();
              return rez != null && rez.status == 'aktivna'
                  ? ReservationBanner(rezervacija: rez)
                  : SizedBox.shrink();
            }),

            // Tab buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => selectedTab = 'search'),
                    icon: Icon(Icons.search),
                    label: Text('Pretraži Parking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedTab == 'search'
                          ? Colors.deepPurple
                          : Colors.grey.shade300,
                      foregroundColor: selectedTab == 'search'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => selectedTab = 'map'),
                    icon: Icon(Icons.map),
                    label: Text('Prikaz Mape'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedTab == 'map'
                          ? Colors.deepPurple
                          : Colors.grey.shade300,
                      foregroundColor: selectedTab == 'map'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                      'Pretražite po lokaciji, adresi ili nazivu parkinga...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Sort dropdown

            // Cancellations history (bottom)
            Consumer<MyAppState>(builder: (context, state, child) {
              final cancelled = state.rezervacije.where((r) => r.status == 'otkazana').toList().reversed.toList();
              if (cancelled.isEmpty) return SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Historija otkaza', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ...cancelled.map((r) {
                      final cancelledTime = r.cancelledAt?.toLocal().toString() ?? 'Nepoznato';
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.parkingName, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Mjesto #${r.mjestoBroj}'),
                              SizedBox(height: 4),
                              Text('Otkačeno: $cancelledTime'),
                              SizedBox(height: 2),
                              Text('Vrijeme odabrano: ${r.durationHours} h'),
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: sortBy,
                    items: ['Udaljenost', 'Cijena', 'Dostupnost'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Sortiraj po $value'),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => sortBy = value);
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Parking listings
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: parkings.length,
              itemBuilder: (context, index) {
                final parking = parkings[index];
                return ParkingCard(parking: parking);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingListing {
  final String name;
  final String address;
  final List<String> features;
  final String available;
  final double pricePerHour;
//promjenio sam u double jer cu morat racunat ukupni prihod, ti samo .toString() dje ti treba
  ParkingListing({
    required this.name,
    required this.address,
    required this.features,
    required this.available,
    required this.pricePerHour,
  });
}

class ParkingCard extends StatelessWidget {
  final ParkingListing parking;

  const ParkingCard({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.directions_car, color: Colors.deepPurple),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parking.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              parking.address,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: parking.features.map((feature) {
                return Chip(
                  label: Text(feature, style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dostupno:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      parking.available,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cijena:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${parking.pricePerHour.toString()} KM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ParkingSpaceSelectionDialog(parking: parking),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text(
                    'Rezerviši Sada',
                    style: TextStyle(color: Colors.white, fontSize: 12),
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

class ParkingSpaceSelectionDialog extends StatefulWidget {
  final ParkingListing parking;

  const ParkingSpaceSelectionDialog({super.key, required this.parking});

  @override
  State<ParkingSpaceSelectionDialog> createState() =>
      _ParkingSpaceSelectionDialogState();
}

class _ParkingSpaceSelectionDialogState
    extends State<ParkingSpaceSelectionDialog> {
  // Parse available spaces (e.g., "45/200" -> 45 available, 200 total)
  late int availableSpaces;
  late int totalSpaces;
  late List<ParkingSpace> spaces;
  int? selectedSpaceId;

  @override
  void initState() {
    super.initState();
    final parts = widget.parking.available.split('/');
    availableSpaces = int.parse(parts[0]);
    totalSpaces = int.parse(parts[1]);

    // Generate parking spaces with statuses and respect global reservations
    final reservedSet = Provider.of<MyAppState>(context, listen: false).reservedSpaces[widget.parking.name] ?? <int>{};
    spaces = List.generate(totalSpaces, (index) {
      final spaceId = index + 1;
      // If the space was reserved/occupied by a confirmed reservation, mark it occupied
      if (reservedSet.contains(spaceId)) {
        return ParkingSpace(id: spaceId, status: SpaceStatus.occupied);
      }
      // Distribute spaces: available (green), reserved (orange), occupied (red)
      if (index < availableSpaces) {
        return ParkingSpace(id: spaceId, status: SpaceStatus.available);
      } else if (index <
          availableSpaces + (totalSpaces - availableSpaces) ~/ 2) {
        return ParkingSpace(id: spaceId, status: SpaceStatus.reserved);
      } else {
        return ParkingSpace(id: spaceId, status: SpaceStatus.occupied);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.parking.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.parking.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Legend
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LegendItem(color: Colors.green, label: 'Dostupno ($availableSpaces)'),
                  LegendItem(color: Colors.orange, label: 'Rezervisano'),
                  LegendItem(color: Colors.red, label: 'Zauzeto'),
                ],
              ),
            ),

            // Parking spaces grid
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: spaces.length,
                    itemBuilder: (context, index) {
                      final space = spaces[index];
                      return GestureDetector(
                        onTap: space.status == SpaceStatus.available
                            ? () {
                                setState(() => selectedSpaceId = space.id);
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: space.status == SpaceStatus.available
                                ? Colors.green
                                : space.status == SpaceStatus.reserved
                                ? Colors.orange
                                : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            border: selectedSpaceId == space.id
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${space.id}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Otkaži'),
                ),
                ElevatedButton(
                  onPressed: selectedSpaceId != null
                      ? () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute( builder: (context) => RezervacijaPage(parking: widget.parking, mjestoBroj: selectedSpaceId!),),);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Nastavi sa Rezervacijom'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 11)),
      ],
    );
  }
}

enum SpaceStatus { available, reserved, occupied }

class ParkingSpace {
  final int id;
  final SpaceStatus status;

  ParkingSpace({required this.id, required this.status});
}

class RezervacijaPage extends StatefulWidget {
  final ParkingListing parking;
  final int mjestoBroj;

  RezervacijaPage({required this.parking, required this.mjestoBroj});

  @override
  State<RezervacijaPage> createState() => _RezervacijaPageState();
}
class _RezervacijaPageState extends State<RezervacijaPage> {
  double trajanjeSati = 1.0;
  TextEditingController customController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double ukupnaCijena = widget.parking.pricePerHour * trajanjeSati;

    return Scaffold(
     
      body: Center(
        child: SizedBox(
          height:600,
          width:450,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
              
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                          
                  children: [
                    Container(
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: Column(
                        children: [
                        Text("Parking: ${widget.parking.name}", style: TextStyle(fontSize: 20)),
                        Text("Mjesto: #${widget.mjestoBroj}"),
                        Text("Adresa: ${widget.parking.address}"),
                        Wrap(
                          spacing: 8,
                          children: widget.parking.features.map((f) => Chip(label: Text(f))).toList(),
                        ),]
                      )

                        ),
                        SizedBox(height: 20),
                        Text("Očekivano Vrijeme Parkinga (Opcionalno)", style: TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 8,
                          children: [0.5, 1, 2, 3, 4, 6, 8, 12].map((h) {
                            return ChoiceChip(
                              label: Text("${h}h"),
                              selected: trajanjeSati == h,
                              onSelected: (_) {
                                setState(() {
                                  trajanjeSati = h.toDouble();
                                  customController.clear();
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        Text("Ili unesite prilagođeno trajanje (sati):"),
                        TextField(
                          controller: customController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              setState(() {
                                trajanjeSati = parsed;
                              });
                            }
                          },
                          decoration: InputDecoration(hintText: "npr. 2.5"),
                        ),
                        SizedBox(height: 20),
                        Text("Ukupno: ${ukupnaCijena.toStringAsFixed(2)} KM", style: TextStyle(fontSize: 18)),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // otkaži
                              },
                              child: Text("Otkaži"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showPaymentDialog(context, ukupnaCijena);
                              },
                              child: Text("Nastavi na plaćanje"),
                            ),
                          ],
                        ),
                      ],
                    
                 
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, double amount) {
    final cardController = TextEditingController();
    final nameController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.green),
              SizedBox(width: 8),
              Text('Sigurno Plaćanje'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Summary box
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Parking Lokacija:'),
                          Text(widget.parking.name),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Parking Mjesto:'),
                          Text('#${widget.mjestoBroj}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Iznos za Plaćanje:'),
                          Text('${amount.toStringAsFixed(2)} KM', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  autocorrect: false,
                  enableSuggestions: false,

                  controller: cardController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Broj Kartice',
                  counterText: "",),
                
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                    LengthLimitingTextInputFormatter(19),
                    CardNumberFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.length != 16) {
                      return 'Unesite validan broj kartice';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Ime na Kartici'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: expiryController,
                        decoration: InputDecoration(labelText: 'Datum Isteka',counterText: ""),
                        
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                          LengthLimitingTextInputFormatter(5),
                          expiryDateNumberFormater(),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'CVV',counterText: ""),
                   
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          LengthLimitingTextInputFormatter(3),
             
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Otkaži')),
            ElevatedButton(
              onPressed: () {
                final provider = Provider.of<MyAppState>(context, listen: false);
                final novaRez = Rezervacija(
                  status: 'aktivna',
                  datum: DateTime.now(),
                  prihod: amount,
                  parkingName: widget.parking.name,
                  mjestoBroj: widget.mjestoBroj,
                  expiresAt: DateTime.now().add(Duration(minutes: 30)),
                  durationHours: trajanjeSati,
                  username: provider.currentUser ?? 'Nepoznato',
                );
                Provider.of<MyAppState>(context, listen: false).dodajRezervaciju(novaRez);
                Provider.of<MyAppState>(context, listen: false).reserveSpace(widget.parking.name, widget.mjestoBroj);
                Navigator.pop(context); 
                Navigator.pop(context); 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uspješno rezervisano mjesto #${widget.mjestoBroj}')));
              },
              child: Text('Plati ${amount.toStringAsFixed(2)} KM'),
            ),
          ],
        );
      },
    );
  }
}

class expiryDateNumberFormater extends TextInputFormatter{
  @override 
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ){
    var text = newValue.text;
    

    if(newValue.selection.baseOffset == 0){
      return newValue;
    }

    var cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');
    

    if(cleanedText.length > 4){
      cleanedText = cleanedText.substring(0, 4);
    }
    
 
    var buffer = StringBuffer();
    for(int i = 0; i < cleanedText.length; i++){
      buffer.write(cleanedText[i]);

      if(i == 1 && cleanedText.length > 2){
        buffer.write('/');
      }
    }
    
    var string = buffer.toString();
    

    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter{
@override 
TextEditingValue formatEditUpdate(
  TextEditingValue oldValue,
  TextEditingValue newValue,

){
  var text=newValue.text;
  if(newValue.selection.baseOffset==0){
    return newValue;
  }
  var cleanedText=text.replaceAll(' ', '');
  var buffer=StringBuffer();
  for(int i=0;i<cleanedText.length;i++){
    buffer.write(cleanedText[i]);
    var index=i+1;
    if(index%4==0 && index!=cleanedText.length){
      buffer.write(' ');
    }
  }
var string=buffer.toString();
return TextEditingValue(
  text: string,
  selection: TextSelection.collapsed(offset: string.length),
);
}

}

class ReservationBanner extends StatefulWidget {
  final Rezervacija rezervacija;
  const ReservationBanner({super.key, required this.rezervacija});

  @override
  State<ReservationBanner> createState() => _ReservationBannerState();
}

class _ReservationBannerState extends State<ReservationBanner> {
  late Duration remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateRemaining();
      if (remaining.inSeconds <= 0) {
        // expire reservation
        final provider = Provider.of<MyAppState>(context, listen: false);
        provider.cancelReservation(widget.rezervacija);
        _timer?.cancel();
      }
    });
  }

  void _updateRemaining() {
    setState(() {
      if (widget.rezervacija.arrived && widget.rezervacija.arrivedUntil != null) {
        remaining = widget.rezervacija.arrivedUntil!.difference(DateTime.now());
      } else {
        remaining = widget.rezervacija.expiresAt.difference(DateTime.now());
      }
      if (remaining.isNegative) remaining = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = d.inHours.toString().padLeft(2, '0');
    if (d.inHours > 0) return '$hh:$mm:$ss';
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppState>(context, listen: false);
    final rez = widget.rezervacija;
    final isArrived = rez.arrived && rez.arrivedUntil != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rez.parkingName, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Mjesto #${rez.mjestoBroj}'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.red),
                    SizedBox(width: 6),
                    Text(isArrived ? 'Preostalo vrijeme: ${_format(remaining)}' : 'Vrijeme za dolazak: ${_format(remaining)}', style: TextStyle(color: Colors.red)),
                  ],
                ),
                if (rez.arrived)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Dolazak potvrđen ✅', style: TextStyle(color: Colors.green)),
                  ),
              ],
            ),
          ),

          if (!isArrived) ...[
            IconButton(
              onPressed: rez.arrived
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Skeniraj QR kod'),
                          content: Text('Simulirajte skeniranje QR koda da potvrdite dolazak.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Otkaži')),
                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Potvrdi dolazak')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        provider.markArrived(rez);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dolazak potvrđen.')));
                      }
                    },
              icon: Icon(Icons.qr_code_scanner, color: rez.arrived ? Colors.grey : Colors.deepPurple),
            ),

            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Otkaži rezervaciju'),
                    content: Text('Da li želite otkazati rezervaciju mjesta #${rez.mjestoBroj}?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Ne')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Da')),
                    ],
                  ),
                );
                if (confirm == true) {
                  provider.cancelReservation(rez);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rezervacija otkazana.')));
                }
              },
              child: Text('Otkaži', style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }
}
