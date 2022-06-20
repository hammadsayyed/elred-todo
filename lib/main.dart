import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/auth_page.dart';
import 'pages/home_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final Future<FirebaseApp> _initiazation = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initiazation,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
            print("Something went Wrong..");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            themeMode: ThemeMode.system,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                colorScheme: ColorScheme(
                    brightness: Brightness.light,
                    primary: Colors.blueAccent,
                    onPrimary: Colors.blueGrey,
                    secondary: Colors.black,
                    onSecondary: Colors.blue,
                    error: Colors.black,
                    onError: Colors.black,
                    background: Colors.blue,
                    onBackground: Colors.blue,
                    surface: Colors.white,
                    onSurface: Colors.blue)),
            home: MainPage(),
          );
        }

        return CircularProgressIndicator();
      },
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
            body: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    return HomeListPage();
                  } else {
                    return AuthPage();
                  }
                })),
      );
}
