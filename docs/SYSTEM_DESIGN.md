# System Design: বউ রিমাইন্ডার

| বিষয় | বিবরণ |
|---|---|
| ভার্সন | 3.0.0 |
| এই ডকুমেন্টে | সামগ্রিক আর্কিটেকচার + Flutter ক্লায়েন্টের পূর্ণ ডিজাইন |
| সার্ভারের বিস্তারিত | `BACKEND_GO.md` (Go API, Postgres স্কিমা, জব, ডিপ্লয়) |
| ডিজাইন সিস্টেম | `DESIGN_SYSTEM.md` |
| কোডিং নিয়ম | `CODING_GUIDELINES.md` |

---

## ১. টেক স্ট্যাক ও ভার্সন (অক্টোবর ২০২৬)

সব ভার্সন ৮ অক্টোবর ২০২৬-এ pub.dev, pkg.go.dev ও go.dev থেকে যাচাই করা। প্রজেক্ট শুরুর দিন আবার `flutter pub outdated` ও `go list -m -u all` চালিয়ে নিন; ক্যারেট (`^`) থাকায় মাইনর আপডেট এমনিই আসবে।

| স্তর | প্রযুক্তি | ভার্সন |
|---|---|---|
| মোবাইল SDK | Flutter (stable) | **3.47.6** (Dart 3.13.5) |
| স্টেট ম্যানেজমেন্ট | Riverpod + generator | flutter_riverpod **3.4.3**, riverpod_generator **4.0.9** |
| লোকাল ডেটাবেস | Drift (SQLite) | **2.35.x** |
| সার্ভার | Go | **1.27.1** |
| ডেটাবেস | Neon Serverless Postgres | Postgres 17, রিজিয়ন `aws-ap-southeast-1` (সিঙ্গাপুর) |
| ফাইল স্টোরেজ | Neon Object Storage (S3-compatible) | সিঙ্গাপুর রিজিয়ন |
| Auth | Firebase Authentication | ইমেইল/পাসওয়ার্ড, Google |
| পুশ | Firebase Cloud Messaging | Go Admin SDK দিয়ে পাঠানো |
| ব্যাকগ্রাউন্ড জব | River (Postgres-ভিত্তিক জব কিউ) | v0.49.x |
| ক্র্যাশ ও এরর | Sentry | sentry_flutter 9.30.x, sentry-go 0.49.x |
| হোস্টিং | Docker কন্টেইনার, রেকমেন্ডেড Fly.io `sin` রিজিয়ন | — |

**Firebase শুধু দুটো কাজে:** সাইন-ইন (Auth) আর পুশ পাঠানো (FCM)। Firestore, Storage, Cloud Functions, Crashlytics, Analytics, Remote Config কিছুই ব্যবহার হবে না।

**কেন সিঙ্গাপুর:** ঢাকা থেকে সবচেয়ে কাছের রিজিয়ন যেখানে Neon-এর Postgres ও Object Storage দুটোই আছে (প্রায় ৪০–৭০ms latency)। সার্ভারও একই শহরে রাখলে DB কলের latency ১–২ms।

> **Neon Object Storage নোট:** এটি নতুন সার্ভিস (২০২৬-এ চালু, বিটা হিসেবে ঘোষিত)। শুধু path-style addressing সমর্থন করে, presigned GET/PUT সমর্থন করে, সর্বোচ্চ অবজেক্ট ৫GiB, ফ্রি প্ল্যানে ৫GB। আমাদের কোড স্ট্যান্ডার্ড S3 API ব্যবহার করে, তাই প্রয়োজনে Cloudflare R2 বা AWS S3-তে যেতে শুধু env ভেরিয়েবল বদলালেই হবে।

---

## ২. হাই-লেভেল আর্কিটেকচার

```
┌────────────────────────────── Flutter App ───────────────────────────────┐
│                                                                          │
│  UI (Widgets, Animations)                                                │
│     │ ref.watch                                                          │
│  Riverpod Providers / Notifiers                                          │
│     │                                                                    │
│  Repositories ──► Drift (SQLite) ◄── সব স্ক্রিন এখান থেকে পড়ে (অফলাইন)      │
│     │                 ▲                                                  │
│     │ লেখা = লোকাল    │ pull করা পরিবর্তন                                │
│     ▼                 │                                                  │
│  Outbox ──► SyncEngine ──► REST (dio) ──────────┐                        │
│                 ▲                               │                        │
│                 └── "changed" সিগন্যাল ◄── WebSocket                      │
│                                                 │                        │
│  Firebase Auth SDK ── ID token ─────────────────┤                        │
│  FCM SDK ── পুশ গ্রহণ                            │                        │
│  flutter_local_notifications ── সময়-নির্ধারিত রিমাইন্ডার (অফলাইন)          │
└─────────────────────────────────────────────────┼────────────────────────┘
                                                  │ HTTPS / WSS
┌─────────────────────────── Go Server (Fly.io sin) ┼───────────────────────┐
│  net/http API ── Firebase token যাচাই ── রেট লিমিট                          │
│  WebSocket Hub ── কাপল-ভিত্তিক চ্যানেল                                       │
│  Domain Services ── pairing, bazar, deeds, cases, dates ...              │
│  River Workers ── push পাঠানো, দলিল আনলক, ফর্দ ডেডলাইন, Wrapped, ক্লিনআপ     │
└───────┬───────────────────────┬─────────────────────────┬────────────────┘
        │ pgx (pooled + direct) │ S3 API (presign)        │ Firebase Admin SDK
        ▼                       ▼                         ▼
  Neon Postgres           Neon Object Storage       Firebase Auth (verify)
  (ডেটা + change_log      (প্রাইভেট বাকেট:            FCM (push)
   + River জব টেবিল)       ছবি, অডিও, এক্সপোর্ট)
```

### মূল ডিজাইন সিদ্ধান্ত

