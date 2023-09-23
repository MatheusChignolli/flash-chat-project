import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool loading = false;
  String email = '';
  String password = '';
  late String? emailError = null;
  late String? passwordError = null;

  void cancelLoading() {
    setState(() {
      loading = false;
    });
  }

  void signIn() async {
    setState(() {
      loading = true;
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) {
          emailError = 'Email is required';
        }

        if (password.isEmpty) {
          passwordError = 'Password is required';
        }
      });

      cancelLoading();
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      Navigator.pushNamed(context, ChatScreen.id);
    } catch (error) {
      print('signIn error: $error');

      setState(() {
        if (error.toString().contains('invalid-email')) {
          emailError = 'Email is invalid';
          return;
        }

        emailError = 'Email is invalid';
        passwordError = 'Password is invalid';
      });
    }

    cancelLoading();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      color: Colors.lightBlueAccent,
      blur: 1,
      inAsyncCall: loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Colors.black,
                ),
                onChanged: (value) {
                  email = value;

                  setState(() {
                    emailError = null;
                  });
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                  errorText: emailError ?? null,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                style: TextStyle(
                  color: Colors.black,
                ),
                onChanged: (value) {
                  password = value;

                  setState(() {
                    passwordError = null;
                  });
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  errorText: passwordError ?? null,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Button(
                color: Colors.lightBlueAccent,
                text: 'Log In',
                onPressed: () {
                  signIn();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
