import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(MyApp());
}

// Helper: provide button colors that adapt for dark mode.
Color _buttonBackground(BuildContext context, Color lightModeColor) =>
    Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : lightModeColor;

Color _buttonForeground(BuildContext context, Color lightModeColor) =>
    Theme.of(context).brightness == Brightness.dark ? Colors.white : lightModeColor;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(builder: (context, state, child) {
        // Light theme (app primary color set to purple used across UI)
        final lightTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF7C3AED)),
          scaffoldBackgroundColor: Colors.white,
        );

        // Dark theme: dark-gray (not pure black) and soft white text
        final darkBackground = Color(0xFF111827); // dark slate gray
        final softWhite = Color(0xFFe6eef6); // soft white with slight blue tint
        final darkTheme = ThemeData.dark().copyWith(
          scaffoldBackgroundColor: darkBackground,
          canvasColor: darkBackground,
          cardColor: Color(0xFF1f2937),
          dialogTheme: DialogThemeData(backgroundColor: Color(0xFF111827)),
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: softWhite.withOpacity(0.9),
                displayColor: softWhite.withOpacity(0.95),
              ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: softWhite.withOpacity(0.95),
          ),
        );

        return MaterialApp(
          theme: state.isDarkMode ? darkTheme : lightTheme,
          home: LoginPage(),
        );
      }),
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

  // Theme mode: true = dark, false = light
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  // Saved payment card (for demo purposes only -- do NOT store real cards like this in production)
  Map<String, String>? savedCard;

  void saveCard({required String number, required String name, required String expiry}) {
    // store masked number and meta
    final cleaned = number.replaceAll(' ', '');
    final last4 = cleaned.length >= 4 ? cleaned.substring(cleaned.length - 4) : cleaned;
    savedCard = {
      'masked': '**** **** **** $last4',
      'number': cleaned,
      'name': name,
      'expiry': expiry,
    };
    notifyListeners();
  }

  bool get hasSavedCard => savedCard != null;

  void clearSavedCard() {
    savedCard = null;
    notifyListeners();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 28.0),
            child: DarkModeButton(),
          ),
        ],
      ),
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
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                          Text(
                            'Pronadite i rezervisite parking mjesta u blizini',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
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
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                          Text(
                            'Upravljajte parking objektima i rezervacijama',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
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
  String ime = ''; // Sklonjen 'late' jer inicijalizuješ odmah praznim stringom
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 560, vertical: 5),
          child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 100, 12.0, 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, //Card će se skupiti oko sadržaja
                children: [
                  Row(
                    children: [
                      BackButton(onPressed: () => Navigator.pop(context)),
                      const Text("Nazad"),
                        Spacer(),
                        DarkModeButton(),
                    ],
                  ),
                  const Icon(
                    Icons.supervised_user_circle_rounded,
                    color: Colors.deepPurple,
                    size: 55,
                  ),
                  SizedBox(width: 40),
                  Text(
                    'Korisnička prijava',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    'Unesite vaše podatke za nastavak',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 20),
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
                            hintText: "Unesite vaše ime",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Molimo unesite ime";
                            return null;
                          },
                          onChanged: (value) => ime = value,
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
                          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                          child: Text('Email'),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Unesite vaš email",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Molimo unesite email";
                            int indexOf = value.indexOf(("@"));
                            if (indexOf == -1) return "Email mora sadržavati @";
                            if (indexOf == value.length - 1) return "Molimo unesite znak nakon @";
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
                          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                          child: Text('Lozinka'),
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Unesite vašu lozinku",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Molimo unesite lozinku";
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
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _buttonBackground(context, Theme.of(context).colorScheme.primary),
                                foregroundColor: _buttonForeground(context, Colors.white),
                              ),
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
                      Spacer(),
                      DarkModeButton(),
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
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  Text(
                    'Unesite vase podatke za nastavak',
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _buttonBackground(context, Theme.of(context).colorScheme.primary),
                                foregroundColor: _buttonForeground(context, Colors.white),
                              ),
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

  // Track disabled parking locations by name (placeholder state)
  Set<String> disabledParkings = {};
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
        title: Text(
          'ParkEasy Admin',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Welcome message
                Text(
                  'Dobrodošli nazad, ${widget.ime}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 16),
                // use the shared DarkModeButton for consistent behavior and appearance
                DarkModeButton(),
                SizedBox(width: 12),
                Builder(builder: (ctx) {
                  final theme = Theme.of(ctx);
                  final isDark = theme.brightness == Brightness.dark;
                  return ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: Icon(Icons.logout, size: 16, color: isDark ? theme.colorScheme.onSurface : Color(0xFF7C3AED)),
                    label: Text('Odjavi se', style: TextStyle(color: isDark ? theme.colorScheme.onSurface : Color(0xFF7C3AED))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? _buttonBackground(ctx, Colors.white) : Colors.white,
                      foregroundColor: isDark ? _buttonForeground(ctx, theme.colorScheme.onSurface) : Color(0xFF7C3AED),
                    ),
                  );
                }),
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
                      buildCard(context, 'Aktivno Sada', state.aktivnoSada.toString(), Icons.people),
                      buildCard(context, 'Danas', state.danas.toString(), Icons.calendar_today),
                      buildCard(context, 'Završeno', '0', Icons.check_circle),
                      buildCard(context, 'Prihod', '\$${state.prihod.toStringAsFixed(2)}', Icons.attach_money),
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
                  child: selectedTab == 'pregled'
                      ? _buildPregledTab(state)
                      : selectedTab == 'rezervacije'
                          ? _buildRezervacijeTab(state)
                          : _buildParkingTab(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () => setState(() => selectedTab = value),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTab == value
            ? (isDark ? _buttonBackground(context, Color(0xFF7C3AED)) : Color(0xFF7C3AED))
            : (isDark ? _buttonBackground(context, Colors.grey.shade300) : Colors.grey.shade300),
        foregroundColor: selectedTab == value ? (isDark ? _buttonForeground(context, Colors.black87) : Colors.white) : (isDark ? Colors.white : Colors.black),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label),
    );
  }

  AlertDialog _buildDisableDialog(String parkingName) {
    return AlertDialog(
      title: Text('Onemogući Lokaciju'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Da li ste sigurni da želite onemogućiti lokaciju ',
                  style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14),
                ),
                TextSpan(
                  text: parkingName + '?',
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text('Razlog Onemogućavanja', style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (value) {},
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: _buttonBackground(context, Colors.grey.shade300),
              foregroundColor: _buttonForeground(context, Colors.black),
            ),
          child: Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              disabledParkings.add(parkingName);
            });
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Onemogući'),
        ),
      ],
    );
  }

  AlertDialog _buildAddLocationDialog() {
    String locationName = '';
    String numPlaces = '';
    return AlertDialog(
      title: Text('Dodaj Novu Lokaciju'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Naziv Lokacije', style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (value) => locationName = value,
          ),
          SizedBox(height: 16),
          Text('Broj Mjesta', style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => numPlaces = value,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
              backgroundColor: _buttonBackground(context, Colors.grey.shade300),
              foregroundColor: _buttonForeground(context, Colors.black),
            ),
          child: Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: () {
            if (locationName.isNotEmpty && numPlaces.isNotEmpty) {
              setState(() {
                parkings.add(
                  ParkingListing(
                    name: locationName,
                    address: '0/$numPlaces zauzeto',
                    features: ['Nova lokacija'],
                    available: '0/$numPlaces',
                    pricePerHour: 10.0,
                  ),
                );
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Dodaj'),
        ),
      ],
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
        Builder(builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(ctx).cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              SizedBox(height: 12),
              // header row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                    Expanded(child: Text('Lokacija', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                    Expanded(child: Text('Početak', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                    Expanded(child: Text('Trajanje', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                    Expanded(child: Text('Iznos', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                    Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
                  ],
                ),
              ),
              Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              // content: either placeholder message or list
              if (sve.isEmpty)
                SizedBox(
                  height: 140,
                  child: Center(
                    child: Text('Još nema rezervacija', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey)),
                  ),
                )
              else
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
                    color: isDark ? Color(0xFF2a2a3e) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(child: Text('#$idNumber', maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false, style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                          Expanded(child: Text('${r.parkingName} - Mjesto #${r.mjestoBroj}', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                          Expanded(child: Text(formattedTime, style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                          Expanded(child: Text('${r.durationHours.toStringAsFixed(0)}h', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                          Expanded(child: Text('\$${r.prihod.toStringAsFixed(2)}', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: r.status == 'aktivna'
                                    ? (isDark ? Colors.green.shade900 : Colors.green.shade100)
                                    : r.status == 'zavrsena'
                                        ? (isDark ? Colors.blue.shade900 : Colors.blue.shade100)
                                        : (isDark ? Colors.red.shade900 : Colors.red.shade100),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  r.status[0].toUpperCase() + r.status.substring(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : (r.status == 'aktivna'
                                            ? Colors.green.shade800
                                            : r.status == 'zavrsena'
                                                ? Colors.blue.shade800
                                                : Colors.red.shade800),
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
          );
        }),
      ],
    );
  }

  Widget _buildParkingTab(MyAppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierColor: Color(0xFF1A237E),
                  barrierDismissible: false,
                  builder: (context) => _buildAddLocationDialog(),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Dodaj Novu Lokaciju'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonBackground(context, Color(0xFF7C3AED)),
                foregroundColor: _buttonForeground(context, Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: parkings.map((p) {
            final parts = p.available.split('/');
            final occupied = int.tryParse(parts[0]) ?? 0;
            final total = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
            final percent = (total > 0) ? (occupied / total) : 0.0;
            final disabled = disabledParkings.contains(p.name);

            return SizedBox(
              width: 360,
              child: Opacity(
                opacity: disabled ? 0.6 : 1.0,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF7C3AED).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.directions_car, color: Color(0xFF7C3AED)),
                                ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('${p.available} mjesta', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text('Popunjenost', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                percent > 0.85 ? Colors.red : (percent > 0.5 ? Colors.orange : Colors.green)),
                          ),
                        ),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(percent * 100).round()}%'),
                            Text('\$${(occupied * p.pricePerHour).toStringAsFixed(2)}', style: TextStyle(color: Color(0xFF7C3AED))),
                          ],
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (disabled) {
                              // Re-enable immediately
                              setState(() {
                                disabledParkings.remove(p.name);
                              });
                            } else {
                              // Show disable confirmation dialog
                              showDialog(
                                context: context,
                                barrierColor: Color(0xFF1A237E),
                                barrierDismissible: false,
                                builder: (context) => _buildDisableDialog(p.name),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: disabled ? Colors.green : Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            minimumSize: Size(double.infinity, 44),
                          ),
                          child: Text(disabled ? 'Omogući' : 'Onemogući'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

Widget buildCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? theme.cardColor : Colors.white;
    final iconBg = isDark ? Colors.grey.shade800 : Color(0xFF1A1A2E);
    final titleColor = theme.textTheme.bodySmall?.color ?? Colors.black87;
    final valueColor = theme.colorScheme.primary;

    return Container(
      width: 250,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: iconBg,
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
                      Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }


class _HomePageState extends State<HomePage> {
  String selectedTab = 'search';
  String sortBy = 'Udaljenost';
  late TextEditingController _searchController;
  // which parking is hovered in the lower list / map
  String? hoveredParkingName;
  Timer? _hoverExitTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _hoverExitTimer?.cancel();
    super.dispose();
  }

  void _onHoverEnter(String name) {
    _hoverExitTimer?.cancel();
    if (hoveredParkingName != name) setState(() => hoveredParkingName = name);
  }

  void _onHoverExit() {
    _hoverExitTimer?.cancel();
    _hoverExitTimer = Timer(const Duration(milliseconds: 180), () {
      if (hoveredParkingName != null) setState(() => hoveredParkingName = null);
    });
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: textColor)),
      ],
    );
  }

  List<ParkingListing> get filteredAndSortedParkings {
    List<ParkingListing> filtered = parkings.where((p) {
      final searchText = _searchController.text.toLowerCase();
      return p.name.toLowerCase().contains(searchText) ||
             p.address.toLowerCase().contains(searchText);
    }).toList();

    // Sortiraj po odabranoj opciji
    switch (sortBy) {
      case 'Cijena':
        filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
        break;
      case 'Dostupnost':
        filtered.sort((a, b) {
          final aParts = a.available.split('/');
          final bParts = b.available.split('/');
          final aOccupied = int.tryParse(aParts[0]) ?? 0;
          final bOccupied = int.tryParse(bParts[0]) ?? 0;
          final aTotal = int.tryParse(aParts.length > 1 ? aParts[1] : '1') ?? 1;
          final bTotal = int.tryParse(bParts.length > 1 ? bParts[1] : '1') ?? 1;
          final aFree = aTotal - aOccupied;
          final bFree = bTotal - bOccupied;
          return bFree.compareTo(aFree); // više slobodnih mjesta = prvo
        });
        break;
      case 'Udaljenost':
      default:
        // Simulacija - u pravoj aplikaciji koristiti Google Maps API
        // Za sada drži originalnu listu
        break;
    }

    return filtered;
  }

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
        elevation: 0,
        title: Text(
          'ParkEasy',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineSmall?.color,
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
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9)),
                ),
                SizedBox(width: 12),
                // Theme toggle placed between welcome and logout (icon-only)
                DarkModeButton(),
                SizedBox(width: 8),
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
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).cardColor,
                          foregroundColor: selectedTab == 'search'
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white)
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => selectedTab = 'map'),
                    icon: Icon(Icons.map),
                    label: Text('Prikaz Mape'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedTab == 'map'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                      foregroundColor: selectedTab == 'map'
                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.black87 : Colors.white)
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),

            if (selectedTab == 'search') ...[
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {});
                  },
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
                itemCount: filteredAndSortedParkings.length,
                itemBuilder: (context, index) {
                  final parking = filteredAndSortedParkings[index];
                  return MouseRegion(
                    onEnter: (_) => _onHoverEnter(parking.name),
                    onExit: (_) => _onHoverExit(),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: hoveredParkingName == parking.name
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: ParkingCard(parking: parking),
                    ),
                  );
                },
              ),
            ] else if (selectedTab == 'map') ...[
              // Map view with title, legend, interactive pins and parking list below
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text('Interaktivna Mapa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    // legend
                    Row(
                      children: [
                        _legendDot(context, Colors.green, 'Dostupno'),
                        SizedBox(width: 12),
                        _legendDot(context, Colors.orange, 'Ograničeno'),
                        SizedBox(width: 12),
                        _legendDot(context, Colors.red, 'Skoro Puno'),
                      ],
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        height: 420,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF0B1220) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LayoutBuilder(builder: (context, constraints) {
                    // sample marker positions (relative) - 5 markers, closer together
                    // Tighter cluster (zoomed-in look) - 5 markers closer together
                    final centerX = constraints.maxWidth * 0.48;
                    final centerY = constraints.maxHeight * 0.4;
                              // slightly increase spacing between markers for clarity
                              final markerPositions = [
                                Offset(centerX - constraints.maxWidth * 0.09, centerY + constraints.maxHeight * 0.05),
                                Offset(centerX - constraints.maxWidth * 0.035, centerY - constraints.maxHeight * 0.03),
                                Offset(centerX + constraints.maxWidth * 0.045, centerY + constraints.maxHeight * 0.03),
                                Offset(centerX + constraints.maxWidth * 0.12, centerY - constraints.maxHeight * 0.06),
                                Offset(centerX - constraints.maxWidth * 0.025, centerY - constraints.maxHeight * 0.07),
                              ];
                    // compute marker ordering and widgets so we can render the hovered marker last
                    final availableCount = markerPositions.length < filteredAndSortedParkings.length
                        ? markerPositions.length
                        : filteredAndSortedParkings.length;
                    final indices = List<int>.generate(availableCount, (i) => i);
                    if (hoveredParkingName != null) {
                      final hoverIndex = filteredAndSortedParkings.indexWhere((p) => p.name == hoveredParkingName);
                      if (hoverIndex != -1 && hoverIndex < availableCount) {
                        indices.remove(hoverIndex);
                        indices.add(hoverIndex);
                      }
                    }
                    final markerWidgets = indices.map((i) => _MapMarker(
                          position: markerPositions[i],
                          parking: filteredAndSortedParkings[i],
                          highlighted: hoveredParkingName == filteredAndSortedParkings[i].name,
                          onEnter: (name) => _onHoverEnter(name),
                          onExit: () => _onHoverExit(),
                        )).toList();

                    return Stack(
                      children: [
                        // grid background
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _MapGridPainter(gridColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade300.withOpacity(0.6)),
                          ),
                        ),
                        // simulated "my location" blue circle near center
                        Positioned(
                          left: centerX - 12,
                          top: centerY - 12,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withOpacity(0.9),
                              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.25), blurRadius: 8, spreadRadius: 4)],
                            ),
                          ),
                        ),
                        // markers (hovered marker rendered last)
                        ...markerWidgets,
                      ],
                    );
                  }),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Parking list under the map (two-column responsive layout)
                    LayoutBuilder(builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 16) / 2;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: filteredAndSortedParkings.map((parking) {
                          return MouseRegion(
                            onEnter: (_) => _onHoverEnter(parking.name),
                            onExit: (_) => _onHoverExit(),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 180),
                              width: itemWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: hoveredParkingName == parking.name
                                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                    : Border.all(color: Colors.transparent),
                              ),
                              child: ParkingCard(parking: parking),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24),
            // Reservation history (user)
            Consumer<MyAppState>(builder: (context, state, child) {
              final history = state.rezervacije.reversed.toList();
              if (history.isEmpty) return SizedBox.shrink();
              return Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Istorija Rezervacija', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    ...history.map((r) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      Color badgeColor;
                      String statusLabel;
                      Color statusTextColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.black87;
                      if (r.status == 'aktivna') {
                        badgeColor = isDark ? Colors.green[800]!.withOpacity(0.2) : Colors.green.shade100;
                        statusLabel = 'Aktivna';
                        statusTextColor = isDark ? Colors.white.withOpacity(0.95) : Colors.black87;
                      } else if (r.status == 'otkazana') {
                        badgeColor = isDark ? Colors.red[800]!.withOpacity(0.18) : Colors.red.shade100;
                        statusLabel = 'Otkazana';
                        statusTextColor = isDark ? Colors.white.withOpacity(0.95) : Colors.black87;
                      } else {
                        badgeColor = isDark ? Colors.blueGrey[700]!.withOpacity(0.14) : Colors.blue.shade50;
                        statusLabel = 'Završena';
                        statusTextColor = isDark ? Colors.white.withOpacity(0.95) : Colors.black87;
                      }

                      final when = r.datum.toLocal().toString();
                      final amount = r.prihod.toStringAsFixed(2);
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${r.parkingName} - Mjesto #${r.mjestoBroj}', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 6),
                                    Text(when, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75))),
                                    SizedBox(height: 6),
                                    Text('Trajanje: ${r.durationHours} sat(a) • \$${amount}'),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
                                child: Text(statusLabel, style: TextStyle(color: statusTextColor)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Reusable dark-mode toggle button used across the app so it looks identical everywhere.
class DarkModeButton extends StatelessWidget {
  const DarkModeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppState>(builder: (context, s, _) {
      final isDark = Theme.of(context).brightness == Brightness.dark || s.isDarkMode;
      // Dark-mode appearance: darker circular background (not full scaffold), yellow sun icon
      // Light-mode appearance: white circular background, purple icon
      final theme = Theme.of(context);
      final bgColor = isDark ? theme.cardColor : Colors.white;
      final iconColor = isDark ? Colors.amber : theme.colorScheme.primary;
      final icon = isDark ? Icons.wb_sunny : Icons.nightlight_round;

      return SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: bgColor,
          shape: CircleBorder(),
          elevation: 0,
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              tooltip: s.isDarkMode ? 'Light mode' : 'Dark mode',
              onPressed: () => s.toggleTheme(),
              icon: Icon(icon, size: 18),
              color: iconColor,
            ),
          ),
        ),
      );
    });
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
    // 1. Move theme logic up here to avoid nested Builders and fix the 'iconBg' error
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Define colors once
    final iconBgColor = isDark 
        ? Colors.deepPurple.shade700.withOpacity(0.14) 
        : Colors.deepPurple.shade100;
    final primaryColor = theme.colorScheme.primary;
    final chipBgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed: The Container now uses the predefined iconBgColor
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.directions_car, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parking.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              parking.address,
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: parking.features.map((feature) {
                return Chip(
                  label: Text(
                    feature, 
                    style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)
                  ),
                  backgroundColor: chipBgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  // Material 3 chips often need small visual adjustments:
                  visualDensity: VisualDensity.compact, 
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dostupno:',
                      style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8), fontSize: 12),
                    ),
                    Text(
                      parking.available,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cijena:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '${parking.pricePerHour} KM', // Simplified string interpolation
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                // Using Consumer or Provider directly is cleaner than Builder if possible
                Consumer<MyAppState>(
                  builder: (context, appState, child) {
                    final hasActive = appState.aktivnaRezervacija() != null;
                    return ElevatedButton(
                      onPressed: hasActive
                          ? null
                          : () => showDialog(
                                context: context,
                                builder: (context) => ParkingSpaceSelectionDialog(parking: parking),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasActive ? Colors.grey.shade400 : Colors.deepPurple,
                        foregroundColor: Colors.white, // Ensure text is visible
                      ),
                      child: const Text(
                        'Rezerviši Sada',
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// Simple map grid painter for placeholder map
class _MapGridPainter extends CustomPainter {
  final Color gridColor;
  _MapGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = gridColor..strokeWidth = 1;
    final step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapMarker extends StatefulWidget {
  final Offset position;
  final ParkingListing parking;
  final bool highlighted;
  final void Function(String)? onEnter;
  final VoidCallback? onExit;
  const _MapMarker({required this.position, required this.parking, this.highlighted = false, this.onEnter, this.onExit, Key? key}) : super(key: key);

  @override
  State<_MapMarker> createState() => _MapMarkerState();
}

class _MapMarkerState extends State<_MapMarker> {
  bool hover = false;

  Timer? _localExitTimer;

  void _delayedLocalExit() {
    _localExitTimer?.cancel();
    _localExitTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => hover = false);
    });
  }

  @override
  void dispose() {
    _localExitTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MapMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent highlights this marker, ensure hover is shown; if parent un-highlights, hide it.
    if (widget.highlighted && !hover) {
      setState(() => hover = true);
    } else if (!widget.highlighted && hover) {
      setState(() => hover = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // if parent marks this marker highlighted (from list hover), show info box
    if (widget.highlighted && !hover) {
      hover = true;
    }
    final isDisabled = Provider.of<MyAppState>(context).aktivnaRezervacija() != null;
    // Larger pin sizing for zoomed-in feel
    final double pinSize = 48.0;
    return Positioned(
      left: widget.position.dx - pinSize / 2,
      top: widget.position.dy - pinSize,
      child: SizedBox(
        width: pinSize + 8,
        height: pinSize + 8,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Info box appears only when hovering over the pin or the box itself
            if (hover)
              Positioned(
                bottom: pinSize + 8,
                child: MouseRegion(
                  onEnter: (_) {
                    _localExitTimer?.cancel();
                    if (widget.onEnter != null) widget.onEnter!(widget.parking.name);
                    setState(() => hover = true);
                  },
                  onExit: (_) {
                    if (widget.onExit != null) widget.onExit!();
                    _delayedLocalExit();
                  },
                  child: _buildInfoBox(context, isDisabled),
                ),
              ),
            // Pin area: limit hover/tap to the icon only
            Positioned(
              bottom: 0,
                child: MouseRegion(
                onEnter: (_) {
                  _localExitTimer?.cancel();
                  if (widget.onEnter != null) widget.onEnter!(widget.parking.name);
                  setState(() => hover = true);
                },
                onExit: (_) {
                  if (widget.onExit != null) widget.onExit!();
                  _delayedLocalExit();
                },
                child: GestureDetector(
                  onTap: () => setState(() => hover = !hover),
                  child: _buildColoredPin(widget.parking, pinSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context, bool isDisabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 240,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.parking.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
          SizedBox(height: 6),
          Text(widget.parking.address, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dostupno: ${widget.parking.available}', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
              Text('\$${widget.parking.pricePerHour}/sat', style: TextStyle(color: theme.colorScheme.primary)),
            ],
          ),
          SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (!isDisabled) {
                  showDialog(context: context, builder: (context) => ParkingSpaceSelectionDialog(parking: widget.parking));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: isDark ? Colors.black87 : Colors.white,
              ),
              child: Text('Rezerviši Sada'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColoredPin(ParkingListing p, double size) {
    // determine availability color (green/yellow/red)
    Color color = Colors.red;
    try {
      final parts = p.available.split('/');
      final occupied = int.tryParse(parts[0]) ?? 0;
      final total = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;
      final free = (total - occupied).clamp(0, total);
      final ratio = total > 0 ? free / total : 0.0;
      if (ratio > 0.5) color = Colors.green;
      else if (ratio > 0.2) color = Colors.orange;
      else color = Colors.red;
    } catch (e) {
      color = Colors.red;
    }

    return Icon(Icons.location_on, color: color, size: size);
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
                        onTap: (space.status == SpaceStatus.available && Provider.of<MyAppState>(context, listen: false).aktivnaRezervacija() == null)
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
                  onPressed: (selectedSpaceId != null && Provider.of<MyAppState>(context, listen: false).aktivnaRezervacija() == null)
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

    final provider = Provider.of<MyAppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        bool useSaved = provider.hasSavedCard;
        bool saveNew = false;

        return StatefulBuilder(builder: (context, setState) {
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
                  if (provider.hasSavedCard) ...[
                    ListTile(
                      title: Text('Koristi spremljenu karticu'),
                      subtitle: Text(provider.savedCard?['masked'] ?? ''),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: useSaved,
                        onChanged: (v) => setState(() => useSaved = true),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          provider.clearSavedCard();
                          setState(() {
                            useSaved = false;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text('Unesi novu karticu'),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: useSaved,
                        onChanged: (v) => setState(() => useSaved = false),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                  if (!provider.hasSavedCard || !useSaved) ...[
                    TextFormField(
                      autocorrect: false,
                      enableSuggestions: false,
                      controller: cardController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Broj Kartice', counterText: ""),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                        LengthLimitingTextInputFormatter(19),
                        CardNumberFormatter(),
                      ],
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
                            decoration: InputDecoration(labelText: 'Datum Isteka', counterText: ""),
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
                            decoration: InputDecoration(labelText: 'CVV', counterText: ""),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: saveNew,
                          onChanged: (v) => setState(() => saveNew = v ?? false),
                        ),
                        SizedBox(width: 8),
                        Text('Zapamti ovu karticu za kasnije'),
                      ],
                    ),
                  ] else ...[
                    // showing saved card summary
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plaćate pomoću:'),
                          SizedBox(height: 6),
                          Text(provider.savedCard?['masked'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(provider.savedCard?['name'] ?? ''),
                        ],
                      ),
                    ),
                  ],
                ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Otkaži')),
              ElevatedButton(
                onPressed: () {
                  final appState = Provider.of<MyAppState>(context, listen: false);

                  // If paying with new card and user asked to save it
                  if ((!appState.hasSavedCard || !useSaved) && saveNew) {
                    appState.saveCard(
                      number: cardController.text,
                      name: nameController.text,
                      expiry: expiryController.text,
                    );
                  }

                  // create reservation
                  final novaRez = Rezervacija(
                    status: 'aktivna',
                    datum: DateTime.now(),
                    prihod: amount,
                    parkingName: widget.parking.name,
                    mjestoBroj: widget.mjestoBroj,
                    expiresAt: DateTime.now().add(Duration(minutes: 30)),
                    durationHours: trajanjeSati,
                    username: appState.currentUser ?? 'Nepoznato',
                  );
                  appState.dodajRezervaciju(novaRez);
                  appState.reserveSpace(widget.parking.name, widget.mjestoBroj);
                  Navigator.pop(context); // close payment dialog
                  Navigator.pop(context); // close reservation page
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uspješno rezervisano mjesto #${widget.mjestoBroj}')));
                },
                child: Text('Plati ${amount.toStringAsFixed(2)} KM'),
              ),
            ],
          );
        });
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Color(0xFF1f2937) : Colors.deepPurple.shade50;
    final headingColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rez.parkingName, style: TextStyle(fontWeight: FontWeight.bold, color: headingColor)),
                SizedBox(height: 4),
                Text('Mjesto #${rez.mjestoBroj}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.95))),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.redAccent),
                    SizedBox(width: 6),
                    Text(isArrived ? 'Preostalo vrijeme: ${_format(remaining)}' : 'Vrijeme za dolazak: ${_format(remaining)}', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
                if (rez.arrived)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Dolazak potvrđen ✅', style: TextStyle(color: Colors.greenAccent)),
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
              icon: Icon(Icons.qr_code_scanner, color: rez.arrived ? Colors.grey : Theme.of(context).colorScheme.primary),
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
              child: Text('Otkaži', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ],
      ),
    );
  }
}