| সিদ্ধান্ত | কারণ |
|---|---|
| **লোকাল-ফার্স্ট:** UI সবসময় Drift থেকে পড়ে, লেখা আগে Drift + Outbox-এ | বাজারে নেট দুর্বল; অফলাইনে পুরো অ্যাপ চলবে, UI তাৎক্ষণিক |
| **সিঙ্ক = push (outbox) + pull (change_log cursor)** | সহজ, নির্ভরযোগ্য, ডুপ্লিকেট-মুক্ত (op id দিয়ে idempotent) |
| **WebSocket শুধু "কিছু বদলেছে" সিগন্যাল পাঠায়**, ডেটা আসে pull দিয়ে | একটাই ডেটা-পথ, বাগ কম; WS কেটে গেলেও কিছু হারায় না |
| ক্লায়েন্টে **UUIDv7** আইডি | অফলাইনে তৈরি হওয়া রেকর্ডের আইডি সংঘর্ষ হয় না, সময়-অনুযায়ী সাজানো যায় |
| সময়-নির্ধারিত রিমাইন্ডার **লোকাল নোটিফিকেশন** | অফলাইনে কাজ করে, সার্ভার খরচ নেই |
| সঙ্গীর কাজে ট্রিগার হওয়া নোটিফিকেশন **FCM** (সার্ভার থেকে, River জবে) | রিট্রাই সহ নির্ভরযোগ্য ডেলিভারি |
| দলিলের গোপনীয়তা **সার্ভারের কোয়েরিতে** প্রয়োগ | change_log-এ `visible_to` + API-তে লেখক যাচাই; ছবির লিংক শুধু লেখক পান |
| ফাইল আপলোড **presigned PUT** দিয়ে সরাসরি স্টোরেজে | সার্ভারে ব্যান্ডউইথ খরচ নেই, বড় ফাইলেও দ্রুত |
| PDF **ক্লায়েন্টে**, Flutter উইজেট → ইমেজ → PDF | `pdf` প্যাকেজ বাংলা যুক্তাক্ষর ঠিকমতো শেপ করে না |

---

## ৩. Flutter প্যাকেজ (`pubspec.yaml`)

```yaml
name: bou_reminder
description: বউ রিমাইন্ডার — সংসারের সব জরুরি কথা, সময়মতো।
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.13.0
  flutter: ">=3.47.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # ── State & architecture ──
  flutter_riverpod: ^3.4.3
  riverpod_annotation: ^4.0.7
  freezed_annotation: ^3.1.0
  json_annotation: ^4.12.0
  go_router: ^18.0.2

  # ── Firebase (শুধু Auth + FCM) ──
  firebase_core: ^4.15.0
  firebase_auth: ^6.7.0
  firebase_messaging: ^16.7.0
  google_sign_in: ^7.2.0

  # ── Networking & sync ──
  dio: ^5.11.1
  web_socket_channel: ^3.0.3
  connectivity_plus: ^7.3.2
  drift: ^2.35.2
  drift_flutter: ^0.3.1
  uuid: ^4.6.0

  # ── Notifications & time ──
  flutter_local_notifications: ^22.3.1
  timezone: ^0.11.1
  flutter_timezone: ^5.1.1
  permission_handler: ^13.0.2

  # ── UI & animation ──
  flutter_animate: ^4.5.2
  rive: ^0.14.11
  lottie: ^3.6.1
  confetti: ^0.8.0
  animations: ^3.0.0
  skeletonizer: ^3.0.0
  flutter_slidable: ^4.0.3
  cached_network_image: ^4.0.4
  qr_flutter: ^4.1.0
  mobile_scanner: ^7.4.2

  # ── Media & files ──
  image_picker: ^1.2.4
  flutter_image_compress: ^2.5.1
  image: ^4.10.1
  pdf: ^3.13.1
  printing: ^5.15.1
  screenshot: ^3.0.0
  share_plus: ^13.3.1
  path_provider: ^2.1.6
  speech_to_text: ^7.5.0          # P1: ভয়েস দিয়ে জিনিস যোগ
  record: ^7.1.1                  # P2: ভয়েস নোট
  just_audio: ^0.10.6             # P2: ভয়েস নোট শোনা

  # ── Device & platform ──
  local_auth: ^3.0.2
  flutter_secure_storage: ^11.2.0
  wakelock_plus: ^1.8.1
  url_launcher: ^6.3.3
  app_links: ^7.2.1
  package_info_plus: ^10.2.2
  in_app_review: ^2.0.12

  # ── Monitoring ──
  sentry_flutter: ^9.30.1

  # ── Utils ──
  intl: any                       # flutter_localizations যে ভার্সন পিন করে সেটাই নেবে
  collection: ^1.19.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  build_runner: ^2.16.2
  riverpod_generator: ^4.0.9
  freezed: ^4.0.2
  json_serializable: ^6.14.1
  drift_dev: ^2.35.1
  flutter_lints: ^6.0.0
  mocktail: ^1.0.5
  firebase_auth_mocks: ^0.15.2
  flutter_native_splash: ^2.4.8
  flutter_launcher_icons: ^0.14.4

flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/rive/
    - assets/lottie/
    - assets/images/
    - assets/data/
    - assets/sounds/
  fonts:
    - family: BalooDa2
      fonts:
        - asset: assets/fonts/BalooDa2-Medium.ttf
          weight: 500
        - asset: assets/fonts/BalooDa2-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/BalooDa2-Bold.ttf
          weight: 700
        - asset: assets/fonts/BalooDa2-ExtraBold.ttf
          weight: 800
    - family: HindSiliguri
      fonts:
        - asset: assets/fonts/HindSiliguri-Regular.ttf
        - asset: assets/fonts/HindSiliguri-Medium.ttf
          weight: 500
        - asset: assets/fonts/HindSiliguri-SemiBold.ttf
          weight: 600
    - family: TiroBangla
      fonts:
        - asset: assets/fonts/TiroBangla-Regular.ttf
        - asset: assets/fonts/TiroBangla-Italic.ttf
          style: italic
```

### ভার্সন-সংক্রান্ত গুরুত্বপূর্ণ পরিবর্তন (পুরনো টিউটোরিয়াল দেখে লিখবেন না)

