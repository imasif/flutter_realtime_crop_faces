import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:facelens_admin_app/common/Request.dart';
import 'package:facelens_admin_app/ui/homepage.dart';
import 'package:facelens_admin_app/ui/EnrollPage.dart';

class UserProfile extends StatelessWidget {
  final String data;

  const UserProfile({Key key, this.data}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   final _width = MediaQuery.of(context).size.width;
  //   final _height = MediaQuery.of(context).size.height;

  //   Map<String, dynamic> response = json.decode(data);

  //   Map<String, dynamic> userInfo = response['user_info'];
  //   List<dynamic> profilePicture = userInfo['Reg_Image_Directories'];
  //   print(profilePicture[0]);

  //   final String imgUrl = 'http://192.168.1.209:5004${profilePicture[0]}';

  //   Widget rowCell(int count, String type) => new Expanded(child: new Column(children: <Widget>[
  //     new Text('$count',style: new TextStyle(color: Colors.black),),
  //     new Text(type,style: new TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
  //   ],));

  //   return Scaffold(
  //     appBar: AppBar(title: Text('User')),
  //     body: Text(data)
  //   );
  // }


  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Map<String, dynamic> response = json.decode(data);

    Map<String, dynamic> userInfo = response['user_info'];
    String userId = userInfo['User_ID'];
    List<dynamic> profilePicture = userInfo['Reg_Image_Directories'];
    List<dynamic> departments = userInfo['Dpt_Names'];
    List<dynamic> zones = userInfo['Zone_Names'];

    

    final String imgUrl = 'http://192.168.1.209:5004${profilePicture[0]}';

    Widget rowCell(int count, String type) => new Expanded(child: new Column(children: <Widget>[
      new Text('$count',style: new TextStyle(color: Colors.black),),
      new Text(type,style: new TextStyle(color: Colors.black, fontWeight: FontWeight.normal))
    ],));
    
    return Scaffold(
      appBar: AppBar(title: Text('User')),
      body: Center(
        child: new Column(
          children: <Widget>[
            new SizedBox(height: _height/50,),
            new CircleAvatar(radius:_width<_height ? _width/7 : _height/7,backgroundImage: NetworkImage(imgUrl),),
            new SizedBox(height: _height/50,),
            new Text(userInfo['Name'], style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/16, color: Colors.black),),
            new Padding(padding: new EdgeInsets.only(top: _height/100, left: _width/8, right: _width/8),
              child:new Text('Email: ${userInfo['Email']}\nPhone: ${userInfo['Phone']}\nGender: ${userInfo['Gender']}',
                style: new TextStyle(fontWeight: FontWeight.normal, fontSize: _width/20,color: Colors.black),textAlign: TextAlign.left,
              )
            ),
            new SizedBox(height: _height/30,),
            new Text('Deparment(s)', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/20, color: Colors.black)),
            new Divider(height: _height/90, color: Colors.black,),
            new Container(
              height: 50.0,
              child: 
              ListView.builder
              (
                itemCount: departments.length,
                padding: EdgeInsets.only(left: _width/20, right: _width/20),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Row(children: <Widget>[
                    new Chip(
                      label: Text(departments[index]),
                    ),
                    new SizedBox(width: _width/30,),
                  ]);
                    // print(departments[index]);
                }
              )
            ),
            new SizedBox(height: _height/30,),
            new Text('Zone(s)', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: _width/20, color: Colors.black)),
            new Divider(height: _height/90, color: Colors.black,),
            new Container(
              height: 50.0,
              child:
              ListView.builder
              (
                itemCount: zones.length,
                padding: EdgeInsets.only(left: _width/20, right: _width/20),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Row(
                    children: <Widget>[
                      new Chip(
                        label: Text(zones[index]),
                      ),
                      new SizedBox(width: _width/30,),
                    ]
                  );
                }
              )
            ),
            new SizedBox(height: _height/30,),
            new Padding(
              padding: new EdgeInsets.only(left: _width/8, right: _width/8),
              child: new OutlineButton(
                onPressed: (){
                  // Navigator.of(context).push(
                  //   PageRouteBuilder(
                  //   opaque: false,
                  //   pageBuilder:
                  //     (BuildContext context, _, __) =>ConfirmationScreen()
                  //   )
                  // );
                  Navigator.of(context).push(new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new ConfirmationScreen(userId: userId);
                    },
                    fullscreenDialog: true));


                },
                child:
                new Container(
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Icon(Icons.done),
                      new SizedBox(width: _width/30,),
                      new Text('Confirm')
                    ],
                  )
                ),
                color: Colors.white,
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ],
            
        ),
      )
    );
  }
}

