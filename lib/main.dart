import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pf2e_app/app.dart';

void main() {
  // Handle any platform-specific setup or configuration here
  switch (appFlavor) {
    case "development":
      break;

    case "staging":
      break;

    case "production":
      break;
  }

  runApp(const App());
}