| প্যাকেজ | যা বদলেছে |
|---|---|
| **Riverpod 3** | সব generated provider-এ শুধু `Ref ref` (আর `FooRef` নেই); `AutoDisposeNotifier`/`FamilyNotifier` মিলে শুধু `Notifier`; `AsyncValue.valueOrNull` এখন `.value`; `AsyncValue` sealed, তাই `switch` দিয়ে exhaustive; `StateProvider`/`StateNotifierProvider` legacy (`package:flutter_riverpod/legacy.dart`), ব্যবহার করবেন না; async gap-এর পরে `ref.mounted` চেক; প্রোভাইডার এরর `ProviderException`-এ মোড়ানো; ব্যর্থ প্রোভাইডার নিজে থেকে রিট্রাই করে (exponential backoff) |
| **riverpod_lint 3** | আর `custom_lint` লাগে না। `analysis_options.yaml`-এ `plugins:` দিয়ে চালু হয় (নিচে দেখুন) |
| **freezed 3+/4** | ক্লাসে `abstract` বা `sealed` কিওয়ার্ড লাগবে: `@freezed abstract class X with _$X` |
| **google_sign_in 7** | `GoogleSignIn.instance.initialize()` তারপর `authenticate()`; পুরনো `GoogleSignIn().signIn()` নেই |
| **rive 0.14** | নতুন রানটাইম: `RiveNative.init()`, `File.asset`, `RiveWidgetController`, `RiveWidgetBuilder`, ডেটা বাইন্ডিং |
| **local_auth 3** | `authenticate(localizedReason:, biometricOnly:, persistAcrossBackgrounding:)`; এরর `LocalAuthException` |
| **flutter_local_notifications 22** | `zonedSchedule` ও `show`-এর প্যারামিটার নামসহ; অ্যান্ড্রয়েডে `androidScheduleMode` আবশ্যক। কোড লেখার আগে প্যাকেজের README-র উদাহরণ মিলিয়ে নিন |
| **go_router 18** | `StatefulShellRoute.indexedStack` ব্যবহার করুন; ভার্সনের changelog দেখে redirect API মিলিয়ে নিন |

### `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

plugins:
  riverpod_lint: 3.1.9

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.drift.dart"
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    prefer_single_quotes: true
    always_declare_return_types: true
    avoid_print: true
    require_trailing_commas: true
    unawaited_futures: true
```

---

## ৪. ফোল্ডার স্ট্রাকচার

```
lib/
├── main.dart                      # flavor অনুযায়ী bootstrap ডাকে
├── bootstrap.dart                 # Firebase, Sentry, timezone, Rive, Drift init → ProviderScope
├── app.dart                       # MaterialApp.router, থিম, লোকালাইজেশন
│
├── core/
│   ├── config/
│   │   ├── env.dart               # API_BASE_URL, WS_URL, SENTRY_DSN (dart-define থেকে)
│   │   └── remote_config.dart     # সার্ভারের /v1/config (ফোর্স আপডেট, ফিচার ফ্ল্যাগ)
│   ├── db/
│   │   ├── app_database.dart      # Drift ডেটাবেস + মাইগ্রেশন
│   │   ├── tables/                # প্রতিটি এনটিটির Drift টেবিল
│   │   └── daos/
│   ├── network/
│   │   ├── api_client.dart        # dio + auth interceptor + error mapping
│   │   ├── api_exception.dart
│   │   └── ws_client.dart         # WebSocket, reconnect, heartbeat
│   ├── sync/
│   │   ├── outbox.dart
│   │   ├── sync_engine.dart       # push + pull + cursor
│   │   └── entity_appliers.dart   # সার্ভারের পরিবর্তন Drift-এ লেখা
│   ├── files/
│   │   └── upload_service.dart    # presign → PUT → confirm
│   ├── notifications/
│   │   ├── local_notification_service.dart
│   │   ├── push_service.dart      # FCM token রেজিস্টার, foreground হ্যান্ডলিং
│   │   └── notification_router.dart  # payload → go_router path
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_motion.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── routes.dart            # path কনস্ট্যান্ট
│   ├── utils/
│   │   ├── bangla_number.dart
│   │   ├── bangla_date.dart
│   │   ├── date_math.dart         # nextOccurrence, লিপ ইয়ার, Dhaka today
│   │   ├── ids.dart               # UUIDv7
│   │   └── quantity_parser.dart   # "আলু ২ কেজি" → (আলু, 2, kg)
│   └── widgets/                   # ডিজাইন সিস্টেমের শেয়ার্ড কম্পোনেন্ট
│
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── profile/
│   ├── pairing/
│   ├── home/
│   ├── special_dates/
│   ├── bazar/                     # বাজারের ফর্দ ও কাজের অনুরোধ
│   │   ├── data/
│   │   │   ├── bazar_repository.dart
│   │   │   └── bazar_suggestions.dart
│   │   ├── domain/
│   │   │   ├── bazar_list.dart
│   │   │   ├── bazar_item.dart
│   │   │   └── bazar_units.dart
│   │   └── presentation/
│   │       ├── bazar_lists_screen.dart
│   │       ├── bazar_compose_screen.dart
│   │       ├── bazar_shopping_screen.dart     # বাজার মোড
│   │       ├── bazar_live_screen.dart         # প্রেরকের লাইভ ভিউ
│   │       ├── bazar_summary_screen.dart
│   │       ├── controllers/
│   │       └── widgets/
│   │           ├── item_input_bar.dart
│   │           ├── frequent_item_chips.dart
│   │           ├── shopping_item_tile.dart
│   │           ├── bag_progress.dart
│   │           └── nudge_button.dart
│   ├── love_deed/
│   ├── cases/
│   ├── ledger/
│   ├── wrapped/
│   ├── apology/
│   ├── promises/
│   └── settings/
│
└── l10n/
    ├── app_bn.arb
    └── app_en.arb

assets/
├── fonts/   rive/   lottie/   images/   sounds/
└── data/
    ├── deed_prompts_bn.json
    ├── apology_bn.json
    ├── punishments_bn.json
    └── bazar_dictionary_bn.json     # CONTENT_BN.md §৮ থেকে তৈরি

test/   integration_test/
```

প্রতিটি ফিচার একই ছাঁচ মেনে চলে: `data/` (repository, Drift DAO ব্যবহার), `domain/` (freezed মডেল, বিশুদ্ধ লজিক), `presentation/` (স্ক্রিন, কন্ট্রোলার, উইজেট)।

---

## ৫. লোকাল-ফার্স্ট ডেটা ও সিঙ্ক

এটি অ্যাপের সবচেয়ে গুরুত্বপূর্ণ ইঞ্জিনিয়ারিং অংশ। সার্ভারের দিক `BACKEND_GO.md` §৬-এ।

### ৫.১. নিয়ম

1. **UI শুধু Drift থেকে পড়ে** (Drift-এর `watch()` স্ট্রিম → Riverpod `StreamProvider`)।
2. **লেখা = এক Drift ট্রানজ্যাকশনে:** এনটিটি টেবিলে আপডেট (`syncState = pending`) + `outbox`-এ একটি অপারেশন।
3. `SyncEngine` outbox খালি করে (`POST /v1/sync/push`), তারপর `GET /v1/sync/pull?cursor=` দিয়ে সার্ভারের সব নতুন পরিবর্তন আনে।
4. সার্ভার প্রতিটি পরিবর্তন `change_log` টেবিলে একটি ক্রমিক `seq` দিয়ে লেখে; ক্লায়েন্ট শেষ `seq` (cursor) মনে রাখে।
5. WebSocket-এ সার্ভার শুধু `{"type":"changed","seq":1234}` পাঠায়; ক্লায়েন্ট তখন pull চালায়।

### ৫.২. কখন সিঙ্ক চলে
- Outbox-এ নতুন অপারেশন যোগ হলে (৩০০ms debounce)
- অ্যাপ foreground-এ এলে
- নেটওয়ার্ক ফিরে এলে (`connectivity_plus`)
- WebSocket-এ `changed` এলে
- FCM পুশ এলে (data payload-এ `sync: 1`)
- ব্যাকআপ হিসেবে অ্যাপ খোলা থাকলে প্রতি ৬০ সেকেন্ডে (WS সংযুক্ত না থাকলে প্রতি ১৫ সেকেন্ডে)

### ৫.৩. Drift টেবিল (উদাহরণ: বাজার)

```dart
// core/db/tables/bazar_tables.dart
enum SyncState { synced, pending, failed }

