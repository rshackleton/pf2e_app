import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl_standalone.dart';
import 'package:pf2e_app/app.dart';
import 'package:pf2e_app/features/auth/manager/auth_manager.dart';
import 'package:pf2e_app/locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final di = GetIt.instance;

Future<void> main() async {
  // Setup Intl package with the device locale.
  await findSystemLocale();

  // Setup date formatting rules using the device locale.
  await initializeDateFormatting();

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
      // This is called when a supabase query is triggered, therefore we
      // can directly access credentials as we would already have initialised
      final authManager = di<AuthManager>();
      return authManager.credentials.value?.accessToken;
    },
  );

  runApp(App());
}
