import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:recibo_facil/src/core/services/navigation_services.dart';
import 'package:recibo_facil/src/features/home/presentation/blocs/home_cubit.dart';
import 'package:recibo_facil/src/features/home/presentation/pages/bill_detail_screen.dart';
import 'package:recibo_facil/src/features/home/presentation/pages/home_screen.dart';
import 'package:recibo_facil/src/features/home/presentation/pages/pdf_viewer_bill.dart';

class Routes {
  static const String home = '/home';
  static const String detailBill = '/details';
  static const String pdfView = '/pdfView';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: GetIt.instance<NavigationService>().navigatorKey,
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        name: Routes.home,
        builder: (context, state) {
          final hasNavigated = state.extra as bool? ?? false;
          return HomeScreen(hasNavigated: hasNavigated);
        },
      ),
      GoRoute(
        path: Routes.detailBill,
        name: Routes.detailBill,
        builder: (context, state) {
          // final homeCubit = GetIt.instance<HomeCubit>();
          // final hasNavigated = state.extra as bool? ?? false;
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final hasNavigated = extras['hasNavigated'] as bool? ?? false;
          final homeCubit =
              extras['homeCubit'] as HomeCubit? ?? GetIt.instance<HomeCubit>();

          return BlocProvider.value(
            value: homeCubit,
            child: BillDetailScreen(
              hasNavigated: hasNavigated,
              homeCubit: homeCubit,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.pdfView,
        name: Routes.pdfView,
        builder: (context, state) {
          final homeCubit = GetIt.instance<HomeCubit>();
          return PdfViewerScreen(pdfPath: homeCubit.state.file!.path);
        },
      ),
    ],
  );
}
