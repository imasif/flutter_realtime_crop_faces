import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facelens_admin_app/common/Request.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  static final CREATE_POST_URL = 'http://192.168.1.209:5004/admin_auth/login';
  TextEditingController emailControler = new TextEditingController(text: 'bmabir17@gmail.com');
  TextEditingController passwordControler = new TextEditingController(text: 'arrows');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 26, 26, 26),
        child: Center(
          child: Form(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(20),
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Image.asset('assets/facelens_logo_white.png'),
                  ),
                ),
                TextFormField(
                  controller: emailControler,
                  style: TextStyle(
                      color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.white)),
                    
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Colors.white
                    ),
                    hintText: 'Input email',
                    hintStyle: TextStyle(
                      color: Colors.white
                    ),
                    // helperText: 'Keep it short, this is just a demo.',
                    prefixIcon: Icon(Icons.email, color: Colors.white,),
                    prefixText: ' ',
                    // suffixText: 'USD',
                    // suffixStyle: const TextStyle(color: Colors.green),
                  ),
                  autovalidate: true,
                  autocorrect: false
                ),
                SizedBox(height: 14.0),
                TextFormField(
                  controller: passwordControler,
                  style: TextStyle(
                      color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: Colors.white
                    ),
                    hintText: 'Input password',
                    hintStyle: TextStyle(
                      color: Colors.white
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.white,),
                    prefixText: ' ',
                  ),
                  obscureText: true,
                  autovalidate: true,
                  autocorrect: false
                ),
                SizedBox(height: 24.0),
                FlatButton(
                  onPressed: () async {
                    // print(emailControler.text);
                    // print(passwordControler.text);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    dynamic loginData = await Request(url: CREATE_POST_URL, body: {"email": emailControler.text, "password": passwordControler.text}).post();

                    print(loginData);

                    if(loginData != null){
                      prefs.setString('loginData', json.encode(loginData));
                      Navigator.pushReplacementNamed(context, '/home');
                    }

                  },
                  child: Text('Log In', style: TextStyle(color: Colors.black)),
                  color: Colors.white,
                )
              ]
            )
          )
        )
      )
    );
  }
}

