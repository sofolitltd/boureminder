# Release Checklist: বউ রিমাইন্ডার

স্টোরের নিয়ম প্রায়ই বদলায়। সাবমিশনের আগে Play Console ও App Store Connect-এর সর্বশেষ নির্দেশনা দেখে নিন; নিচের তালিকা অক্টোবর ২০২৬-এর বোঝাপড়া অনুযায়ী।

---

## ১. একবারের সেটআপ

### অ্যাকাউন্ট ও ডোমেইন
- [ ] Google Play Developer অ্যাকাউন্ট (ব্যক্তিগত হলে: নতুন অ্যাপ প্রোডাকশনে নেওয়ার আগে **কমপক্ষে ১২ জন টেস্টার নিয়ে ১৪ দিন closed testing** বাধ্যতামূলক — বিটা পরিকল্পনার সাথে মিলিয়ে নিন)
- [ ] Apple Developer Program
- [ ] ডোমেইন কেনা (যেমন `bou.app` বা `boureminder.com`) — API, ডিপ লিংক, প্রাইভেসি পলিসি ও অ্যাকাউন্ট ডিলিট পেজের জন্য
- [ ] সাপোর্ট ইমেইল (যেমন `support@<domain>`)

### Firebase (দুটো প্রজেক্ট: dev, prod)
- [ ] Authentication: Email/Password, Google চালু
- [ ] Email/Password: ইমেইল এনুমারেশন প্রোটেকশন চালু (Firebase কনসোল); রিভিউয়ার ও QA-র জন্য টেস্ট অ্যাকাউন্ট আগে থেকে তৈরি
- [ ] Android SHA-1 ও SHA-256 (debug, upload key, **Play App Signing key**) যোগ — না করলে Google সাইন-ইন প্রোডাকশনে ব্যর্থ হবে
- [ ] iOS: APNs Authentication Key (.p8) Firebase-এ আপলোড
- [ ] Cloud Messaging API (V1) চালু
- [ ] সার্ভারের জন্য সার্ভিস অ্যাকাউন্ট (শুধু Firebase Auth Admin ও FCM পাঠানোর ভূমিকা)
- [ ] Firestore, Storage, Functions **চালু করবেন না**

### Neon
- [ ] প্রজেক্ট: AWS Singapore; ব্রাঞ্চ `main`, `staging`, `dev`
- [ ] রোল: `app` (DML), `migrator` (DDL)
- [ ] Object Storage: প্রতিটি ব্রাঞ্চে `bou-private` বাকেট (private access)
- [ ] PITR উইন্ডো ≥ ৭ দিন (prod)

### হোস্টিং
- [ ] Fly.io অ্যাপ `bou-reminder-api` (`sin`), staging আলাদা অ্যাপ
- [ ] সব secrets সেট (`BACKEND_GO.md` §১৩)
- [ ] কাস্টম ডোমেইন + TLS সার্টিফিকেট (`api.<domain>`)
- [ ] আপটাইম মনিটর (`/healthz`, প্রতি ১ মিনিটে) — যেমন Better Stack বা UptimeRobot

### মনিটরিং
- [ ] Sentry: দুটো প্রজেক্ট (flutter, go), রিলিজ ট্র্যাকিং, অ্যালার্ট (নতুন ইস্যু, ক্র্যাশ রেট > ১%)
- [ ] Flutter `--split-debug-info`-এর symbol ফাইল Sentry-তে আপলোড (CI-তে)

---

## ২. Android

- [ ] `applicationId`: `com.yourname.bou_reminder` (একবার দিলে আর বদলানো যায় না)
- [ ] Flavors: `dev`, `staging`, `prod` (আলাদা applicationId suffix, আলাদা `google-services.json`)
- [ ] `targetSdk`: Google Play-র বর্তমান বাধ্যতামূলক লেভেল (Play Console দেখুন); `minSdk 24`
- [ ] আপলোড কী তৈরি ও **নিরাপদে ব্যাকআপ** (পাসওয়ার্ড ম্যানেজার + অফলাইন কপি); Play App Signing চালু
- [ ] পারমিশন শুধু যা লাগে: `INTERNET`, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM` (বা `USE_EXACT_ALARM` শুধু যদি নীতিমালা অনুমতি দেয়), `RECEIVE_BOOT_COMPLETED`, `CAMERA` (QR ও ছবি), `RECORD_AUDIO` (শুধু ভয়েস ফিচার চালু হলে), `WAKE_LOCK`
- [ ] Exact alarm পারমিশন ব্যবহার করলে Play Console-এ ঘোষণা ও কারণ (ক্যালেন্ডার/রিমাইন্ডার অ্যাপ)
- [ ] Notification চ্যানেল (`SYSTEM_DESIGN.md` §৭.২)
- [ ] Adaptive icon, splash (`flutter_native_splash`, Android 12+ splash API)
- [ ] App Links: `https://<domain>/.well-known/assetlinks.json`
- [ ] R8/ProGuard চালু; Rive, Drift, Firebase-এর keep rules যাচাই (রিলিজ বিল্ড ডিভাইসে টেস্ট)
- [ ] রিলিজ বিল্ড: `flutter build appbundle --flavor prod --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json`

