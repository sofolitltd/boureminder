import 'package:bou_reminder/app.dart';
import 'package:bou_reminder/features/onboarding/application/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// These tests exercise the main shell directly, so they skip the
/// onboarding/pairing flow by overriding its completed state.
Widget _appPastOnboarding() => ProviderScope(
      overrides: [
        onboardingControllerProvider.overrideWithValue(const OnboardingData(completed: true)),
      ],
      child: const BouReminderApp(),
    );

void main() {
  testWidgets('app boots to home screen with bottom nav', (tester) async {
    await tester.pumpWidget(_appPastOnboarding());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('হোম'), findsOneWidget);
    expect(find.text('ফর্দ'), findsOneWidget);
    expect(find.text('দলিল'), findsOneWidget);
    expect(find.text('আরও'), findsOneWidget);
  });

  testWidgets('bottom nav switches tabs without errors', (tester) async {
    await tester.pumpWidget(_appPastOnboarding());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ফর্দ'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('এখনো কোনো ফর্দ নেই'), findsOneWidget);

    await tester.tap(find.text('দলিল'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('দলিল খালি'), findsOneWidget);

    await tester.tap(find.text('আরও'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('সেটিংস'), findsOneWidget);
  });

  testWidgets('quick-add sheet opens from the + button', (tester) async {
    await tester.pumpWidget(_appPastOnboarding());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('বাজারের ফর্দ'), findsOneWidget);
  });

  testWidgets('fresh app starts on the onboarding carousel', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BouReminderApp()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('আর কিছু ভুলবেন না'), findsOneWidget);
    expect(find.text('এড়িয়ে যান'), findsOneWidget);
  });

  testWidgets('onboarding -> sign-in -> otp -> profile -> pairing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BouReminderApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('এড়িয়ে যান'));
    await tester.pumpAndSettle();
    expect(find.text('শুরু করা যাক'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '01712345678');
    await tester.pumpAndSettle();
    await tester.tap(find.text('OTP পাঠান'));
    await tester.pumpAndSettle();
    expect(find.text('কোড দিয়ে যাচাই করুন'), findsOneWidget);

    final otpFields = find.byType(TextField);
    for (var i = 0; i < 6; i++) {
      await tester.enterText(otpFields.at(i), '${i + 1}');
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('নিজের পরিচয় দিন'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'নুসরাত');
    await tester.tap(find.text('👰'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('তারিখ বেছে নিন'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ঠিক আছে'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('চালিয়ে যান'));
    await tester.tap(find.text('চালিয়ে যান'));
    await tester.pumpAndSettle();
    expect(find.text('সঙ্গীকে যুক্ত করুন'), findsOneWidget);

    await tester.tap(find.text('কোড লিখুন'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsWidgets);
  });
}
