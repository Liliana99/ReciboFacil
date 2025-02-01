import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:window_manager/window_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';
import 'package:recibo_facil/src/core/navigation/services/service_locator.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.

  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  setupServiceLocator();
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  WidgetsFlutterBinding.ensureInitialized();

// Inicializar Sentry sin DSN
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://bfd9f190ce053d834b15ddfee56ae347@o4508692452409344.ingest.de.sentry.io/4508692455489616';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () {
      // Bloquear orientación en modo vertical
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp, // Solo orientación vertical
      ]).then((_) async {
        // Configurar el tamaño mínimo en macOS y Windows
        if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.macOS ||
                defaultTargetPlatform == TargetPlatform.windows)) {
          await windowManager.ensureInitialized();
          windowManager
              .setMinimumSize(const Size(400, 700)); // Mínimo de 400px de ancho
        }

        runApp(
          BlocProvider(
            create: (context) => getIt<HomeCubit>(),
            child: MyApp(settingsController: settingsController),
          ),
        );
      });
    },
  );
}
