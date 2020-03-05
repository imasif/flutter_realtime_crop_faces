import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:facelens_admin_app/common/Request.dart';
import 'package:facelens_admin_app/ui/UserProfilePage.dart';
import 'package:facelens_admin_app/ui/homepage.dart';
import 'package:facelens_admin_app/common/AppDrawer.dart';

class EnrollPage extends StatefulWidget {

  EnrollPage();
  
  @override
  _EnrollPageState createState() => _EnrollPageState();

  
}

class _EnrollPageState  extends State<EnrollPage> {
  dynamic _selectedDepartment;
  List<dynamic> _departments = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneControler = new TextEditingController(text: '01915601505');
  

  initState() {
    super.initState();
    getDepartments().then((val){
      setState(() {
        _departments = val;
      });
    });
  }

  getDepartments() {
    dynamic data = Request(url: 'http://192.168.1.209:5004/api/department/list',body: {}).get;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return 
      Scaffold(
        appBar: AppBar(title: Text("Enrollment")),
        drawer: AppDrawer(),
        body: Center(
          child: Form(
            key: _formKey,
            // autovalidate: true,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(50),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child:
                //   MultiSelect(
                //   autovalidate: false,
                //   titleText: 'Country of Residence',
                //   validator: (value) {
                //     if (value == null) {
                //       return 'Please select one or more option(s)2';
                //     }
                //   },
                //   errorText: 'Please select one or more option(s)1',
                //   dataSource: [
                //     {
                //       "display": "Australia",
                //       "value": 1,
                //     },
                //     {
                //       "display": "Canada",
                //       "value": 2,
                //     },
                //     {
                //       "display": "India",
                //       "value": 3,
                //     },
                //     {
                //       "display": "United States",
                //       "value": 4,
                //     }
                //   ],
                //   textField: 'display',
                //   valueField: 'value',
                //   filterable: true,
                //   required: true,
                //   onSaved: (value) {
                //     print('The value is $value');
                //   }
                // )
                  MultiSelect(
                    autovalidate: false,
                    titleText: "Department",
                    validator: (value) {
                      // print(value); 
                      if (value == null) {
                        return 'Please select one or more department(s)';
                      }
                      
                      
                      _selectedDepartment = value;
                      
                    },
                    hintText: 'Select department',
                    errorText: 'Please select one or more department(s)',
                    dataSource: _departments,
                    textField: 'Dpt_Name',
                    valueField: 'Dpt_ID',
                    filterable: true,
                    // required: true,
                    // value: ["dpt3056"],
                    onSaved: (value) {
                      print('The value is $value');
                    }
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: phoneControler,
                    style: TextStyle(
                        color: Colors.black,
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter a mobile number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                      ),
                      focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide: BorderSide(color: Colors.black)),
                      
                      labelText: 'Phone',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      hintText: 'Input phone number',
                      hintStyle: TextStyle(
                        color: Colors.black
                      ),
                      // helperText: 'Keep it short, this is just a demo.',
                      // errorText: 'Enter a mobile number',
                      prefixIcon: Icon(Icons.phone, color: Colors.black,),
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
                      if (_formKey.currentState.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.


                        print('validation ok');
                        print('selectedDepartment $_selectedDepartment');
                        print('phoneControler ${phoneControler.text}');

                        final snackBar = SnackBar(
                          content: Text('Yay! A SnackBar!'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                        );

                        // Find the Scaffold in the widget tree and use
                        // it to show a SnackBar.

                        dynamic data = await Request(url: 'http://192.168.1.209:5004/api/query/user_phone_validation',body: {"phone": '+88${phoneControler.text}'}).post();

                        print(data['message']);

                        // Scaffold.of(context).showSnackBar(snackBar);
                        if(data['message'] == 'No user found.'){
                        }else{
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctx) => UserProfile(data: json.encode(data))));
                        }

                        // setState(() {
                        //   curentView = profileView(json.encode(data));
                        // });
                      }
                    },
                    // child: Text('Next', style: TextStyle(color: Colors.black)),
                    child:
                      new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text('Next'),
                            new SizedBox(width: _width/30,),
                            new Icon(Icons.arrow_forward),
                          ],
                        )
                      ),
                    color: Colors.white,
                    borderSide: BorderSide(color: Colors.black),
                  )
                )
              ]
            )
          )
        )
      );
  }
  
}
