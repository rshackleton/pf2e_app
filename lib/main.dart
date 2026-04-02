import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pf2e_app/app.dart';
import 'package:pf2e_app/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env", mergeWith: Platform.environment);

  // Handle any platform-specific setup or configuration here
  switch (appFlavor) {
    case "development":
      break;

    case "staging":
      break;

    case "production":
      break;
  }

  WidgetsFlutterBinding.ensureInitialized();

  final sbUrl = dotenv.get('SUPABASE_URL');
  final sbKey = dotenv.get('SUPABASE_PUBLISHABLE_KEY');

  if (sbUrl.isEmpty || sbKey.isEmpty) {
    throw Exception(
      "Supabase URL and Key must be provided as environment variables.",
    );
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: sbUrl,
    anonKey: sbKey,
    accessToken: () async {
      final hasSession = await AuthService().hasSession();

      if (!hasSession) {
        return null;
      }

      final session = await AuthService().session();
      return session.accessToken;
    },
  );

  runApp(const App());
}