class BazarLists extends Table {
  TextColumn get id => text()();                    // UUIDv7
  TextColumn get coupleId => text()();
  TextColumn get kind => text()();                  // bazar | medicine | tasks
  TextColumn get title => text()();
  TextColumn get status => text()();                // draft | sent | shopping | done | cancelled
  TextColumn get createdBy => text()();
  TextColumn get assignedTo => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  IntColumn get budgetPaisa => integer().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
  IntColumn get doneCount => integer().withDefault(const Constant(0))();
  IntColumn get totalSpentPaisa => integer().withDefault(const Constant(0))();
  TextColumn get rating => text().nullable()();     // great | ok | case
  DateTimeColumn get sentAt => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get lastNudgeAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncState => intEnum<SyncState>()();

  @override
  Set<Column> get primaryKey => {id};
}

class BazarItems extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text().references(BazarLists, #id)();
  TextColumn get name => text()();
  RealColumn get qty => real().nullable()();
  TextColumn get unit => text().nullable()();       // kg | g | l | ml | pcs | hali | dozen | ati | pack | pata | box | bottle
  TextColumn get category => text()();              // veg | fish_meat | grocery | fruit | dairy_egg | medicine | household | other
  TextColumn get note => text().nullable()();
  TextColumn get photoKey => text().nullable()();
  TextColumn get status => text()();                // pending | bought | unavailable | substituted
  TextColumn get substituteNote => text().nullable()();
  IntColumn get pricePaisa => integer().nullable()();
  IntColumn get position => integer()();
  TextColumn get checkedBy => text().nullable()();
  DateTimeColumn get checkedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncState => intEnum<SyncState>()();

  @override
  Set<Column> get primaryKey => {id};
}

class Outbox extends Table {
  TextColumn get opId => text()();                  // UUIDv7, idempotency key
  TextColumn get entity => text()();                // "bazar_item", "bazar_list", ...
  TextColumn get entityId => text()();
  TextColumn get op => text()();                    // upsert | delete | action
  TextColumn get payload => text()();               // JSON
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {opId};
}

class SyncMeta extends Table {
  TextColumn get key => text()();                   // "cursor"
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}
```

> টাকা সবসময় **পয়সায় (integer)** রাখুন: ৳১,৮৫০ = `185000`। double দিয়ে টাকা রাখলে যোগফলে ভুল আসে।

### ৫.৪. লেখা: Repository উদাহরণ

```dart
// features/bazar/data/bazar_repository.dart
@Riverpod(keepAlive: true)
BazarRepository bazarRepository(Ref ref) => BazarRepository(
      ref.watch(appDatabaseProvider),
      ref.watch(syncEngineProvider),
    );

class BazarRepository {
  BazarRepository(this._db, this._sync);
  final AppDatabase _db;
  final SyncEngine _sync;

  Stream<List<BazarItemRow>> watchItems(String listId) =>
      (_db.select(_db.bazarItems)
            ..where((t) => t.listId.equals(listId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .watch();

  /// বাজার মোডে টিক দেওয়া। অফলাইনেও সাথে সাথে UI-তে দেখাবে।
  Future<void> setItemStatus({
    required String itemId,
    required ItemStatus status,
    required String myUid,
    int? pricePaisa,
    String? substituteNote,
  }) async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await (_db.update(_db.bazarItems)..where((t) => t.id.equals(itemId))).write(
        BazarItemsCompanion(
          status: Value(status.name),
          pricePaisa: Value(pricePaisa),
          substituteNote: Value(substituteNote),
          checkedBy: Value(myUid),
          checkedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(SyncState.pending),
        ),
      );
      await _db.into(_db.outbox).insert(OutboxCompanion.insert(
            opId: newId(),
            entity: 'bazar_item',
            entityId: itemId,
            op: 'patch',
            payload: jsonEncode({
              'status': status.name,
              'price_paisa': pricePaisa,
              'substitute_note': substituteNote,
              'client_updated_at': now.toIso8601String(),
            }),
            createdAt: now,
          ));
    });
    _sync.schedulePush();
  }
}
```

### ৫.৫. SyncEngine (কাঠামো)

```dart
// core/sync/sync_engine.dart
@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) {
  final engine = SyncEngine(
    db: ref.watch(appDatabaseProvider),
    api: ref.watch(apiClientProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
}

class SyncEngine {
  SyncEngine({required this.db, required this.api});
  final AppDatabase db;
  final ApiClient api;

  Timer? _debounce;
  Future<void>? _running;

  void schedulePush() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), syncNow);
  }

  /// একসাথে একটাই সিঙ্ক চলবে; চলাকালীন ডাকলে সেটাই ফেরত দেবে।
  Future<void> syncNow() => _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    await _push();
    await _pull();
  }

  Future<void> _push() async {
    while (true) {
      final batch = await (db.select(db.outbox)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
            ..limit(50))
          .get();
      if (batch.isEmpty) return;

      final res = await api.syncPush(batch.map(OutboxOp.fromRow).toList());
      await db.transaction(() async {
        for (final r in res.results) {
          if (r.ok || r.permanentError) {
            // সফল, বা এমন এরর যা রিট্রাইয়ে ঠিক হবে না (যেমন 403): সরিয়ে ফেলুন
            await (db.delete(db.outbox)..where((t) => t.opId.equals(r.opId))).go();
            if (r.permanentError) await _markFailed(r);
          } else {
            await _incrementAttempts(r.opId, r.error);
          }
        }
      });
      if (res.results.any((r) => !r.ok && !r.permanentError)) return; // পরে আবার চেষ্টা
    }
  }

  Future<void> _pull() async {
    var cursor = await _readCursor();
    while (true) {
      final page = await api.syncPull(cursor: cursor, limit: 500);
      await db.transaction(() async {
        for (final change in page.changes) {
          await applyChange(db, change);   // entity_appliers.dart
        }
        await _writeCursor(page.nextCursor);
      });
      cursor = page.nextCursor;
      if (!page.hasMore) return;
    }
  }
}
```

**`applyChange` নিয়ম:** সার্ভার থেকে আসা রেকর্ড লোকাল রেকর্ডকে প্রতিস্থাপন করবে, **যদি না** সেই রেকর্ডের জন্য outbox-এ এখনো পাঠানো-বাকি অপারেশন থাকে (তাহলে লোকাল পরিবর্তন রেখে দিন; push হলে সার্ভারের পরের ভার্সন আসবে)। এতে ইউজারের সদ্য দেওয়া টিক হঠাৎ উল্টে যায় না।

**কনফ্লিক্ট:** প্রতিটি রেকর্ডে last-write-wins (সার্ভার যে ক্রমে পায়)। বাজারের জিনিসে এটা যথেষ্ট; দুজন একই জিনিস একসাথে বদলানো বিরল।

### ৫.৬. WebSocket ক্লায়েন্ট

```dart
// core/network/ws_client.dart
class WsClient {
  WsClient({required this.url, required this.tokenProvider, required this.onChanged});
  final Uri url;
  final Future<String> Function() tokenProvider;
  final void Function(int seq) onChanged;

