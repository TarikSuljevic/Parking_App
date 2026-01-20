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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.fromLTRB(170.0, 20, 170, 100),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.ime});

  final String ime;
  @override
  State<HomePage> createState() => _HomePageState();
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
      pricePerHour: '\$5.00/sat',
    ),
    ParkingListing(
      name: 'Gradska Garaža',
      address: 'Trg Slobode 456, Centar',
      features: ['Pokriveno', 'Valet Usluga', 'Autopraonica'],
      available: '12/150',
      pricePerHour: '\$6.50/sat',
    ),
    ParkingListing(
      name: 'Parking kod Rijeke',
      address: 'Riječna Obala 789, Riverside',
      features: ['Na otvorenom', 'Video nadzor'],
      available: '78/100',
      pricePerHour: '\$3.50/sat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('ParkEasy', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Dobrodošli, ${widget.ime}', style: TextStyle(color: Colors.black54)),
                SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  child: Text('Odjavi se', style: TextStyle(color: Colors.deepPurple)),
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
                      backgroundColor: selectedTab == 'search' ? Colors.deepPurple : Colors.grey.shade300,
                      foregroundColor: selectedTab == 'search' ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => selectedTab = 'map'),
                    icon: Icon(Icons.map),
                    label: Text('Prikaz Mape'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedTab == 'map' ? Colors.deepPurple : Colors.grey.shade300,
                      foregroundColor: selectedTab == 'map' ? Colors.white : Colors.black,
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
                  hintText: 'Pretražite po lokaciji, adresi ili nazivu parkinga...',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: sortBy,
                    items: ['Udaljenost', 'Cijena', 'Dostupnost'].map((String value) {
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
  final String pricePerHour;

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
                      Text(parking.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(child: Text(parking.address, style: TextStyle(color: Colors.grey, fontSize: 12))),
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
                    Text('Dostupno:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(parking.available, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cijena:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(parking.pricePerHour, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: Text('Rezerviši Sada', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}