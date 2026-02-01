import 'package:chat_app/widgets/custombutton.dart';
import 'package:chat_app/widgets/customtextinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChatterLogin extends StatefulWidget {
  final VoidCallback onToggle;
  const ChatterLogin({Key? key, required this.onToggle}) : super(key: key);

  @override
  _ChatterLoginState createState() => _ChatterLoginState();
}

class _ChatterLoginState extends State<ChatterLogin> {
  String? email;
  String? password;
  bool loggingin = false;
  final _auth = FirebaseAuth.instance;

  void _showAlert(BuildContext context, String title, String description) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $description'),
        backgroundColor: Colors.deepPurple[900],
      ),
    );
  }

  bool _isLoginValid() {
    return (email?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false);
  }
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loggingin,
      child: Scaffold(
        // backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            // margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: 'heroicon',
                    child: Icon(
                      Icons.textsms,
                      size: 120,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Hero(
                    tag: 'HeroTitle',
                    child: Text(
                      'Chatter',
                      style: TextStyle(
                          color: Colors.deepPurple[900],
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  // Text(
                  //   "World's most private chatting app".toUpperCase(),
                  //   style: TextStyle(
                  //       fontFamily: 'Poppins',
                  //       fontSize: 12,
                  //       color: Colors.deepPurple),
                  // ),
                  CustomTextInput(
                    hintText: 'Email',
                    leading: Icons.mail,
                    obscure: false,
                    keyboard: TextInputType.emailAddress,
                    userTyped: (val) {
                      email = val;
                    },
                  ),
                  SizedBox(
                    height: 0,
                  ),
                  CustomTextInput(
                    hintText: 'Password',
                    leading: Icons.lock,
                    obscure: true,
                    userTyped: (val) {
                      password = val;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Hero(
                    tag: 'loginbutton',
                    child: CustomButton(
                      text: 'login',
                      accentColor: Colors.white,
                      mainColor: Colors.deepPurple,
                      onpress: () async {
                        if (_isLoginValid()) {
                          setState(() {
                            loggingin = true;
                          });
                          try {
                            final loggedUser =
                                await _auth.signInWithEmailAndPassword(
                                    email: email!, password: password!);
                            setState(() {
                              loggingin = false;
                            });
                            if (!mounted) return;
                          } catch (e) {
                            setState(() {
                              loggingin = false;
                            });
                            _showAlert(context, 'Login Failed', e.toString());
                          }
                        } else {
                          _showAlert(
                              context,
                              'Uh oh!',
                              'Please enter the email and password.');
                        }
                        // Navigator.pushReplacementNamed(context, '/chat');
                      },
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                      onTap: widget.onToggle,
                      child: Text(
                        'or create an account',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.deepPurple),
                      )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Hero(
                    tag: 'footer',
                    child: Text(
                      'Made with love by ishandeveloper',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