  WebSocketChannel? _ch;
  int _retry = 0;
  Timer? _ping;

  Future<void> connect() async {
    final token = await tokenProvider();
    final ch = WebSocketChannel.connect(url.replace(queryParameters: {'v': '1'}));
    await ch.ready;
    ch.sink.add(jsonEncode({'type': 'auth', 'token': token}));   // URL-এ টোকেন নয়
    _ch = ch;
    _retry = 0;
    _ping = Timer.periodic(const Duration(seconds: 25), (_) => ch.sink.add('{"type":"ping"}'));
    ch.stream.listen(
      (raw) {
        final msg = jsonDecode(raw as String) as Map<String, dynamic>;
        if (msg['type'] == 'changed') onChanged(msg['seq'] as int);
      },
      onDone: _reconnect,
      onError: (_) => _reconnect(),
    );
  }

  void _reconnect() {
    _ping?.cancel();
    final delay = Duration(seconds: min(30, 1 << _retry++));   // 1,2,4,...,30s
    Future.delayed(delay, connect);
  }
}
```
- অ্যাপ background-এ গেলে WS বন্ধ করুন (ব্যাটারি); foreground-এ এলে আবার খুলুন ও একবার `syncNow()`।
- Background-এ নতুন তথ্য আসে FCM দিয়ে।

### ৫.৭. API ক্লায়েন্ট

```dart
// core/network/api_client.dart
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'X-App-Version': ref.watch(appVersionProvider)},
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (o, h) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) o.headers['Authorization'] = 'Bearer ${await user.getIdToken()}';
      h.next(o);
    },
    onError: (e, h) async {
      // 401 হলে একবার টোকেন রিফ্রেশ করে আবার চেষ্টা
      if (e.response?.statusCode == 401 && e.requestOptions.extra['retried'] != true) {
        final t = await FirebaseAuth.instance.currentUser?.getIdToken(true);
        if (t != null) {
          final o = e.requestOptions
            ..headers['Authorization'] = 'Bearer $t'
            ..extra['retried'] = true;
          return h.resolve(await dio.fetch(o));
        }
      }
      h.next(e);
    },
  ));
  return ApiClient(dio);
}
```
সার্ভারের এরর ফরম্যাট (`{"error":{"code":"pair_code_expired","message":"..."}}`) কে `ApiException`-এ রূপান্তর করুন; UI `code` দেখে `CONTENT_BN.md` §৯ থেকে বাংলা মেসেজ দেখাবে।

### ৫.৮. ফাইল আপলোড

```
1. ছবি বাছাই → flutter_image_compress (সর্বোচ্চ 1600px, JPEG 80%, ~200–400KB)
2. POST /v1/uploads/presign {purpose:"bazar_item", content_type:"image/jpeg", size}
   ← {key, url, headers, expires_at}
3. dio.put(url, data: bytes, headers)   // সরাসরি Neon Object Storage-এ
4. রেকর্ডে photo_key = key সেট করে স্বাভাবিক outbox দিয়ে সিঙ্ক
5. দেখানোর সময়: GET /v1/files/url?key=... ← ১৫ মিনিটের signed URL (cached_network_image, cacheKey = key)
```
অফলাইনে ছবি তুললে লোকাল পাথ রেখে `pending_uploads` টেবিলে রাখুন; নেট এলে ধাপ ২–৪।

---

## ৬. Riverpod 3 প্যাটার্ন

### ৬.১. প্রোভাইডার গ্রাফ

```
authStateProvider (Stream<User?>, Firebase)
        │
        ▼
meProvider (Stream<Profile?>, Drift)  ◄── /v1/me সিঙ্ক
        │
        ▼
coupleProvider (Stream<Couple?>, Drift)
        │
  ┌─────┼──────────────┬────────────────┬──────────────────┐
  ▼     ▼              ▼                ▼                  ▼
specialDates   activeBazarLists   myDeedVault      casesProvider
  │            bazarItems(listId)  deedStreak       (filter family)
  ▼            frequentItems       deliveredDeeds
nextSpecialDate (computed)
reminderReconciler (keepAlive side-effect)
```

### ৬.২. Functional provider (Riverpod 3 সিনট্যাক্স)

```dart
@riverpod
Stream<List<BazarItemRow>> bazarItems(Ref ref, String listId) =>
    ref.watch(bazarRepositoryProvider).watchItems(listId);

@riverpod
BazarProgress bazarProgress(Ref ref, String listId) {
  final items = ref.watch(bazarItemsProvider(listId)).value ?? const [];
  final done = items.where((i) => i.status != 'pending').length;
  final spent = items.fold<int>(0, (s, i) => s + (i.pricePaisa ?? 0));
  return BazarProgress(total: items.length, done: done, spentPaisa: spent);
}
```

### ৬.৩. Notifier দিয়ে অ্যাকশন

```dart
@riverpod
class BazarShoppingController extends _$BazarShoppingController {
  @override
  FutureOr<void> build(String listId) {}

