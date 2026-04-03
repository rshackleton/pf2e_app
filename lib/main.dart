import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pf2e_app/app.dart';
import 'package:pf2e_app/locator.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

final di = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Configure all dependencies
  await configureDependencies();

  // Wait for async services to initialize (Auth0Service)
  await di.allReady();

  final sbUrl = dotenv.get('SUPABASE_URL');
  final sbKey = dotenv.get('SUPABASE_PUBLISHABLE_KEY');

  if (sbUrl.isEmpty || sbKey.isEmpty) {
    throw Exception(
      "Supabase URL and Key must be provided as environment variables.",
    );
  }

  // Initialize Supabase with auth callback from AuthManager
  await Supabase.initialize(
    url: sbUrl,
    anonKey: sbKey,
    accessToken: () async {
      final credentials = di<AuthManager>().credentials.value;
      return credentials?.idToken;
    },
  );

  runApp(const App());
}
