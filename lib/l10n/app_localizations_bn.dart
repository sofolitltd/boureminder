// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'বউ রিমাইন্ডার';

  @override
  String get navHome => 'হোম';

  @override
  String get navBazar => 'ফর্দ';

  @override
  String get navDeed => 'দলিল';

  @override
  String get navMore => 'আরও';

  @override
  String get quickAddBazar => 'বাজারের ফর্দ';

  @override
  String get quickAddChore => 'কাজের অনুরোধ';

  @override
  String get quickAddDeed => 'দলিল লিখুন';

  @override
  String get quickAddCase => 'মামলা দায়ের';

  @override
  String get quickAddChoreLog => 'কাজের লগ';

  @override
  String get quickAddPromise => 'প্রতিশ্রুতি';

  @override
  String get homeGreetingMorning => 'শুভ সকাল';

  @override
  String get homeGreetingAfternoon => 'শুভ দুপুর';

  @override
  String get homeGreetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get homeGreetingNight => 'শুভ রাত্রি';

  @override
  String get emptyBazarTitle => 'এখনো কোনো ফর্দ নেই';

  @override
  String get emptyBazarBody =>
      'এখনো কোনো ফর্দ নেই। প্রথম বাজারের লিস্টটা বানিয়ে ফেলুন!';

  @override
  String get emptyBazarAction => 'নতুন ফর্দ';

  @override
  String get emptyCaseTitle => 'কোনো মামলা নেই';

  @override
  String get emptyCaseBody => 'এখনো কোনো মামলা নেই। সংসারে শান্তি! 🕊️';

  @override
  String get emptyDeedTitle => 'দলিল খালি';

  @override
  String get emptyDeedBody =>
      'প্রথম চিঠিটা আজই লিখুন। ছোট্ট একটা ভালো কথাই যথেষ্ট।';

  @override
  String get emptyDeedAction => 'লিখুন';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get galleryTitle => 'কম্পোনেন্ট গ্যালারি';

  @override
  String get obSkip => 'এড়িয়ে যান';

  @override
  String get obNext => 'পরবর্তী';

  @override
  String get obStart => 'শুরু করি';

  @override
  String get obTitle1 => 'আর কিছু ভুলবেন না';

  @override
  String get obBody1 =>
      'জন্মদিন, বার্ষিকী, প্রতিশ্রুতি। আমরা সময়মতো মনে করিয়ে দেব।';

  @override
  String get obTitle2 => 'ফর্দ পাঠান এক ট্যাপে';

  @override
  String get obBody2 => 'বাজারের লিস্ট পাঠান, আর লাইভ দেখুন কোনটা কেনা হলো।';

  @override
  String get obTitle3 => 'প্রতিদিন একটা ভালো কথা';

  @override
  String get obBody3 =>
      'সঙ্গীর জন্য গোপনে লিখুন। একদিন সেটা হবে সবচেয়ে সুন্দর উপহার।';

  @override
  String get obTitle4 => 'আর একটু খুনসুটি';

  @override
  String get obBody4 => 'মশারি কে টাঙাল? মামলা করুন, রায় দিন, হাসুন।';

  @override
  String get signInTitle => 'শুরু করা যাক';

  @override
  String get signInSubtitle => 'ফোন নম্বর দিয়ে সাইন-ইন করুন';

  @override
  String get signInPhoneLabel => 'ফোন নম্বর';

  @override
  String get signInPhoneHint => '০১৭xxxxxxxx';

  @override
  String get signInSendOtp => 'OTP পাঠান';

  @override
  String get signInOr => 'অথবা';

  @override
  String get signInGoogle => 'Google দিয়ে সাইন-ইন';

  @override
  String get signInApple => 'Apple দিয়ে সাইন-ইন';

  @override
  String get signInTerms => 'চালিয়ে গেলে আপনি শর্তাবলী মেনে নিচ্ছেন।';

  @override
  String get otpTitle => 'কোড দিয়ে যাচাই করুন';

  @override
  String otpSubtitle(Object phone) {
    return '$phone নম্বরে একটি ৬ অক্ষরের কোড পাঠানো হয়েছে';
  }

  @override
  String get otpVerify => 'যাচাই করুন';

  @override
  String get otpResend => 'আবার পাঠান';

  @override
  String otpResendIn(Object seconds) {
    return 'আবার পাঠান (${seconds}s)';
  }

  @override
  String get otpWrong => 'ভুল কোড, আবার চেষ্টা করুন';

  @override
  String get profileTitle => 'নিজের পরিচয় দিন';

  @override
  String get profileSubtitle => 'এই তথ্য আপনার সঙ্গী দেখবেন';

  @override
  String get profileNameLabel => 'নাম';

  @override
  String get profileNicknameLabel => 'ডাকনাম';

  @override
  String get profileNicknameHint => 'যেমন \"ম্যাডাম\" বা \"জনাব\"';

  @override
  String get profileRoleLabel => 'আপনি কে?';

  @override
  String get profileRoleHusband => 'স্বামী';

  @override
  String get profileRoleWife => 'স্ত্রী';

  @override
  String get profileBirthdayLabel => 'জন্মদিন';

  @override
  String get profileBirthdayPick => 'তারিখ বেছে নিন';

  @override
  String get profileContinue => 'চালিয়ে যান';

  @override
  String get pairingTitle => 'সঙ্গীকে যুক্ত করুন';

  @override
  String get pairingTabShare => 'আমার কোড';

  @override
  String get pairingTabEnter => 'কোড লিখুন';

  @override
  String get pairingShareHint =>
      'এই কোডটা আপনার সঙ্গীকে দিন। ২৪ ঘণ্টা কাজ করবে।';

  @override
  String pairingCodeExpiry(Object hours) {
    return 'মেয়াদ শেষ হবে $hours ঘণ্টা পর';
  }

  @override
  String get pairingCopyCode => 'কোড কপি করুন';

  @override
  String get pairingCopied => 'কোড কপি হয়েছে';

  @override
  String pairingShareText(Object code, Object link) {
    return 'চলো বউ রিমাইন্ডারে যুক্ত হই! কোড: $code 👉 $link';
  }

  @override
  String get pairingEnterHint => 'সঙ্গীর কোড আছে? এখানে লিখুন';

  @override
  String get pairingEnterLabel => 'পেয়ারিং কোড';

  @override
  String get pairingScanButton => 'QR স্ক্যান করুন';

  @override
  String get pairingSubmit => 'যুক্ত করুন';

  @override
  String get pairingSkip => 'একা মোডে চালিয়ে যান';

  @override
  String get pairingErrorInvalid => 'এই কোডটি সঠিক নয়';

  @override
  String get pairingErrorExpired => 'কোডের মেয়াদ শেষ হয়ে গেছে';

  @override
  String get pairingErrorOwnCode => 'নিজের কোড নিজে ব্যবহার করা যাবে না';

  @override
  String pairingSameRoleWarning(Object role) {
    return 'দুজনেই \"$role\" বেছে নিয়েছেন। ঠিক আছে তো?';
  }

  @override
  String get pairingSameRoleContinue => 'তাতে কিছু হবে না';

  @override
  String get scanTitle => 'QR কোড স্ক্যান করুন';

  @override
  String get scanHint => 'সঙ্গীর স্ক্রিনের QR কোডটা ফ্রেমের মধ্যে আনুন';

  @override
  String get scanTorchOn => 'টর্চ জ্বালান';

  @override
  String get scanTorchOff => 'টর্চ নেভান';

  @override
  String get pairingSuccessTitle => 'সংসার জুড়ে গেল! 💞';

  @override
  String pairingSuccessBody(Object partner) {
    return '$partner-এর সাথে এখন আপনি যুক্ত';
  }

  @override
  String get pairingSuccessContinue => 'চালিয়ে যান';

  @override
  String get weddingDateTitle => 'বিবাহবার্ষিকী কবে?';

  @override
  String get weddingDateSubtitle => 'দুজনের বিয়ের তারিখটা জানিয়ে দিন';

  @override
  String get weddingDatePick => 'তারিখ বেছে নিন';

  @override
  String weddingDateConfirmedByPartner(Object partner) {
    return '$partner এই তারিখ দিয়েছেন। ঠিক আছে তো?';
  }

  @override
  String get weddingDateConfirm => 'নিশ্চিত করুন';

  @override
  String get weddingDateSkip => 'পরে দেব';

  @override
  String get notifPrimerTitle => 'নোটিফিকেশনের অনুমতি দিন';

  @override
  String get notifPrimerBody =>
      'জন্মদিন আর বাজারের ফর্দ ঠিক সময়ে জানাতে আমাদের নোটিফিকেশনের অনুমতি লাগবে। কথা দিচ্ছি, বিরক্ত করব না।';

  @override
  String get notifPrimerAllow => 'অনুমতি দিন';

  @override
  String get notifPrimerLater => 'পরে';

  @override
  String get batteryGuideTitle => 'একটা ছোট্ট কাজ বাকি';

  @override
  String get batteryGuideBody =>
      'আপনার ফোন মাঝেমধ্যে রিমাইন্ডার আটকে দেয়। ঠিক সময়ে পেতে ব্যাটারি অপ্টিমাইজেশন বন্ধ করে দিন।';

  @override
  String get batteryGuideOpenSettings => 'সেটিংস খুলুন';

  @override
  String get batteryGuideDone => 'বুঝেছি, শেষ করি';
}
