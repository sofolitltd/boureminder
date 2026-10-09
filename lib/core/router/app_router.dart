import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../dev_gallery/gallery_screen.dart';
import '../../features/bazar/presentation/bazar_lists_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/love_deed/presentation/deed_home_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/onboarding/application/onboarding_controller.dart';
import '../../features/onboarding/presentation/notification_primer_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/otp_screen.dart';
import '../../features/onboarding/presentation/pairing_scan_screen.dart';
import '../../features/onboarding/presentation/pairing_screen.dart';
import '../../features/onboarding/presentation/pairing_success_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/onboarding/presentation/sign_in_screen.dart';
import '../../features/onboarding/presentation/wedding_date_screen.dart';
import 'main_shell.dart';
import 'routes.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Mock, in-memory gate: redirect to onboarding until it's been completed
  // once this app session. There's no persistence yet (see
  // OnboardingController's doc comment), so this resets on every cold start.
  final onboardingCompleted = ref.watch(
    onboardingControllerProvider.select((state) => state.completed),
  );

  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final onOnboardingRoute = state.matchedLocation.startsWith(Routes.onboarding);
      if (!onboardingCompleted && !onOnboardingRoute) return Routes.onboarding;
      if (onboardingCompleted && onOnboardingRoute) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: Routes.otp, builder: (_, _) => const OtpScreen()),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(path: Routes.pairing, builder: (_, _) => const PairingScreen()),
      GoRoute(path: Routes.pairingScan, builder: (_, _) => const PairingScanScreen()),
      GoRoute(path: Routes.pairingSuccess, builder: (_, _) => const PairingSuccessScreen()),
      GoRoute(path: Routes.weddingDate, builder: (_, _) => const WeddingDateScreen()),
      GoRoute(path: Routes.notificationPrimer, builder: (_, _) => const NotificationPrimerScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.bazar, builder: (_, _) => const BazarListsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.deed, builder: (_, _) => const DeedHomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.more, builder: (_, _) => const MoreScreen())],
          ),
        ],
      ),
    ],
  );
}