  Future<void> mark(String itemId, ItemStatus status, {int? pricePaisa, String? note}) async {
    final uid = ref.read(currentUidProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(bazarRepositoryProvider).setItemStatus(
          itemId: itemId,
          status: status,
          myUid: uid,
          pricePaisa: pricePaisa,
          substituteNote: note,
        ));
  }

  Future<void> nudge() async {
    final res = await AsyncValue.guard(
      () => ref.read(apiClientProvider).nudgeBazar(listId),  // অনলাইন অ্যাকশন
    );
    if (!ref.mounted) return;           // Riverpod 3: async gap-এর পরে চেক
    state = res;
  }
}
```

### ৬.৪. UI-তে sealed AsyncValue

```dart
final items = ref.watch(bazarItemsProvider(listId));
return switch (items) {
  AsyncData(:final value) => ShoppingList(items: value),
  AsyncError(:final error) => ErrorView(error: error),
  AsyncLoading() => const ShoppingListSkeleton(),     // skeletonizer
};
```

> Riverpod 3-এ `Mutation` API (ফর্ম সাবমিটের loading/success/error) **experimental**। স্থিতিশীল না হওয়া পর্যন্ত উপরের Notifier প্যাটার্ন ব্যবহার করুন।

### ৬.৫. নিয়ম
- UI শুধু `ref.watch`; ইভেন্টে `ref.read(...notifier)`।
- নেটওয়ার্ক বা ডেটাবেস কখনো সরাসরি UI থেকে নয়: Repository → Provider → UI।
- লগআউটে `ref.invalidate(meProvider)` ইত্যাদি, Drift ডেটাবেস মুছে ফেলা, outbox খালি।
- টেস্টে `ProviderContainer.test()` এবং `overrideWithBuild` / `overrideWith`।

---

## ৭. নোটিফিকেশন

### ৭.১. দুই ধরন

| ধরন | মাধ্যম | উদাহরণ |
|---|---|---|
| সময়-নির্ধারিত, নিজের ডিভাইসে | `flutter_local_notifications` | জন্মদিন/বার্ষিকী, দলিল প্রম্পট, প্রতিশ্রুতি |
| সঙ্গীর কাজে ট্রিগার | FCM (Go সার্ভার → River জব → FCM) | ফর্দ পাঠানো/শুরু/শেষ, মনে করানো, নতুন মামলা, রায়, সরি, দলিল আনলক |

### ৭.২. Android চ্যানেল

| চ্যানেল ID | নাম | গুরুত্ব |
|---|---|---|
| `bazar` | বাজারের ফর্দ | High |
| `special_dates` | বিশেষ দিন | High |
| `deed_prompt` | ভালোবাসার দলিল | Default |
| `partner_events` | সঙ্গীর কার্যকলাপ | Default |
| `promises` | প্রতিশ্রুতি | Default |

### ৭.৩. FCM পেলোড (সার্ভার থেকে)

```json
{
  "notification": { "title": "বাজারের ফর্দ এসেছে! 🛒", "body": "১২টি জিনিস, সন্ধ্যা ৭টার মধ্যে।" },
  "data": { "route": "/bazar/0192f3.../shop", "sync": "1", "kind": "bazar_sent" },
  "android": { "notification": { "channel_id": "bazar" } }
}
```
- ট্যাপ করলে `data.route` → `go_router`।
- `sync: 1` থাকলে অ্যাপ খুললেই `syncNow()`।
- Foreground-এ FCM এলে সিস্টেম নোটিফিকেশন না দেখিয়ে অ্যাপের ভেতরে একটা সুন্দর টোস্ট/ব্যানার।
- নোটিফিকেশন অ্যাকশন বাটন ("বাজারে যাচ্ছি"): অ্যান্ড্রয়েডে FCM data-only মেসেজ পেয়ে লোকাল নোটিফিকেশন দেখিয়ে অ্যাকশন যোগ করতে হয়; MVP-তে শুধু ট্যাপ-টু-ওপেন রাখুন, অ্যাকশন বাটন P1।

### ৭.৪. FCM টোকেন
- লগইনের পর ও `onTokenRefresh`-এ `POST /v1/devices {token, platform, locale, app_version}`।
- লগআউটে `DELETE /v1/devices/{token}`।

### ৭.৫. বিশেষ দিনের লোকাল রিমাইন্ডার

```
reconcileReminders(dates, myUid):
  1. pendingNotificationRequests() থেকে সব special_dates রিমাইন্ডার বাতিল
  2. for d in dates where myUid in d.notifyUids:
       next = nextOccurrence(d.month, d.day, todayDhaka)    // ২৯ ফেব্রুয়ারি → অ-লিপ বছরে ২৮
       for offset in d.reminderOffsetsDays:
          fireAt = (next − offset দিন) at d.reminderTime, Asia/Dhaka
          if fireAt > now: zonedSchedule(id: reminderId(d.id, offset), ...)
