import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In bn, this message translates to:
  /// **'বউ রিমাইন্ডার'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In bn, this message translates to:
  /// **'হোম'**
  String get navHome;

  /// No description provided for @navBazar.
  ///
  /// In bn, this message translates to:
  /// **'ফর্দ'**
  String get navBazar;

  /// No description provided for @navDeed.
  ///
  /// In bn, this message translates to:
  /// **'দলিল'**
  String get navDeed;

  /// No description provided for @navMore.
  ///
  /// In bn, this message translates to:
  /// **'আরও'**
  String get navMore;

  /// No description provided for @quickAddBazar.
  ///
  /// In bn, this message translates to:
  /// **'বাজারের ফর্দ'**
  String get quickAddBazar;

  /// No description provided for @quickAddChore.
  ///
  /// In bn, this message translates to:
  /// **'কাজের অনুরোধ'**
  String get quickAddChore;

  /// No description provided for @quickAddDeed.
  ///
  /// In bn, this message translates to:
  /// **'দলিল লিখুন'**
  String get quickAddDeed;

  /// No description provided for @quickAddCase.
  ///
  /// In bn, this message translates to:
  /// **'মামলা দায়ের'**
  String get quickAddCase;

  /// No description provided for @quickAddChoreLog.
  ///
  /// In bn, this message translates to:
  /// **'কাজের লগ'**
  String get quickAddChoreLog;

  /// No description provided for @quickAddPromise.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিশ্রুতি'**
  String get quickAddPromise;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In bn, this message translates to:
  /// **'শুভ সকাল'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In bn, this message translates to:
  /// **'শুভ দুপুর'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In bn, this message translates to:
  /// **'শুভ সন্ধ্যা'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingNight.
  ///
  /// In bn, this message translates to:
  /// **'শুভ রাত্রি'**
  String get homeGreetingNight;

  /// No description provided for @emptyBazarTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো ফর্দ নেই'**
  String get emptyBazarTitle;

  /// No description provided for @emptyBazarBody.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো ফর্দ নেই। প্রথম বাজারের লিস্টটা বানিয়ে ফেলুন!'**
  String get emptyBazarBody;

  /// No description provided for @emptyBazarAction.
  ///
  /// In bn, this message translates to:
  /// **'নতুন ফর্দ'**
  String get emptyBazarAction;

  /// No description provided for @emptyCaseTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোনো মামলা নেই'**
  String get emptyCaseTitle;

  /// No description provided for @emptyCaseBody.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো মামলা নেই। সংসারে শান্তি! 🕊️'**
  String get emptyCaseBody;

  /// No description provided for @emptyDeedTitle.
  ///
  /// In bn, this message translates to:
  /// **'দলিল খালি'**
  String get emptyDeedTitle;

  /// No description provided for @emptyDeedBody.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম চিঠিটা আজই লিখুন। ছোট্ট একটা ভালো কথাই যথেষ্ট।'**
  String get emptyDeedBody;

  /// No description provided for @emptyDeedAction.
  ///
  /// In bn, this message translates to:
  /// **'লিখুন'**
  String get emptyDeedAction;

  /// No description provided for @comingSoon.
  ///
  /// In bn, this message translates to:
  /// **'শীঘ্রই আসছে'**
  String get comingSoon;

  /// No description provided for @galleryTitle.
  ///
  /// In bn, this message translates to:
  /// **'কম্পোনেন্ট গ্যালারি'**
  String get galleryTitle;

  /// No description provided for @obSkip.
  ///
  /// In bn, this message translates to:
  /// **'এড়িয়ে যান'**
  String get obSkip;

  /// No description provided for @obNext.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী'**
  String get obNext;

  /// No description provided for @obStart.
  ///
  /// In bn, this message translates to:
  /// **'শুরু করি'**
  String get obStart;

  /// No description provided for @obTitle1.
  ///
  /// In bn, this message translates to:
  /// **'আর কিছু ভুলবেন না'**
  String get obTitle1;

  /// No description provided for @obBody1.
  ///
  /// In bn, this message translates to:
  /// **'জন্মদিন, বার্ষিকী, প্রতিশ্রুতি। আমরা সময়মতো মনে করিয়ে দেব।'**
  String get obBody1;

  /// No description provided for @obTitle2.
  ///
  /// In bn, this message translates to:
  /// **'ফর্দ পাঠান এক ট্যাপে'**
  String get obTitle2;

  /// No description provided for @obBody2.
  ///
  /// In bn, this message translates to:
  /// **'বাজারের লিস্ট পাঠান, আর লাইভ দেখুন কোনটা কেনা হলো।'**
  String get obBody2;

  /// No description provided for @obTitle3.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিদিন একটা ভালো কথা'**
  String get obTitle3;

  /// No description provided for @obBody3.
  ///
  /// In bn, this message translates to:
  /// **'সঙ্গীর জন্য গোপনে লিখুন। একদিন সেটা হবে সবচেয়ে সুন্দর উপহার।'**
  String get obBody3;

  /// No description provided for @obTitle4.
  ///
  /// In bn, this message translates to:
  /// **'আর একটু খুনসুটি'**
  String get obTitle4;

  /// No description provided for @obBody4.
  ///
  /// In bn, this message translates to:
  /// **'মশারি কে টাঙাল? মামলা করুন, রায় দিন, হাসুন।'**
  String get obBody4;

  /// No description provided for @signInTitle.
  ///
  /// In bn, this message translates to:
  /// **'শুরু করা যাক'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর দিয়ে সাইন-ইন করুন'**
  String get signInSubtitle;

  /// No description provided for @signInPhoneLabel.
  ///
  /// In bn, this message translates to:
  /// **'ফোন নম্বর'**
  String get signInPhoneLabel;

  /// No description provided for @signInPhoneHint.
  ///
  /// In bn, this message translates to:
  /// **'০১৭xxxxxxxx'**
  String get signInPhoneHint;

  /// No description provided for @signInSendOtp.
  ///
  /// In bn, this message translates to:
  /// **'OTP পাঠান'**
  String get signInSendOtp;

  /// No description provided for @signInOr.
  ///
  /// In bn, this message translates to:
  /// **'অথবা'**
  String get signInOr;

  /// No description provided for @signInGoogle.
  ///
  /// In bn, this message translates to:
  /// **'Google দিয়ে সাইন-ইন'**
  String get signInGoogle;

  /// No description provided for @signInApple.
  ///
  /// In bn, this message translates to:
  /// **'Apple দিয়ে সাইন-ইন'**
  String get signInApple;

  /// No description provided for @signInTerms.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে গেলে আপনি শর্তাবলী মেনে নিচ্ছেন।'**
  String get signInTerms;

  /// No description provided for @otpTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোড দিয়ে যাচাই করুন'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'{phone} নম্বরে একটি ৬ অক্ষরের কোড পাঠানো হয়েছে'**
  String otpSubtitle(Object phone);

  /// No description provided for @otpVerify.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই করুন'**
  String get otpVerify;

  /// No description provided for @otpResend.
  ///
  /// In bn, this message translates to:
  /// **'আবার পাঠান'**
  String get otpResend;

  /// No description provided for @otpResendIn.
  ///
  /// In bn, this message translates to:
  /// **'আবার পাঠান ({seconds}s)'**
  String otpResendIn(Object seconds);

  /// No description provided for @otpWrong.
  ///
  /// In bn, this message translates to:
  /// **'ভুল কোড, আবার চেষ্টা করুন'**
  String get otpWrong;

  /// No description provided for @profileTitle.
  ///
  /// In bn, this message translates to:
  /// **'নিজের পরিচয় দিন'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'এই তথ্য আপনার সঙ্গী দেখবেন'**
  String get profileSubtitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In bn, this message translates to:
  /// **'নাম'**
  String get profileNameLabel;

  /// No description provided for @profileNicknameLabel.
  ///
  /// In bn, this message translates to:
  /// **'ডাকনাম'**
  String get profileNicknameLabel;

  /// No description provided for @profileNicknameHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন \"ম্যাডাম\" বা \"জনাব\"'**
  String get profileNicknameHint;

  /// No description provided for @profileRoleLabel.
  ///
  /// In bn, this message translates to:
  /// **'আপনি কে?'**
  String get profileRoleLabel;

  /// No description provided for @profileRoleHusband.
  ///
  /// In bn, this message translates to:
  /// **'স্বামী'**
  String get profileRoleHusband;

  /// No description provided for @profileRoleWife.
  ///
  /// In bn, this message translates to:
  /// **'স্ত্রী'**
  String get profileRoleWife;

  /// No description provided for @profileBirthdayLabel.
  ///
  /// In bn, this message translates to:
  /// **'জন্মদিন'**
  String get profileBirthdayLabel;

  /// No description provided for @profileBirthdayPick.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ বেছে নিন'**
  String get profileBirthdayPick;

  /// No description provided for @profileContinue.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে যান'**
  String get profileContinue;

  /// No description provided for @pairingTitle.
  ///
  /// In bn, this message translates to:
  /// **'সঙ্গীকে যুক্ত করুন'**
  String get pairingTitle;

  /// No description provided for @pairingTabShare.
  ///
  /// In bn, this message translates to:
  /// **'আমার কোড'**
  String get pairingTabShare;

  /// No description provided for @pairingTabEnter.
  ///
  /// In bn, this message translates to:
  /// **'কোড লিখুন'**
  String get pairingTabEnter;

  /// No description provided for @pairingShareHint.
  ///
  /// In bn, this message translates to:
  /// **'এই কোডটা আপনার সঙ্গীকে দিন। ২৪ ঘণ্টা কাজ করবে।'**
  String get pairingShareHint;

  /// No description provided for @pairingCodeExpiry.
  ///
  /// In bn, this message translates to:
  /// **'মেয়াদ শেষ হবে {hours} ঘণ্টা পর'**
  String pairingCodeExpiry(Object hours);

  /// No description provided for @pairingCopyCode.
  ///
  /// In bn, this message translates to:
  /// **'কোড কপি করুন'**
  String get pairingCopyCode;

  /// No description provided for @pairingCopied.
  ///
  /// In bn, this message translates to:
  /// **'কোড কপি হয়েছে'**
  String get pairingCopied;

  /// No description provided for @pairingShareText.
  ///
  /// In bn, this message translates to:
  /// **'চলো বউ রিমাইন্ডারে যুক্ত হই! কোড: {code} 👉 {link}'**
  String pairingShareText(Object code, Object link);

  /// No description provided for @pairingEnterHint.
  ///
  /// In bn, this message translates to:
  /// **'সঙ্গীর কোড আছে? এখানে লিখুন'**
  String get pairingEnterHint;

  /// No description provided for @pairingEnterLabel.
  ///
  /// In bn, this message translates to:
  /// **'পেয়ারিং কোড'**
  String get pairingEnterLabel;

  /// No description provided for @pairingScanButton.
  ///
  /// In bn, this message translates to:
  /// **'QR স্ক্যান করুন'**
  String get pairingScanButton;

  /// No description provided for @pairingSubmit.
  ///
  /// In bn, this message translates to:
  /// **'যুক্ত করুন'**
  String get pairingSubmit;

  /// No description provided for @pairingSkip.
  ///
  /// In bn, this message translates to:
  /// **'একা মোডে চালিয়ে যান'**
  String get pairingSkip;

  /// No description provided for @pairingErrorInvalid.
  ///
  /// In bn, this message translates to:
  /// **'এই কোডটি সঠিক নয়'**
  String get pairingErrorInvalid;

  /// No description provided for @pairingErrorExpired.
  ///
  /// In bn, this message translates to:
  /// **'কোডের মেয়াদ শেষ হয়ে গেছে'**
  String get pairingErrorExpired;

  /// No description provided for @pairingErrorOwnCode.
  ///
  /// In bn, this message translates to:
  /// **'নিজের কোড নিজে ব্যবহার করা যাবে না'**
  String get pairingErrorOwnCode;

  /// No description provided for @pairingSameRoleWarning.
  ///
  /// In bn, this message translates to:
  /// **'দুজনেই \"{role}\" বেছে নিয়েছেন। ঠিক আছে তো?'**
  String pairingSameRoleWarning(Object role);

  /// No description provided for @pairingSameRoleContinue.
  ///
  /// In bn, this message translates to:
  /// **'তাতে কিছু হবে না'**
  String get pairingSameRoleContinue;

  /// No description provided for @scanTitle.
  ///
  /// In bn, this message translates to:
  /// **'QR কোড স্ক্যান করুন'**
  String get scanTitle;

  /// No description provided for @scanHint.
  ///
  /// In bn, this message translates to:
  /// **'সঙ্গীর স্ক্রিনের QR কোডটা ফ্রেমের মধ্যে আনুন'**
  String get scanHint;

  /// No description provided for @scanTorchOn.
  ///
  /// In bn, this message translates to:
  /// **'টর্চ জ্বালান'**
  String get scanTorchOn;

  /// No description provided for @scanTorchOff.
  ///
  /// In bn, this message translates to:
  /// **'টর্চ নেভান'**
  String get scanTorchOff;

  /// No description provided for @pairingSuccessTitle.
  ///
  /// In bn, this message translates to:
  /// **'সংসার জুড়ে গেল! 💞'**
  String get pairingSuccessTitle;

  /// No description provided for @pairingSuccessBody.
  ///
  /// In bn, this message translates to:
  /// **'{partner}-এর সাথে এখন আপনি যুক্ত'**
  String pairingSuccessBody(Object partner);

  /// No description provided for @pairingSuccessContinue.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে যান'**
  String get pairingSuccessContinue;

  /// No description provided for @weddingDateTitle.
  ///
  /// In bn, this message translates to:
  /// **'বিবাহবার্ষিকী কবে?'**
  String get weddingDateTitle;

  /// No description provided for @weddingDateSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'দুজনের বিয়ের তারিখটা জানিয়ে দিন'**
  String get weddingDateSubtitle;

  /// No description provided for @weddingDatePick.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ বেছে নিন'**
  String get weddingDatePick;

  /// No description provided for @weddingDateConfirmedByPartner.
  ///
  /// In bn, this message translates to:
  /// **'{partner} এই তারিখ দিয়েছেন। ঠিক আছে তো?'**
  String weddingDateConfirmedByPartner(Object partner);

  /// No description provided for @weddingDateConfirm.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত করুন'**
  String get weddingDateConfirm;

  /// No description provided for @weddingDateSkip.
  ///
  /// In bn, this message translates to:
  /// **'পরে দেব'**
  String get weddingDateSkip;

  /// No description provided for @notifPrimerTitle.
  ///
  /// In bn, this message translates to:
  /// **'নোটিফিকেশনের অনুমতি দিন'**
  String get notifPrimerTitle;

  /// No description provided for @notifPrimerBody.
  ///
  /// In bn, this message translates to:
  /// **'জন্মদিন আর বাজারের ফর্দ ঠিক সময়ে জানাতে আমাদের নোটিফিকেশনের অনুমতি লাগবে। কথা দিচ্ছি, বিরক্ত করব না।'**
  String get notifPrimerBody;

  /// No description provided for @notifPrimerAllow.
  ///
  /// In bn, this message translates to:
  /// **'অনুমতি দিন'**
  String get notifPrimerAllow;

  /// No description provided for @notifPrimerLater.
  ///
  /// In bn, this message translates to:
  /// **'পরে'**
  String get notifPrimerLater;

  /// No description provided for @batteryGuideTitle.
  ///
  /// In bn, this message translates to:
  /// **'একটা ছোট্ট কাজ বাকি'**
  String get batteryGuideTitle;

  /// No description provided for @batteryGuideBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ফোন মাঝেমধ্যে রিমাইন্ডার আটকে দেয়। ঠিক সময়ে পেতে ব্যাটারি অপ্টিমাইজেশন বন্ধ করে দিন।'**
  String get batteryGuideBody;

  /// No description provided for @batteryGuideOpenSettings.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস খুলুন'**
  String get batteryGuideOpenSettings;

  /// No description provided for @batteryGuideDone.
  ///
  /// In bn, this message translates to:
  /// **'বুঝেছি, শেষ করি'**
  String get batteryGuideDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
