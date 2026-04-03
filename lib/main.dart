import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:pf2e_app/app.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';
import 'package:pf2e_app/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  await configureDependencies();
  await di.allReady();

  final sbUrl = dotenv.get('SUPABASE_URL');
  final sbKey = dotenv.get('SUPABASE_PUBLISHABLE_KEY');

  if (sbUrl.isEmpty || sbKey.isEmpty) {
    throw Exception(
      "Supabase URL and Key must be provided as environment variables.",
    );
  }

  await Supabase.initialize(
    url: sbUrl,
    anonKey: sbKey,
    accessToken: () async {
      final authService = di<AuthService>();
      final credentials = await authService.getSession();
      return credentials?.idToken;
    },
  );

  runApp(App());
}