```
- নোটিফিকেশন ID ডিটারমিনিস্টিক: `stableHash(dateId) % 100000 * 10 + offset` (Dart-এর `hashCode` রিস্টার্টে বদলায়, তাই নিজের FNV-1a হ্যাশ ব্যবহার করুন)।
- কখন চালাবেন: অ্যাপ খুললে (দিনে একবার), specialDates স্ট্রিম বদলালে, সময়/টাইমজোন বদলালে।
- iOS-এ সর্বোচ্চ ৬৪টি পেন্ডিং লোকাল নোটিফিকেশন। ৩ তারিখ × ৪ অফসেট = ১২ + ৭ দিনের দলিল প্রম্পট + প্রতিশ্রুতি। কাস্টম তারিখ বেশি হলে শুধু আগামী ৬০ দিনেরগুলো শিডিউল করুন।
- Android 13+: `POST_NOTIFICATIONS` পারমিশন। Android 12+: নির্ভুল সময়ের জন্য `SCHEDULE_EXACT_ALARM`; না পেলে `inexactAllowWhileIdle` (কয়েক মিনিট দেরি, রিমাইন্ডারের জন্য ঠিক আছে)।

### ৭.৬. দৈনিক দলিল প্রম্পট
- রিপিটিং নোটিফিকেশনে টেক্সট বদলানো যায় না, তাই **আগামী ৭ দিনের জন্য ৭টি আলাদা one-shot** শিডিউল করুন (প্রতিটিতে আলাদা প্রশ্ন); অ্যাপ খুললে উইন্ডো রিফিল।
- আজকের এন্ট্রি লেখা হলে আজকেরটা বাতিল।

---

## ৮. রাউটিং (go_router)

```dart
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(authStateProvider, (_, __) => refresh.value++)
    ..listen(meProvider, (_, __) => refresh.value++)
    ..onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final me = ref.read(meProvider);
      if (auth.isLoading || me.isLoading) return Routes.splash;
      if (auth.value == null) return Routes.onboarding;
      final p = me.value;
      if (p == null || !p.profileComplete) return Routes.profileSetup;
      if (p.coupleId == null && !state.matchedLocation.startsWith(Routes.pairing)) {
        return Routes.pairing;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: Routes.profileSetup, builder: (_, __) => const ProfileSetupScreen()),
      GoRoute(path: Routes.pairing, builder: (_, __) => const PairingScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/bazar', builder: (_, __) => const BazarListsScreen(), routes: [
              GoRoute(path: 'new', builder: (_, s) => BazarComposeScreen(templateId: s.uri.queryParameters['from'])),
              GoRoute(path: ':id/shop', builder: (_, s) => BazarShoppingScreen(listId: s.pathParameters['id']!)),
              GoRoute(path: ':id/live', builder: (_, s) => BazarLiveScreen(listId: s.pathParameters['id']!)),
              GoRoute(path: ':id/summary', builder: (_, s) => BazarSummaryScreen(listId: s.pathParameters['id']!)),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/deed', builder: (_, __) => const DeedHomeScreen(), routes: [
              GoRoute(path: 'write', builder: (_, __) => const DeedWriteScreen()),
              GoRoute(path: 'reveal/:deedId', builder: (_, s) => DeedRevealScreen(deedId: s.pathParameters['deedId']!)),
              GoRoute(path: 'archive', builder: (_, __) => const DeedArchiveScreen()),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => const MoreScreen(), routes: [
              GoRoute(path: 'cases', builder: (_, __) => const CasesScreen()),
              GoRoute(path: 'cases/:id', builder: (_, s) => CaseDetailScreen(id: s.pathParameters['id']!)),
              GoRoute(path: 'dates', builder: (_, __) => const SpecialDatesScreen()),
              GoRoute(path: 'ledger', builder: (_, __) => const LedgerScreen()),
              GoRoute(path: 'wrapped/:month', builder: (_, s) => WrappedScreen(month: s.pathParameters['month']!)),
              GoRoute(path: 'apology', builder: (_, __) => const ApologyScreen()),
              GoRoute(path: 'promises', builder: (_, __) => const PromisesScreen()),
              GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
            ]),
          ]),
        ],
      ),
    ],
  );
}
```
- বটম নেভ: হোম · ফর্দ · **➕** · দলিল · আরও। মাঝের ➕ কোনো ব্রাঞ্চ নয়; এটি একটি bottom sheet খোলে: "বাজারের ফর্দ", "কাজের অনুরোধ", "দলিল লিখুন", "মামলা দায়ের", "কাজের লগ", "প্রতিশ্রুতি"।
- ডিপ লিংক (`app_links`): `https://bou.app/pair/ABC123` → পেয়ারিং স্ক্রিনে কোড বসানো। (ডোমেইন আপনার কেনা ডোমেইন দিয়ে বদলান।)

---

## ৯. অথেন্টিকেশন ফ্লো

```
1. ক্লায়েন্ট: Firebase Auth দিয়ে সাইন-ইন (Email/Password / Google)
2. ক্লায়েন্ট: user.getIdToken() → প্রতিটি API কলে Authorization: Bearer <token>
3. সার্ভার: Firebase Admin SDK দিয়ে টোকেন যাচাই → firebase_uid
4. প্রথম কলে সার্ভার users টেবিলে রেকর্ড তৈরি করে (POST /v1/me/bootstrap)
5. এরপর সব ডেটা Postgres-এ; Firebase-এ শুধু পরিচয়
```

**Google Sign-In (google_sign_in 7):**
```dart
await GoogleSignIn.instance.initialize(serverClientId: Env.googleServerClientId);
final account = await GoogleSignIn.instance.authenticate();
final idToken = account.authentication.idToken;
await FirebaseAuth.instance.signInWithCredential(
  GoogleAuthProvider.credential(idToken: idToken),
);
```

**Email/Password:**
```dart
final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
// সাইন-ইনের সময়:
await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
```
পাসওয়ার্ড ন্যূনতম ৮ অক্ষর (Firebase ডিফল্ট ন্যূনতম ৬, অ্যাপে আরও কড়া নিয়ম ক্লায়েন্ট-সাইডে)। সাইন-আপের পর `sendEmailVerification()` পাঠান; ভেরিফাই না করলেও অ্যাপ ব্যবহার করা যাবে, তবে সেটিংসে একটা মনে করানো ব্যানার থাকবে। "পাসওয়ার্ড ভুলে গেছি" → `sendPasswordResetEmail(email:)`।

---

## ১০. ভালোবাসার দলিল: PDF জেনারেশন

### ১০.১. সমস্যা
`pdf` প্যাকেজ টেক্সট শেপিং করে না, তাই বাংলা যুক্তাক্ষর ভেঙে যায় এবং `ি` কার ভুল জায়গায় বসে। দলিলের মতো আবেগী ফিচারে এটা চলবে না।

### ১০.২. সমাধান: Flutter উইজেট → ছবি → PDF
Flutter-এর রেন্ডারার বাংলা নিখুঁতভাবে শেপ করে। প্রতিটি পাতা একটি উইজেট হিসেবে বানিয়ে অফস্ক্রিনে ছবি করে PDF-এ বসান।

```dart
// features/love_deed/data/deed_pdf_builder.dart
class DeedPdfBuilder {
  static const pageSize = Size(420, 595);   // A5, pt
  static const pixelRatio = 3.0;            // ~216 dpi

  final _shot = ScreenshotController();

  Future<Uint8List> build({
    required DeliveredDeed deed,
    required List<DeedEntry> entries,
    required Map<String, Uint8List> photos,     // আগেই ডাউনলোড করা
    required ThemeData theme,
    void Function(double progress)? onProgress,
  }) async {
    final pages = <Widget>[
      DeedCoverPage(deed: deed),
      ...paginateEntries(entries, photos),      // পাতায় ২–৩টি এন্ট্রি, ছবি থাকলে ১টি
      DeedStatsPage(deed: deed, entries: entries),
    ];

    final doc = pw.Document(title: 'ভালোবাসার দলিল', author: deed.authorName);
    for (var i = 0; i < pages.length; i++) {
      final png = await _shot.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(size: pageSize),
          child: Theme(data: theme, child: Material(child: pages[i])),
        ),
        targetSize: pageSize,
        pixelRatio: pixelRatio,
        delay: const Duration(milliseconds: 40),
      );
      final jpg = await compute(_pngToJpeg, png);   // সাইজ ৫–৮ গুণ কমে
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Image(pw.MemoryImage(jpg), fit: pw.BoxFit.cover),
      ));
      onProgress?.call((i + 1) / pages.length);
    }
    return doc.save();
  }
}

Uint8List _pngToJpeg(Uint8List png) =>
    img.encodeJpg(img.decodePng(png)!, quality: 85);
```
- ছবি আগেই মেমরিতে লোড করুন, না হলে PDF-এ খালি জায়গা আসবে।
- তৈরি PDF `ApplicationDocuments/deeds/{deedId}.pdf`-এ ক্যাশ; পরের বার আবার বানাতে হবে না।
- শেয়ার/সেভ/প্রিন্ট: `Printing.sharePdf()`।

