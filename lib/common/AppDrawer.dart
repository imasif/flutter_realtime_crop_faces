import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer();


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

    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader,
          ListTile(
            title: Text('Home'),
            onTap: () async {
              // Update the state of the app
              // setState(() {
              //   _showVal = 'Itemed 1';
              //   _appBarTitle = 'Main';
              //   curentView = mainView();
              // });
              // await this.getLoginData();
              // print(this.loginData);
              // Then close the drawer
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          ListTile(
            title: Text('Enroll'),
            onTap: () {
              // Update the state of the app
              // setState(() {
              //   _showVal = 'Enroll 1';
              //   _appBarTitle = 'Enrollment';
              //   curentView = EnrollPage();
              // });
              // Navigator.pop(context);

              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/enroll');

              // Navigator.pushReplacementNamed(context, '/enroll');
            },
          ),
          ListTile(
            title: Text('Face'),
            onTap: () {
              // Update the state of the app
              // setState(() {
              //   _showVal = 'Profile';
              //   _appBarTitle = 'Profile';
              //   // curentView = profileView();
              // });
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/faceDetect');

              // Navigator.pushReplacementNamed(context, '/enroll');
            },
          ),
          ListTile(
            title: Text('Log out'),
            onTap: () async {
              // Update the state of the app
              /*setState(() {
                _showVal = 'Itemed 2';
                _appBarTitle = 'Title 2';
              });*/

              await this.removeLoginData();

              // widget.callback("login");
              // Then close the drawer
              // Navigator.pop(context);
              // Navigator.pushNamed(context, '/');
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');

            },
          ),
        ],
      ),
    );
  }

}