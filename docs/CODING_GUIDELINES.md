# Coding Guidelines: বউ রিমাইন্ডার

এই ফাইলটা দুই কাজে লাগবে: (১) আপনার নিজের কোডিং নিয়ম, (২) VS Code-এ AI সহকারী (GitHub Copilot, Claude ইত্যাদি) ব্যবহার করলে তাকে নিয়ম জানানো। দ্বিতীয় কাজের জন্য এই ফাইলের কপি রাখুন `.github/copilot-instructions.md` বা রিপোর রুটে `CLAUDE.md` / `AGENTS.md` নামে।

---

## ০. AI সহকারীর জন্য সংক্ষিপ্ত নির্দেশ (এই অংশটা কপি করুন)

```
Project: "বউ রিমাইন্ডার" (Bou Reminder) — couple app for Bangladesh.
Docs: docs/PRD.md, docs/SYSTEM_DESIGN.md, docs/BACKEND_GO.md, docs/DESIGN_SYSTEM.md, docs/CONTENT_BN.md.

Stack (do not substitute):
- Flutter 3.47 / Dart 3.13, Riverpod 3 with riverpod_generator (@riverpod, Ref ref — no FooRef),
  freezed 4 (`@freezed abstract class`), go_router 18, Drift for local DB, dio for HTTP.
- Firebase ONLY for Auth and FCM. Never add cloud_firestore, firebase_storage, cloud_functions,
  firebase_analytics, firebase_crashlytics or firebase_remote_config.
- Backend: Go 1.27, net/http ServeMux, pgx v5 + sqlc, goose migrations, River jobs,
  Neon Postgres, Neon Object Storage via aws-sdk-go-v2 (path-style, presigned URLs).

Rules:
- Local-first: UI reads from Drift streams; writes go to Drift + Outbox in one transaction.
- Never hardcode user-facing strings; use l10n (app_bn.arb) and CONTENT_BN.md.
- Money is integer paisa. Times are UTC in storage, Asia/Dhaka for display and day logic.
- IDs are UUIDv7, generated client-side for user-created records.
- Every server query is scoped by the actor's couple_id; deed entries are readable by the
  recipient only when delivered_deed_id IS NOT NULL.
- Riverpod 3: AsyncValue.value (not valueOrNull); check ref.mounted after awaits;
  do not use StateProvider/StateNotifierProvider.
- Prefer small widgets, const constructors, and design tokens from core/theme.
- Write tests for logic you add.
```

---

## ১. সাধারণ

- **ভাষা:** কোড, কমেন্টের প্রয়োজনীয় অংশ, কমিট মেসেজ ইংরেজিতে; ব্যবহারকারীর দেখা টেক্সট শুধু l10n ফাইলে। ব্যাখ্যামূলক কমেন্ট বাংলায় লিখলেও চলবে।
- **নামকরণ:** ফিচারের ইংরেজি নাম কোডে স্থির: `bazar` (ফর্দ), `deed` (দলিল), `case` (মামলা), `specialDate`, `ledger`, `wrapped`, `apology`, `promise`।
- **ছোট PR/কমিট:** এক কমিটে এক কাজ।
- **ব্রাঞ্চ:** `main` সবসময় ডিপ্লয়যোগ্য; কাজ `feat/bazar-shopping-mode`, `fix/deed-unlock-tz` ধরনের ব্রাঞ্চে।
- **কমিট মেসেজ:** Conventional Commits — `feat(bazar): swipe to mark unavailable`, `fix(api): pull cursor gap`, `chore(deps): bump riverpod`।

---

## ২. Flutter

### ২.১. স্ট্রাকচার
- ফিচার-ফার্স্ট: `features/<name>/{data,domain,presentation}`।
- `domain/`-এ Flutter import নয় (বিশুদ্ধ Dart, সহজে টেস্টযোগ্য)।
- `presentation/` কখনো সরাসরি `dio` বা Drift ব্যবহার করবে না; শুধু প্রোভাইডার।

### ২.২. Riverpod 3
```dart
// ✅ ঠিক
@riverpod
Stream<List<BazarItemRow>> bazarItems(Ref ref, String listId) => ...;

@riverpod
class DeedWriteController extends _$DeedWriteController {
  @override
  FutureOr<void> build() {}
  Future<void> submit(...) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ...);
    if (!ref.mounted) return;
    state = result;
  }
}

// ❌ ভুল (পুরনো API)
final counterProvider = StateProvider<int>((ref) => 0);
@riverpod Future<X> foo(FooRef ref) => ...;
ref.watch(p).valueOrNull;
```
- রিপোজিটরি, সার্ভিস, ডেটাবেস: `@Riverpod(keepAlive: true)`।
- স্ক্রিন-নির্ভর ডেটা: ডিফল্ট auto-dispose।
- `ref.watch` শুধু `build`-এ; কলব্যাকে `ref.read`।
- সাইড-ইফেক্ট (snackbar, navigation) `ref.listen` দিয়ে।

### ২.৩. মডেল (freezed 4)
```dart
@freezed
abstract class BazarItem with _$BazarItem {
  const factory BazarItem({
    required String id,
    required String name,
    double? qty,
    BazarUnit? unit,
    @Default(ItemStatus.pending) ItemStatus status,
    int? pricePaisa,
  }) = _BazarItem;

  factory BazarItem.fromJson(Map<String, dynamic> json) => _$BazarItemFromJson(json);
}
```
JSON ফিল্ড নাম সার্ভারের সাথে মিলিয়ে `snake_case`: `build.yaml`-এ `json_serializable: field_rename: snake`।

