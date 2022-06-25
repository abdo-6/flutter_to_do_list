import 'dart:async';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoproject/ui/page_done.dart';
import 'package:todoproject/ui/page_info.dart';
import 'package:todoproject/ui/page_task.dart';


User? _currentUser;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  _currentUser = (await _signInAnonymously()).user;

  runApp(const MyApp());
}
final FirebaseAuth _auth = FirebaseAuth.instance;



Future<UserCredential> _signInAnonymously() async {
  final user = (await _auth.signInAnonymously()) ;
  return user;
}

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Taskist",
      home: HomePage(
        user: _currentUser!,
      ),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  

  final List<Widget> _children = [
    TaskPage(
      user: _currentUser!,
    ),
    DonePage(
      user: _currentUser!,
    ),
    SettingsPage(
      user: _currentUser!,
    )
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: _children[_selectedIndex],
        
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'TasksDone',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_sharp),
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  
}