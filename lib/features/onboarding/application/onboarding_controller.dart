import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

enum CoupleRole { husband, wife }

/// In-memory onboarding/pairing state. There's no backend or local
/// persistence wired up yet (see docs/BACKEND_GO.md) — this mocks the flow
/// described in docs/PRD.md §4.1 so the screens have something real to
/// drive off of. Replace the body of [generateMyCode] / [submitPartnerCode]
/// with actual API calls once the pairing endpoints exist.
class OnboardingData {
  const OnboardingData({
    this.phone,
    this.otpVerified = false,
    this.name,
    this.nickname,
    this.role,
    this.birthday,
    this.myCode,
    this.codeGeneratedAt,
    this.paired = false,
    this.partnerName,
    this.partnerRole,
    this.weddingDate,
    this.weddingDateConfirmed = false,
    this.notificationsGranted = false,
    this.completed = false,
  });

  final String? phone;
  final bool otpVerified;
  final String? name;
  final String? nickname;
  final CoupleRole? role;
  final DateTime? birthday;
  final String? myCode;
  final DateTime? codeGeneratedAt;
  final bool paired;
  final String? partnerName;
  final CoupleRole? partnerRole;
  final DateTime? weddingDate;
  final bool weddingDateConfirmed;
  final bool notificationsGranted;
  final bool completed;

  bool get sameRoleAsPartner => paired && role != null && role == partnerRole;

  Duration? get codeRemaining {
    if (codeGeneratedAt == null) return null;
    final expiresAt = codeGeneratedAt!.add(const Duration(hours: 24));
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  OnboardingData copyWith({
    String? phone,
    bool? otpVerified,
    String? name,
    String? nickname,
    CoupleRole? role,
    DateTime? birthday,
    String? myCode,
    DateTime? codeGeneratedAt,
    bool? paired,
    String? partnerName,
    CoupleRole? partnerRole,
    DateTime? weddingDate,
    bool? weddingDateConfirmed,
    bool? notificationsGranted,
    bool? completed,
  }) {
    return OnboardingData(
      phone: phone ?? this.phone,
      otpVerified: otpVerified ?? this.otpVerified,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      birthday: birthday ?? this.birthday,
      myCode: myCode ?? this.myCode,
      codeGeneratedAt: codeGeneratedAt ?? this.codeGeneratedAt,
      paired: paired ?? this.paired,
      partnerName: partnerName ?? this.partnerName,
      partnerRole: partnerRole ?? this.partnerRole,
      weddingDate: weddingDate ?? this.weddingDate,
      weddingDateConfirmed: weddingDateConfirmed ?? this.weddingDateConfirmed,
      notificationsGranted: notificationsGranted ?? this.notificationsGranted,
      completed: completed ?? this.completed,
    );
  }
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingData build() => const OnboardingData();

  void sendOtp(String phone) {
    state = state.copyWith(phone: phone);
  }

  /// Mock verification: any 6-digit code is accepted.
  bool verifyOtp(String code) {
    if (code.length != 6) return false;
    state = state.copyWith(otpVerified: true);
    return true;
  }

  void saveProfile({
    required String name,
    required String nickname,
    required CoupleRole role,
    required DateTime birthday,
  }) {
    state = state.copyWith(name: name, nickname: nickname, role: role, birthday: birthday);
  }

  /// Generates a 6-character couple code, valid 24h, per PRD §4.1.
  String generateMyCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    final code = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
    state = state.copyWith(myCode: code, codeGeneratedAt: DateTime.now());
    return code;
  }

  /// Mocked pairing: rejects your own code, otherwise invents a partner.
  /// Returns an error key on failure, or null on success.
  String? submitPartnerCode(String code) {
    final entered = code.trim().toUpperCase();
    if (entered.length != 6) return 'pairingErrorInvalid';
    if (entered == state.myCode) return 'pairingErrorOwnCode';

    final partnerRole = state.role == CoupleRole.husband ? CoupleRole.wife : CoupleRole.husband;
    state = state.copyWith(
      paired: true,
      partnerName: 'সঙ্গী',
      partnerRole: partnerRole,
    );
    return null;
  }

  void setSameRolePartner() {
    state = state.copyWith(partnerRole: state.role);
  }

  void confirmWeddingDate(DateTime date) {
    state = state.copyWith(weddingDate: date, weddingDateConfirmed: true);
  }

  void setNotificationsGranted(bool granted) {
    state = state.copyWith(notificationsGranted: granted);
  }

  void complete() {
    state = state.copyWith(completed: true);
  }

  void skipPairing() {
    state = state.copyWith(completed: true);
  }
}
