// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Bou Reminder';

  @override
  String get navHome => 'Home';

  @override
  String get navBazar => 'Lists';

  @override
  String get navDeed => 'Deed';

  @override
  String get navMore => 'More';

  @override
  String get quickAddBazar => 'Shopping list';

  @override
  String get quickAddChore => 'Chore request';

  @override
  String get quickAddDeed => 'Write a deed';

  @override
  String get quickAddCase => 'File a case';

  @override
  String get quickAddChoreLog => 'Chore log';

  @override
  String get quickAddPromise => 'Promise';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeGreetingNight => 'Good night';

  @override
  String get emptyBazarTitle => 'No lists yet';

  @override
  String get emptyBazarBody => 'No shopping lists yet. Make your first one!';

  @override
  String get emptyBazarAction => 'New list';

  @override
  String get emptyCaseTitle => 'No cases';

  @override
  String get emptyCaseBody => 'No cases yet. Peace at home! 🕊️';

  @override
  String get emptyDeedTitle => 'Deed is empty';

  @override
  String get emptyDeedBody =>
      'Write your first letter today. A small kind word is enough.';

  @override
  String get emptyDeedAction => 'Write';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get galleryTitle => 'Component gallery';

  @override
  String get obSkip => 'Skip';

  @override
  String get obNext => 'Next';

  @override
  String get obStart => 'Let\'s start';

  @override
  String get obTitle1 => 'Never forget again';

  @override
  String get obBody1 =>
      'Birthdays, anniversaries, promises. We\'ll remind you right on time.';

  @override
  String get obTitle2 => 'Send a list in one tap';

  @override
  String get obBody2 =>
      'Send a shopping list and watch live as items get checked off.';

  @override
  String get obTitle3 => 'One kind word a day';

  @override
  String get obBody3 =>
      'Write something secretly for your partner. One day it\'ll become the sweetest gift.';

  @override
  String get obTitle4 => 'A little bit of teasing';

  @override
  String get obBody4 =>
      'Who hung the mosquito net? File a case, deliver a verdict, have a laugh.';

  @override
  String get signInTitle => 'Let\'s get started';

  @override
  String get signInSubtitle => 'Sign in with your phone number';

  @override
  String get signInPhoneLabel => 'Phone number';

  @override
  String get signInPhoneHint => '01xxxxxxxxx';

  @override
  String get signInSendOtp => 'Send OTP';

  @override
  String get signInOr => 'or';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get signInApple => 'Sign in with Apple';

  @override
  String get signInTerms => 'By continuing you agree to the terms.';

  @override
  String get otpTitle => 'Verify with the code';

  @override
  String otpSubtitle(Object phone) {
    return 'A 6-digit code was sent to $phone';
  }

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpResend => 'Resend';

  @override
  String otpResendIn(Object seconds) {
    return 'Resend in (${seconds}s)';
  }

  @override
  String get otpWrong => 'Wrong code, try again';

  @override
  String get profileTitle => 'Tell us about yourself';

  @override
  String get profileSubtitle => 'Your partner will see this info';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileNicknameLabel => 'Nickname';

  @override
  String get profileNicknameHint => 'e.g. \"Madam\" or \"Sir\"';

  @override
  String get profileRoleLabel => 'Who are you?';

  @override
  String get profileRoleHusband => 'Husband';

  @override
  String get profileRoleWife => 'Wife';

  @override
  String get profileBirthdayLabel => 'Birthday';

  @override
  String get profileBirthdayPick => 'Pick a date';

  @override
  String get profileContinue => 'Continue';

  @override
  String get pairingTitle => 'Connect with your partner';

  @override
  String get pairingTabShare => 'My code';

  @override
  String get pairingTabEnter => 'Enter code';

  @override
  String get pairingShareHint =>
      'Give this code to your partner. It works for 24 hours.';

  @override
  String pairingCodeExpiry(Object hours) {
    return 'Expires in $hours hours';
  }

  @override
  String get pairingCopyCode => 'Copy code';

  @override
  String get pairingCopied => 'Code copied';

  @override
  String pairingShareText(Object code, Object link) {
    return 'Let\'s connect on Bou Reminder! Code: $code 👉 $link';
  }

  @override
  String get pairingEnterHint => 'Have your partner\'s code? Enter it here';

  @override
  String get pairingEnterLabel => 'Pairing code';

  @override
  String get pairingScanButton => 'Scan QR';

  @override
  String get pairingSubmit => 'Connect';

  @override
  String get pairingSkip => 'Continue in solo mode';

  @override
  String get pairingErrorInvalid => 'This code isn\'t valid';

  @override
  String get pairingErrorExpired => 'This code has expired';

  @override
  String get pairingErrorOwnCode => 'You can\'t use your own code';

  @override
  String pairingSameRoleWarning(Object role) {
    return 'You both picked \"$role\". Is that right?';
  }

  @override
  String get pairingSameRoleContinue => 'That\'s fine';

  @override
  String get scanTitle => 'Scan QR code';

  @override
  String get scanHint => 'Bring your partner\'s QR code into the frame';

  @override
  String get scanTorchOn => 'Turn on torch';

  @override
  String get scanTorchOff => 'Turn off torch';

  @override
  String get pairingSuccessTitle => 'You\'re connected! 💞';

  @override
  String pairingSuccessBody(Object partner) {
    return 'You\'re now paired with $partner';
  }

  @override
  String get pairingSuccessContinue => 'Continue';

  @override
  String get weddingDateTitle => 'When\'s your anniversary?';

  @override
  String get weddingDateSubtitle => 'Tell us your wedding date';

  @override
  String get weddingDatePick => 'Pick a date';

  @override
  String weddingDateConfirmedByPartner(Object partner) {
    return '$partner entered this date. Is that correct?';
  }

  @override
  String get weddingDateConfirm => 'Confirm';

  @override
  String get weddingDateSkip => 'I\'ll add it later';

  @override
  String get notifPrimerTitle => 'Allow notifications';

  @override
  String get notifPrimerBody =>
      'We need notification permission to remind you about birthdays and shopping lists on time. Promise we won\'t spam you.';

  @override
  String get notifPrimerAllow => 'Allow';

  @override
  String get notifPrimerLater => 'Later';

  @override
  String get batteryGuideTitle => 'One small thing left';

  @override
  String get batteryGuideBody =>
      'Your phone sometimes blocks reminders. Turn off battery optimization to get them on time.';

  @override
  String get batteryGuideOpenSettings => 'Open settings';

  @override
  String get batteryGuideDone => 'Got it, finish up';
}
