import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/button.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
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

  void signUp() async {
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
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      print('newUser: $newUser');
      Navigator.pushNamed(context, ChatScreen.id);
    } catch (error) {
      print(error);
      setState(() {
        if (error.toString().contains('invalid-email')) {
          emailError = 'Email is invalid';
          return;
        }

        if (error
            .toString()
            .contains('Password should be at least 6 characters')) {
          passwordError = 'Password should be at least 6 characters';
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
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;

                  setState(() {
                    passwordError = null;
                  });
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                  errorText: emailError ?? null,
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
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;

                  setState(() {
                    emailError = null;
                  });
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                  errorText: passwordError ?? null,
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              Button(
                color: Colors.blueAccent,
                text: 'Register',
                onPressed: signUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