class ConfirmationScreen extends StatelessWidget {

  final String userId;
  final TextEditingController cardControler = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ConfirmationScreen({Key key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Info'),
        leading: new IconButton(
          icon: new Icon(Icons.close, color: Colors.white),
          onPressed: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            // Focus.clear(context);

            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context).pop();
            });
            
          },
        )
      ),
      body:
      Builder(
      // Create an inner BuildContext so that the onPressed methods
      // can refer to the Scaffold with Scaffold.of().
        builder: (BuildContext context) {
          return Container(
            color: Color.fromARGB(255, 33, 150, 243),
            child: Center(
              child: Form(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(20),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: cardControler,
                        style: TextStyle(
                            color: Colors.white,
                        ),
                        // validator: (value) {
                        //   if (value.isEmpty) {
                        //     return 'Enter a mobile number';
                        //   }
                        //   return null;
                        // },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(5.0))
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.white)),
                          
                          labelText: 'Card No.',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          hintText: 'Input number',
                          hintStyle: TextStyle(
                            color: Colors.white
                          ),
                          // helperText: 'Keep it short, this is just a demo.',
                          // errorText: 'Enter a mobile number',
                          prefixIcon: Icon(Icons.credit_card, color: Colors.white,),
                          prefixText: ' ',
                          // suffixText: ' *',
                          // suffixStyle: TextStyle(color: Colors.red),
                        ),
                        autocorrect: false
                      )
                    ),

                    Padding(
                      padding: EdgeInsets.all(10),
                      child: OutlineButton(
                        onPressed: () async {
                          print('userId: $userId');
                          print('cardNo: ${cardControler.text}');

                          dynamic data = {"Field": {"Card_Number": '${cardControler.text}'}, "Delete_Images": []};

                          dynamic submit = await Request(url: 'http://192.168.1.209:5004/api/update/user/$userId', body: data).formPost();

                          print('data: $data');
                          print('submit: $submit');

                          if(submit["User_Data_Updated"] == 0){
                            throw new Exception('sorry no data could be updated');
                          }

                          final snackBar = SnackBar(
                              content: Text('Great work done'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // Some code to undo the change.
                                },
                              ),
                            );

                          Scaffold.of(context).showSnackBar(snackBar);


                          FocusScope.of(context).requestFocus(new FocusNode());
                          // Focus.clear(context);

                          Future.delayed(const Duration(milliseconds: 100), () {
                            // Navigator.of(context).pop();
                            Navigator.of(context).pushNamed('/enroll');
                          });

                          // _scaffoldKey.currentState.showSnackBar(snackBar);
                          // Future.delayed(const Duration(milliseconds: 1000), () {
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => HomePage()));
                            // Navigator.of(context).push(
                            //   new PageRouteBuilder(
                            //     pageBuilder: (BuildContext context, _, __) {
                            //       return new EnrollPage();
                            //     },
                            //     transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                            //       return new FadeTransition(
                            //         opacity: animation,
                            //         child: child
                            //       );
                            //     }
                            //   )
                            // );
                            // Navigator.pushReplacementNamed(context, '/enroll');
                            // Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
                            //   builder: (BuildContext context) {
                            //     return new EnrollPage();
                            // });
                          // });
                          // Navigator.of(context).pop();
                          // SharedPreferences prefs = await SharedPreferences.getInstance();
                          // dynamic loginData = await Request(url: 'http://192.168.1.209:5004/admin_auth/login',body: {"email": emailControler.text, "password": passwordControler.text}).post();

                          // print(loginData);

                          // if(loginData != null){
                          //   prefs.setString('loginData', json.encode(loginData));
                          //   Navigator.pushReplacementNamed(context, '/home');
                          // }

                        },
                        child:
                        new Container(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text('Submit', style: TextStyle(color: Colors.white),),
                              new SizedBox(width: _width/30,),
                              new Icon(Icons.arrow_forward, color: Colors.white,),
                            ],
                          )
                        ),
                        color: Colors.white,
                        borderSide: BorderSide(color: Colors.white),
                      )
                    )
                  ]
                )
              )
            )
          );
        }
      )
    );
  }
}