### ২.৪. উইজেট
- `const` যেখানে সম্ভব।
- একটা উইজেট ফাইল ~২৫০ লাইনের বেশি হলে ভাগ করুন।
- রং/সাইজ সরাসরি নয়: `context.colors.stamp`, `Space.lg`, `Radii.card`, `Motion.normal`।
- প্রতিটি স্ক্রিনে তিন অবস্থা: লোডিং (skeleton), খালি (MascotState), এরর (বাংলা মেসেজ + আবার চেষ্টা)।
- আইকন-বাটনে `tooltip`/`Semantics` বাংলায়।

### ২.৫. তারিখ, টাকা, সংখ্যা
- "আজ" মানে সবসময় `DateMath.todayDhaka()`; কখনো `DateTime.now()` দিয়ে দিন হিসাব নয়।
- টাকা `int` পয়সা; দেখানোর সময় `formatTaka(paisa)` → "৳১,৮৫০"।
- সংখ্যা দেখানো `formatNumber(n, ref.watch(numeralPrefProvider))`।

### ২.৬. এরর হ্যান্ডলিং
- নেটওয়ার্ক এরর → `ApiException(code)` → UI-তে `l10n.errorFor(code)`।
- অপ্রত্যাশিত এরর → Sentry; ইউজারকে সাধারণ বার্তা।
- কখনো ফাঁকা `catch (_) {}` নয়।

---

## ৩. Go

### ৩.১. স্টাইল
- `gofmt`, `go vet`, `staticcheck` পাস করতে হবে।
- এরর র‍্যাপ করুন: `fmt.Errorf("deliver deed %s: %w", id, err)`।
- `context.Context` প্রথম প্যারামিটার, সব DB ও নেটওয়ার্ক কলে।
- গ্লোবাল ভেরিয়েবল নয় (কনফিগ, পুল, ক্লায়েন্ট `main`-এ তৈরি করে ডিপেন্ডেন্সি হিসেবে পাঠান)।
- লগ: `slog` স্ট্রাকচার্ড, কখনো টোকেন বা ব্যক্তিগত লেখা (দলিলের টেক্সট) লগ নয়।

### ৩.২. হ্যান্ডলার ছাঁচ
```go
func (h *Handler) Nudge(w http.ResponseWriter, r *http.Request) {
    actor := auth.MustActor(r.Context())
    listID, err := uuid.Parse(r.PathValue("id"))
    if err != nil {
        httpx.WriteErr(w, httpx.ErrCode(400, "invalid_id"))
        return
    }
    if err := h.svc.Nudge(r.Context(), actor, listID); err != nil {
        httpx.WriteErr(w, err)
        return
    }
    w.WriteHeader(http.StatusNoContent)
}
```
- হ্যান্ডলার পাতলা; লজিক সার্ভিসে; SQL sqlc কোয়েরিতে।
- **প্রতিটি কোয়েরিতে `couple_id = $actorCouple`।** কোনো আইডি দিয়ে সরাসরি `SELECT ... WHERE id = $1` নয়।
- ডেটা বদল + পুশ জব একই ট্রানজ্যাকশনে (`river.InsertTx`)।

### ৩.৩. SQL
- নতুন কলাম/টেবিল = নতুন goose মাইগ্রেশন; পুরনো মাইগ্রেশন কখনো এডিট নয়।
- মাইগ্রেশন backward-compatible রাখুন (আগে কলাম যোগ, কোড ডিপ্লয়, পরে পুরনো কলাম মুছুন)।
- বড় টেবিলে ইনডেক্স `CREATE INDEX CONCURRENTLY` (আলাদা মাইগ্রেশনে, `-- +goose NO TRANSACTION`)।

---

## ৪. API কন্ট্র্যাক্ট
- JSON `snake_case`; সময় RFC 3339 UTC; আইডি UUID স্ট্রিং; টাকা `*_paisa` integer।
- এরর সবসময় `{"error":{"code","message"}}`।
- ব্রেকিং পরিবর্তন হলে নতুন পাথ (`/v2/...`) বা `MIN_APP_VERSION` বাড়ানো; পুরনো অ্যাপ ভেঙে দেওয়া নয়।
- নতুন ফিল্ড যোগ করা ব্রেকিং নয়; ক্লায়েন্ট অজানা ফিল্ড উপেক্ষা করবে।

---

## ৫. নিরাপত্তা চেকলিস্ট (প্রতিটি PR-এ)
- [ ] নতুন এন্ডপয়েন্টে auth মিডলওয়্যার আছে
- [ ] কোয়েরি couple_id দিয়ে সীমাবদ্ধ
- [ ] ইনপুটের দৈর্ঘ্য/মান যাচাই
- [ ] দলিলের ডেটা ছুঁলে গোপনীয়তার টেস্ট আপডেট
- [ ] কোনো সিক্রেট কোডে বা লগে নেই
- [ ] ফাইল URL presigned, স্বল্পমেয়াদি

---

## ৬. ডিপেন্ডেন্সি আপডেট নীতি
- **সবসময় সর্বশেষ স্থিতিশীল ভার্সন।** নতুন প্যাকেজ যোগের আগে pub.dev / pkg.go.dev-তে সর্বশেষ ভার্সন ও শেষ আপডেটের তারিখ দেখুন।
- প্রতি সপ্তাহে একবার: `flutter pub outdated` ও `go list -m -u all`; মাইনর/প্যাচ সাথে সাথে আপডেট।
- মেজর আপডেট (যেমন Riverpod 4): আলাদা ব্রাঞ্চে, changelog পড়ে, টেস্ট চালিয়ে।
- GitHub-এ Dependabot বা Renovate চালু রাখুন (pub ও gomod দুটোই)।
- এক বছরের বেশি আপডেট না হওয়া প্যাকেজ এড়িয়ে চলুন, অথবা বিকল্প খুঁজুন।
