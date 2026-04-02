import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pf2e_app/auth/auth.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("PF2e App - ${appFlavor ?? "Unknown Flavor"}"),
        ),
        body: Center(child: Auth()),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      title: "PF2e App",
    );
  }
}
