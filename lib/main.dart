import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/database/database_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/utils/app_logger.dart';
import 'features/player/providers/player_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Production Global Uncaught Exception Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'FlutterError caught: ${details.exceptionAsString()}',
      category: LogCategory.general,
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!kReleaseMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      'PlatformDispatcher uncaught asynchronous error: $error',
      category: LogCategory.general,
      error: error,
      stackTrace: stack,
    );
    return true; // Marks error as handled to prevent native crash
  };

  // Graceful fallback UI in place of standard framework red screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }
    return Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: AppTypography.darkTextTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'An unexpected rendering issue occurred. Please restart the screen.',
                textAlign: TextAlign.center,
                style: AppTypography.darkTextTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };

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
      AppLogger.warning(
        'AudioService.init failed (safe fallback to in-app audio): $e',
        category: LogCategory.player,
      );
    }

    try {
      sharedPreferences = await SharedPreferences.getInstance();
    } catch (e) {
      AppLogger.warning(
        'SharedPreferences init failed: $e',
        category: LogCategory.general,
      );
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
