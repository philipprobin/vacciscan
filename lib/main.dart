import 'package:VaccineCheck/util/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/vaccination_certificate_screen.dart';
import 'screens/travel_vaccination_screen.dart';
import 'screens/scan_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  static final GlobalKey<_HomeScreenState> homeScreenKey = GlobalKey<_HomeScreenState>();

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = [
    const VaccinationCertificateScreen(),
    const ScanScreen(),
    const TravelVaccinationScreen(),
  ];

  void setPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: AppColors.primaryColor, // Set the primary color here
        items: const [
          TabItem(icon: Icons.list_alt, title: 'Vac. Cert'),
          TabItem(icon: Icons.qr_code_scanner, title: ''),
          TabItem(icon: Icons.travel_explore, title: 'Travel'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int i) {
          setState(() {
            _currentIndex = i;
          });
        },
      ),
    );
  }
}
