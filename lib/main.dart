import 'package:flutter/material.dart';
import 'package:equb/ui/home_screen.dart';
import 'package:provider/provider.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Equb Financials',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.black,
            primaryIconTheme: IconThemeData(color: Colors.black),
            primaryTextTheme: TextTheme(
                title: TextStyle(color: Colors.black, fontFamily: "Aveny")),
            textTheme: TextTheme(title: TextStyle(color: Colors.black))),
        home: MultiProvider(
          providers: [ChangeNotifierProvider<UserVariables>(create: (context) => UserVariables())],
          child: homeWidget(),
        ));
  }
  Widget homeWidget(){
    return HomeScreen();
  }
}
class UserVariables extends ChangeNotifier {
  Map<String, bool> bookmarkMap = Map();
  void bookmark(String key) {
    bookmarkMap[key] = true;
  }
  void removeBookmark(String key){
    bookmarkMap.remove(key);
  }
}
