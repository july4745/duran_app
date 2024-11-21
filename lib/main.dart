import 'package:flutter/material.dart';
import '../home/home.dart';
import '../date/fragrance_date.dart';
import 'screens/history.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // ภาษาอังกฤษ
        const Locale('th'), // ภาษาไทย
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/FragranceDate': (context) => FragranceDate(),
        '/History': (context) => History(),
        '/Home': (context) => HomeState(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _page = [];

  @override
  void initState() {
    super.initState();
    _page.addAll([HomeState(), FragranceDate(), History()]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/home.png',
              width: 30,
              height: 30,
              color: _selectedIndex == 0
                  ? const Color.fromARGB(255, 26, 161, 31)
                  : Colors.grey,
            ),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/schedule.png',
              width: 30,
              height: 30,
              color: _selectedIndex == 1
                  ? const Color.fromARGB(255, 26, 161, 31)
                  : Colors.grey,
            ),
            label: 'คำนวณวัน',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/history.png',
              width: 30,
              height: 30,
              color: _selectedIndex == 2
                  ? const Color.fromARGB(255, 26, 161, 31)
                  : Colors.grey,
            ),
            label: 'ประวัติ',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 26, 161, 31),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
