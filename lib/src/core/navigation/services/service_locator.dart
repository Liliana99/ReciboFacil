import 'package:get_it/get_it.dart';
import 'package:recibo_facil/src/core/navigation/services/navigation_services.dart';
import 'package:recibo_facil/src/features/data/repositories/pdf_repository.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Registrar el repositorio
  getIt.registerLazySingleton<PdfRepository>(() => PdfRepository());

  // Registrar el HomeCubit y pasarle el repositorio como dependencia
  getIt.registerLazySingleton<HomeCubit>(
      () => HomeCubit(getIt<PdfRepository>()));

  // Registrar el NavigationService como singleton
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
}
