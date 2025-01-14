import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:recibo_facil/src/core/navigation/services/navigation_services.dart';
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
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: HomeScreen(
              hasNavigated: state.extra as bool? ?? false,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: Duration(milliseconds: 700),
          );
        },
      ),
      GoRoute(
        path: Routes.detailBill,
        name: Routes.detailBill,
        pageBuilder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          final hasNavigated = extras['hasNavigated'] as bool? ?? false;
          final homeCubit =
              extras['homeCubit'] as HomeCubit? ?? GetIt.instance<HomeCubit>();

          return CustomTransitionPage(
            key: state.pageKey,
            child: BlocProvider.value(
              value: homeCubit,
              child: BillDetailScreen(
                hasNavigated: hasNavigated,
                homeCubit: homeCubit,
              ),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: Duration(milliseconds: 700),
          );
        },
      ),
      GoRoute(
        path: Routes.pdfView,
        name: Routes.pdfView,
        pageBuilder: (context, state) {
          final homeCubit = GetIt.instance<HomeCubit>();
          return CustomTransitionPage(
            key: state.pageKey,
            child: PdfViewerScreen(pdfPath: homeCubit.state.file!.path),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: Duration(milliseconds: 700),
          );
        },
      ),
    ],
  );
}