### ১০.৩. পাতার লেআউট
`DESIGN_SYSTEM.md` §৯-এ দলিলের কভার ও এন্ট্রি পাতার ডিজাইন।

---

## ১১. অ্যানিমেশন ইমপ্লিমেন্টেশন

পূর্ণ মোশন স্পেক `DESIGN_SYSTEM.md` §৭-এ। কোডের দিক:

**Rive 0.14 (হাতুড়ি, খাম, মাস্কট)**
```dart
// bootstrap.dart
await RiveNative.init();

// widget
class GavelStrike extends StatefulWidget { ... }
class _GavelStrikeState extends State<GavelStrike> {
  late final _loader = FileLoader.fromAsset('assets/rive/gavel.riv', riveFactory: Factory.rive);
  ViewModelInstance? _vm;

  @override
  Widget build(BuildContext context) => RiveWidgetBuilder(
        fileLoader: _loader,
        onLoaded: (state) => _vm = state.controller.dataBind(DataBind.auto()),
        builder: (context, state) => switch (state) {
          RiveLoading() => const SizedBox.square(dimension: 160),
          RiveFailed() => const Icon(Icons.gavel, size: 96),       // ফলব্যাক
          RiveLoaded() => RiveWidget(controller: state.controller, fit: Fit.contain),
        },
      );

  void strike() => _vm?.trigger('strike')?.trigger();   // .riv ফাইলের ViewModel-এ 'strike' trigger থাকতে হবে

  @override
  void dispose() {
    _vm?.dispose();
    _loader.dispose();
    super.dispose();
  }
}
```
> `onLoaded` কলব্যাক ও trigger API-র ঠিক নাম Rive-এর ডকুমেন্টেশনে (rive.app/docs/runtimes/flutter) মিলিয়ে নিন; 0.14 সিরিজে API দ্রুত বদলাচ্ছে।

**flutter_animate (বাকি সব ছোট অ্যানিমেশন):** স্ট্যাম্প, তালিকা, কার্ড। উদাহরণ `DESIGN_SYSTEM.md`-এ।

**Reduce Motion:** `MediaQuery.disableAnimationsOf(context)` true হলে বড় অ্যানিমেশন বাদ, শুধু fade।

---

## ১২. নিরাপত্তা (ক্লায়েন্ট)

- অ্যাপ লক: `local_auth`; ফলব্যাক ৪-সংখ্যার PIN (`flutter_secure_storage`-এ salted hash)।
- `AppLifecycleListener`: ব্যাকগ্রাউন্ডে ৩০ সেকেন্ডের বেশি থাকলে আবার লক।
- দলিল লেখা ও রিভিল স্ক্রিনে Android `FLAG_SECURE` (রিসেন্ট অ্যাপসে লেখা দেখা যাবে না)।
- Drift ডেটাবেস অ্যাপের প্রাইভেট ডিরেক্টরিতে। লগআউটে মুছে ফেলা হয়।
- কোনো সিক্রেট অ্যাপে নয়: Neon বা S3-এর কোনো কী অ্যাপে থাকবে না, সব সার্ভারের presigned URL দিয়ে।
- রিলিজ বিল্ডে `--obfuscate --split-debug-info` (Sentry-তে symbol আপলোড)।

---

## ১৩. পরিবেশ (Flavors)

| Flavor | API | Firebase প্রজেক্ট | Neon ব্রাঞ্চ |
|---|---|---|---|
| `dev` | `http://10.0.2.2:8080` (লোকাল Go) | bou-reminder-dev | `dev` ব্রাঞ্চ |
| `staging` | `https://api-staging.<domain>` | bou-reminder-dev | `staging` ব্রাঞ্চ |
| `prod` | `https://api.<domain>` | bou-reminder-prod | `main` |

```bash
flutter run --flavor dev -t lib/main.dart \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=WS_URL=ws://10.0.2.2:8080/v1/ws \
  --dart-define=SENTRY_DSN=
```
Neon-এর **branching** খুব কাজের: প্রতিটি বড় ফিচারের জন্য `main` থেকে একটা ব্রাঞ্চ বানিয়ে আসল-মতো ডেটায় টেস্ট করা যায়, আর Neon Object Storage-ও ব্রাঞ্চ অনুযায়ী আলাদা থাকে।

---

## ১৪. ডেভেলপমেন্ট সেটআপ (VS Code)

```bash
# ১. Flutter আপডেট
flutter upgrade                      # 3.47.x নিশ্চিত করুন
flutter --version

# ২. প্রজেক্ট
flutter create --org com.yourname --platforms android,ios bou_reminder
cd bou_reminder

# ৩. Firebase (শুধু Auth + Messaging)
dart pub global activate flutterfire_cli
flutterfire configure --project=bou-reminder-dev

# ৪. কোড জেনারেশন (কাজের সময় চালু রাখুন)
dart run build_runner watch -d

# ৫. সার্ভার (আলাদা টার্মিনালে) — BACKEND_GO.md §১২ দেখুন
cd ../api && make dev
```

**VS Code এক্সটেনশন:** Dart, Flutter, Go (golang.go), Error Lens, Even Better TOML, YAML, SQLTools + PostgreSQL ড্রাইভার (Neon-এ সরাসরি কোয়েরি), REST Client (`api.http` ফাইল দিয়ে API টেস্ট), GitLens।

**রিপো লেআউট (রেকমেন্ডেড মনোরেপো):**
```
bou-reminder/
├── app/          # Flutter
├── api/          # Go
├── docs/         # এই ফোল্ডারের সব .md
└── .github/workflows/
```
