import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:facelens_admin_app/common/AppDrawer.dart';
import 'package:facelens_admin_app/common/Request.dart';
import 'package:facelens_admin_app/ui/loginpage.dart';
import 'package:facelens_admin_app/ui/EnrollPage.dart';


class HomePage extends StatefulWidget {

  HomePage();

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  String _appBarTitle = "init page";
  var loginData;


  getLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    this.loginData = prefs.get('loginData');
  }

  removeLoginData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('loginData');
  }
  

  @override
  Widget build(BuildContext context) {
    final DrawerHeader = UserAccountsDrawerHeader(
      accountName: Text('MD. Asif Khan'),
      accountEmail: Text('imasifkhan1010@gmail.com'),
      currentAccountPicture: CircleAvatar(
        child: FlutterLogo(size: 42.0,),
        backgroundColor: Colors.white,
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)),
      body: Center( child: Text('Main') ),
      drawer: AppDrawer(),
      // drawer: Drawer(
      //   // Add a ListView to the drawer. This ensures the user can scroll
      //   // through the options in the drawer if there isn't enough vertical
      //   // space to fit everything.
      //   child: ListView(
      //     // Important: Remove any padding from the ListView.
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       DrawerHeader,
      //       ListTile(
      //         title: Text('Nav 1'),
      //         onTap: () async {
      //           // Update the state of the app
      //           setState(() {
      //             _showVal = 'Itemed 1';
      //             _appBarTitle = 'Main';
      //             curentView = mainView();
      //           });
      //           await this.getLoginData();
      //           print(this.loginData);
      //           // Then close the drawer
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         title: Text('Enroll'),
      //         onTap: () {
      //           // Update the state of the app
      //           // setState(() {
      //           //   _showVal = 'Enroll 1';
      //           //   _appBarTitle = 'Enrollment';
      //           //   curentView = EnrollPage();
      //           // });
      //           // Navigator.pop(context);

      //           Navigator.of(context).pop();
      //           Navigator.of(context).pushNamed('/enroll');

      //           // Navigator.pushReplacementNamed(context, '/enroll');
      //         },
      //       ),
      //       ListTile(
      //         title: Text('Profile'),
      //         onTap: () {
      //           // Update the state of the app
      //           setState(() {
      //             _showVal = 'Profile';
      //             _appBarTitle = 'Profile';
      //             // curentView = profileView();
      //           });
      //           Navigator.pop(context);

      //           // Navigator.pushReplacementNamed(context, '/enroll');
      //         },
      //       ),
      //       ListTile(
      //         title: Text('Log out'),
      //         onTap: () {
      //           // Update the state of the app
      //           /*setState(() {
      //             _showVal = 'Itemed 2';
      //             _appBarTitle = 'Title 2';
      //           });*/

      //           this.removeLoginData();

      //           // widget.callback("login");
      //           // Then close the drawer
      //           // Navigator.pop(context);
      //           // Navigator.pushNamed(context, '/');
      //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => LoginPage()));
 
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}