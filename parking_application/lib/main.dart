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
            Container(
              padding: EdgeInsets.all(0.1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.deepPurple, width: 3), // boja i debljina border-a
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                
              
              
              
                  child: Icon(Icons.local_parking_rounded, size: 60, color: Colors.deepPurple)
              ),
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
            padding: const EdgeInsets.fromLTRB(12.0, 100.0, 12.0, 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(children: [
         BackButton(
      // child:
    
    
    ),
    Text("Nazad"),
    ],),
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
                          Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => Placeholder())
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
  }}



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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ParkingSpaceSelectionDialog(parking: parking),
                    );
                  },
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

class ParkingSpaceSelectionDialog extends StatefulWidget {
  final ParkingListing parking;

  const ParkingSpaceSelectionDialog({super.key, required this.parking});

  @override
  State<ParkingSpaceSelectionDialog> createState() => _ParkingSpaceSelectionDialogState();
}

class _ParkingSpaceSelectionDialogState extends State<ParkingSpaceSelectionDialog> {
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
    
    // Generate parking spaces with random statuses
    spaces = List.generate(totalSpaces, (index) {
      final spaceId = index + 1;
      // Distribute spaces: available (green), reserved (orange), occupied (red)
      if (index < availableSpaces) {
        return ParkingSpace(id: spaceId, status: SpaceStatus.available);
      } else if (index < availableSpaces + (totalSpaces - availableSpaces) ~/ 2) {
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  LegendItem(color: Colors.green, label: 'Dostupno (${availableSpaces})'),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Mjesto broj $selectedSpaceId je rezervisano'),
                              backgroundColor: Colors.green,
                            ),
                          );
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

enum SpaceStatus {
  available,
  reserved,
  occupied,
}

class ParkingSpace {
  final int id;
  final SpaceStatus status;

  ParkingSpace({required this.id, required this.status});
}
