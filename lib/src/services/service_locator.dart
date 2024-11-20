import 'package:get_it/get_it.dart';
import 'package:recibo_facil/src/home/blocs/home_cubit.dart';
import 'package:recibo_facil/src/home/repositories/pdf_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Registrar el repositorio
  getIt.registerLazySingleton<PdfRepository>(() => PdfRepository());

  // Registrar el HomeCubit y pasarle el repositorio como dependencia
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<PdfRepository>()));
}
