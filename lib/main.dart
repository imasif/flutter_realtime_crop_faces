import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/loginpage.dart';
import 'ui/homepage.dart';
import 'ui/EnrollPage.dart';
import 'ui/camera_preview/camera_preview_scanner.dart';

void main() => runApp(RTFaceCrop());

class RTFaceCrop extends StatefulWidget {
  final appTitle = 'Facelens Admin';

  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<RTFaceCrop>{
  String initRoute;
  var _loginData;
  
  getLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.get('loginData');
  }


  @override
  initState() {
    super.initState();
    getLoginData().then((loginData){
    // print('loginData in');
    print(loginData);
      setState(() {
          _loginData = loginData;
      });
    });
  }

  // callback(newInit) {
  //     setState(() {
  //       initRoute = newInit;
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    // print('loginData out');
    dynamic _initPage;
    if(_loginData == null){
      _initPage = LoginPage();
    }else{
      if(json.decode(_loginData)['data'] == null){
        _initPage = LoginPage();
      }else{
        _initPage = HomePage();
      }
    }
    // print();

      return MaterialApp(
        home: CameraPreviewScanner(),
        routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => new LoginPage(),
        '/home': (BuildContext context) => new HomePage(),
        '/enroll': (BuildContext context) => new EnrollPage(),
        '/faceDetect': (BuildContext context) => new CameraPreviewScanner()
      },
      );
    // if(_loginData == null){
    //   return MaterialApp(
    //     home: LoginPage()
    //   );
    // }
    // else{
      // return MaterialApp(
      //   //title: appTitle,
      //   initialRoute: '/',
      //   routes: {
      //     '/': (context) => HomePage(),
      //   }
      // );
      // return MaterialApp(
      //   home: HomePage()
      // );
    // }
  }

}





/*import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

// #docregion MyApp
class MyApp extends StatelessWidget {
  // #docregion build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: RandomWords(),
    );
  }
  // #enddocregion build
}
// #enddocregion MyApp

// #docregion RWS-var
class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final Set<WordPair> _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  // #enddocregion RWS-var

  // #docregion _buildSuggestions
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_suggestions[index]);
        });
  }
  // #enddocregion _buildSuggestions

  // #docregion _buildRow
  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }
  // #enddocregion _buildRow

  // #docregion RWS-build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: _buildSuggestions(),
    );
  }
  // #enddocregion RWS-build
  // #docregion RWS-var
}
// #enddocregion RWS-var

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}*/