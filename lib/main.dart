import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:recibo_facil/src/home/blocs/home_cubit.dart';
import 'package:recibo_facil/src/services/service_locator.dart';

import 'src/app.dart';
import 'src/home/repositories/pdf_repository.dart';
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
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final pdfRepository = PdfRepository();

  runApp(BlocProvider(
    create: (context) => getIt<HomeCubit>(),
    child: MyApp(settingsController: settingsController),
  ));
}