## ৩. iOS

- [ ] Bundle ID: `com.yourname.bouReminder`
- [ ] Capabilities: Push Notifications, Background Modes (Remote notifications), Associated Domains
- [ ] `Info.plist` বাংলায় ব্যবহারের কারণ: ক্যামেরা ("QR কোড স্ক্যান ও জিনিসের ছবি তোলার জন্য"), ফটো লাইব্রেরি, মাইক্রোফোন (ভয়েস ফিচার থাকলে), Face ID ("অ্যাপ লক খোলার জন্য"), স্পিচ রিকগনিশন (ভয়েস ইনপুট থাকলে)
- [ ] **Privacy Manifest** (`PrivacyInfo.xcprivacy`): ব্যবহৃত "required reason" API ও সংগৃহীত ডেটার ঘোষণা; থার্ড-পার্টি SDK-গুলোর নিজস্ব manifest আছে কিনা যাচাই
- [ ] Apple-এর নিয়ম (গাইডলাইন ৪.৮): Google সাইন-ইন থাকলে থার্ড-পার্টি SDK ছাড়া একটা সমমানের বিকল্প লাগবে — আমাদের ইমেইল/পাসওয়ার্ড সাইন-ইন সেই শর্ত পূরণ করে, তাই আলাদা Sign in with Apple লাগছে না। **অ্যাপের ভেতর থেকে অ্যাকাউন্ট ডিলিট** এখনও বাধ্যতামূলক
- [ ] Universal Links: `https://<domain>/.well-known/apple-app-site-association`
- [ ] রিলিজ বিল্ড: `flutter build ipa --flavor prod --obfuscate --split-debug-info=build/symbols`

---

## ৪. স্টোর কমপ্লায়েন্স

### দুই স্টোরেই
- [ ] প্রাইভেসি পলিসি পাবলিক URL-এ (`PRIVACY_POLICY.md` থেকে, আইনজীবী দিয়ে দেখিয়ে)
- [ ] টার্মস অফ ইউজ পাবলিক URL-এ
- [ ] **অ্যাকাউন্ট ডিলিট:** অ্যাপের ভেতরে + একটি ওয়েব পেজ (`https://<domain>/delete-account`) যেখান থেকে অ্যাপ ছাড়াও অনুরোধ করা যায় (Google Play-র নিয়ম)
- [ ] রিভিউয়ারের জন্য ডেমো অ্যাকাউন্ট: দুটি টেস্ট ইমেইল/পাসওয়ার্ড অ্যাকাউন্ট, আগে থেকে পেয়ারড, কিছু ফর্দ ও আনলক হওয়া একটি দলিলসহ; রিভিউ নোটে ধাপ লিখে দিন
- [ ] কনটেন্ট রেটিং প্রশ্নাবলী (ইউজার-জেনারেটেড টেক্সট আছে, শুধু দুজনের মধ্যে, পাবলিক নয়)
- [ ] বয়স: ১৮+ (বিবাহিত কাপলদের অ্যাপ) — স্টোরে টার্গেট অডিয়েন্স সেই অনুযায়ী

### Google Play Data Safety ফর্ম (খসড়া উত্তর)
| ডেটা | সংগ্রহ | শেয়ার | উদ্দেশ্য | ঐচ্ছিক? |
|---|---|---|---|---|
| নাম, ডাকনাম | হ্যাঁ | না | অ্যাপ ফাংশনালিটি | না |
| ইমেইল | হ্যাঁ (Firebase Auth) | না | অ্যাকাউন্ট | না |
| জন্মদিন, বিয়ের তারিখ | হ্যাঁ | না | রিমাইন্ডার | হ্যাঁ |
| ছবি | হ্যাঁ | না | ফর্দ, মামলা, দলিল | হ্যাঁ |
| ইউজারের লেখা (ফর্দ, দলিল, মামলা) | হ্যাঁ | না | অ্যাপ ফাংশনালিটি | না |
| অডিও (ভয়েস নোট, P2) | হ্যাঁ | না | ফর্দ | হ্যাঁ |
| ক্র্যাশ লগ, ডায়াগনস্টিক | হ্যাঁ (Sentry) | না | স্থিতিশীলতা | না |
| ডিভাইস আইডি (FCM টোকেন) | হ্যাঁ | না | নোটিফিকেশন | না |
| লোকেশন | না | — | — | — |

- ট্রানজিটে এনক্রিপ্টেড: হ্যাঁ। ইউজার ডিলিট অনুরোধ করতে পারেন: হ্যাঁ।
- "শেয়ার" মানে তৃতীয় পক্ষকে দেওয়া; সার্ভিস প্রোভাইডার (Neon, Fly.io, Firebase, Sentry) যারা আমাদের পক্ষে প্রসেস করে, সেগুলো সাধারণত শেয়ার হিসেবে গণ্য নয় — Play-র সংজ্ঞা দেখে নিশ্চিত হোন।
- ভয়েস টু টেক্সট (speech_to_text) ডিভাইসের/প্ল্যাটফর্মের স্পিচ সার্ভিস ব্যবহার করে; এটা প্রাইভেসি পলিসিতে উল্লেখ করুন।

