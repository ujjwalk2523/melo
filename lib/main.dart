import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/database/database_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/player/providers/player_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MeloAudioHandler? audioHandler;
  SharedPreferences? sharedPreferences;

  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      audioHandler = await AudioService.init(
        builder: () => MeloAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.melo.app.melo.audio',
          androidNotificationChannelName: 'Melo Audio Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidShowNotificationBadge: true,
        ),
      );
    } catch (e) {
      debugPrint(
        'AudioService.init failed (safe fallback to in-app audio): $e',
      );
    }

    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('SharedPreferences init failed: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        if (audioHandler != null)
          audioHandlerProvider.overrideWithValue(audioHandler),
        if (sharedPreferences != null)
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MeloApp(),
    ),
  );
}

/// Root widget for the Melo Music Streaming Application.
class MeloApp extends ConsumerStatefulWidget {
  const MeloApp({super.key});

  @override
  ConsumerState<MeloApp> createState() => _MeloAppState();
}

class _MeloAppState extends ConsumerState<MeloApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerNotifierProvider.notifier).restoreSavedState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
