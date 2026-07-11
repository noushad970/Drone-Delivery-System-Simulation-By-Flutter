import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/providers.dart';
import 'data/services/storage_service.dart';
import 'features/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for the simulation.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialise offline storage once and inject it into the provider tree.
  final storage = await StorageService.create();

  runApp(
    ProviderScope(
      overrides: <Override>[
        storageProvider.overrideWithValue(storage),
      ],
      child: const DroneDeliveryApp(),
    ),
  );
}

class DroneDeliveryApp extends StatelessWidget {
  const DroneDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Delivery Simulation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