---

## ৫. প্রতিটি রিলিজের চেকলিস্ট

### আগে
- [ ] `main` সবুজ (সব টেস্ট পাস, `flutter analyze` ও `go vet` পরিষ্কার)
- [ ] রিলিজ ব্লকার টেস্ট (`TEST_PLAN.md` §১) পাস
- [ ] ডিপেন্ডেন্সি আপডেট দেখা (`flutter pub outdated`, `go list -m -u all`)
- [ ] ভার্সন বাড়ানো: `pubspec.yaml`-এ `version: 1.2.0+12` (build নম্বর সবসময় বাড়বে)
- [ ] সার্ভারে নতুন মাইগ্রেশন থাকলে: আগে staging-এ, backward-compatible কিনা যাচাই
- [ ] সার্ভার আগে ডিপ্লয়, তারপর অ্যাপ সাবমিট (নতুন অ্যাপ পুরনো সার্ভারে চলবে না, কিন্তু পুরনো অ্যাপ নতুন সার্ভারে চলতে হবে)
- [ ] staging-এ দুই ডিভাইসে ইন্টিগ্রেশন ফ্লো (`TEST_PLAN.md` §৩)
- [ ] রিলিজ নোট বাংলা ও ইংরেজিতে

### সময়
- [ ] Android: staged rollout ১০% → ৫০% → ১০০% (প্রতিটিতে ২৪–৪৮ ঘণ্টা, Sentry-তে ক্র্যাশ দেখে)
- [ ] iOS: phased release চালু

### পরে
- [ ] Sentry-তে নতুন ক্র্যাশ নেই
- [ ] সার্ভারের এরর রেট ও p95 latency স্বাভাবিক
- [ ] River-এ ব্যর্থ জব নেই
- [ ] পুরনো ভার্সন বন্ধ করতে হলে `MIN_APP_VERSION` বাড়ানো (সতর্কভাবে, বেশিরভাগ ইউজার আপডেট করার পর)

---

## ৬. CI/CD (GitHub Actions)

```yaml
# .github/workflows/app.yml (সংক্ষেপে)
name: app
on:
  push: { paths: ['app/**'] }
  pull_request: { paths: ['app/**'] }
jobs:
  test:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: app } }
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable, cache: true }
      - run: flutter pub get
      - run: dart run build_runner build -d
      - run: flutter analyze
      - run: flutter test --coverage
```

```yaml
# .github/workflows/api.yml (সংক্ষেপে)
name: api
on:
  push: { paths: ['api/**'] }
  pull_request: { paths: ['api/**'] }
jobs:
  test:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: api } }
    services:
      postgres:
        image: postgres:17
        env: { POSTGRES_PASSWORD: test, POSTGRES_DB: bou_test }
        ports: ['5432:5432']
        options: --health-cmd pg_isready --health-interval 5s --health-retries 10
    env:
      DATABASE_URL: postgres://postgres:test@localhost:5432/bou_test?sslmode=disable
      DATABASE_DIRECT_URL: postgres://postgres:test@localhost:5432/bou_test?sslmode=disable
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with: { go-version-file: api/go.mod }
      - run: make migrate-up
      - run: go vet ./...
      - run: go test -race ./...
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        working-directory: api
        env: { FLY_API_TOKEN: '${{ secrets.FLY_API_TOKEN }}' }
```
Action-গুলোর সর্বশেষ মেজর ভার্সন (`@v4`, `@v5` ইত্যাদি) GitHub Marketplace-এ দেখে আপডেট করুন। মোবাইল বিল্ড ও স্টোরে আপলোড অটোমেট করতে পরে fastlane বা Codemagic যোগ করতে পারেন।

---

## ৭. ঘটনা ঘটলে (Incident)

| সমস্যা | প্রথম কাজ |
|---|---|
| API ডাউন | `fly status`, `fly logs`; আগের রিলিজে ফেরত `fly releases` → `fly deploy --image <prev>` |
| DB সমস্যা | Neon কনসোলে compute ও সংযোগ দেখা; প্রয়োজনে PITR দিয়ে নতুন ব্রাঞ্চে রিস্টোর |
| পুশ যাচ্ছে না | River ড্যাশবোর্ড/টেবিলে ব্যর্থ জব; Firebase কনসোলে FCM কোটা ও সার্ভিস অ্যাকাউন্ট |
| ভুল ডেটা ছড়িয়েছে | `MIN_APP_VERSION` বা `/v1/config`-এ মেইনটেন্যান্স ফ্ল্যাগ দিয়ে অ্যাপ থামানো |
| সিক্রেট ফাঁস | সাথে সাথে কী রোটেট (Neon পাসওয়ার্ড, S3 কী, Firebase সার্ভিস অ্যাকাউন্ট), `fly secrets set`, ডিপ্লয় |
