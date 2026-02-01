// import 'package:chat_app/pages/chat.dart';
import 'package:chat_app/pages/firebase_options.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(ChatterApp());
}

class ChatterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatter',

      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return AuthSwitcher();
      },
    );
  }
}

class AuthSwitcher extends StatefulWidget {
  @override
  State<AuthSwitcher> createState() => _AuthSwitcherState();
}

class _AuthSwitcherState extends State<AuthSwitcher> {
  bool showLogin = true;

  void _toggle() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return ChatterLogin(onToggle: _toggle);
    }
    return ChatterSignUp(onToggle: _toggle);
  }
}
