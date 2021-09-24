import 'package:flutter/material.dart';
import 'package:yogamates/ui/home_screen.dart';
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
    return InstaHomeScreen();
  }
}
class UserVariables extends ChangeNotifier {
  Map<int, bool> bookmarkMap = { 0: false, 1: false, 2: false, 3: false, 4: false, 5: false, 6: false,  7: false,  8: false,  9: false, 10: false, 11: false};
  void bookmark(int index) {
   bookmarkMap[index] = true;
  }
}
