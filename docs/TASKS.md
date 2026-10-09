# Build Tasks: বউ রিমাইন্ডার

PRD-র মাইলস্টোন ধরে ধাপে ধাপে কাজের তালিকা। প্রতিটি টাস্ক শেষে টিক দিন। প্রতিটি মাইলস্টোনের শেষে "ডেমো" লাইনটা কাজ করলে পরেরটায় যান।

---

## M0: ভিত্তি (১.৫ সপ্তাহ)

**রিপো ও টুলিং**
- [ ] মনোরেপো: `app/`, `api/`, `docs/`, `.github/workflows/`
- [ ] `CODING_GUIDELINES.md` §০ কপি করে `CLAUDE.md` / `.github/copilot-instructions.md`
- [ ] Dependabot/Renovate (pub + gomod)

**Flutter**
- [ ] `flutter upgrade` (3.47.x), প্রজেক্ট তৈরি, flavors (dev/staging/prod)
- [ ] `pubspec.yaml` (`SYSTEM_DESIGN.md` §৩), `analysis_options.yaml` (riverpod_lint plugin)
- [ ] ফন্ট বান্ডেল, `AppColors` ThemeExtension (`DESIGN_SYSTEM.md` §৩.৪), টাইপোগ্রাফি, স্পেসিং, মোশন টোকেন
- [ ] কম্পোনেন্ট: `PaperCard`, `StickyNote`, `Stamp`, `AppButton`, `MascotState`, `SkeletonList`, `AppToast`
- [ ] একটা `/_gallery` ডেভ-স্ক্রিন যেখানে সব কম্পোনেন্ট লাইট ও ডার্কে দেখা যায়
- [ ] go_router + বটম নেভ শেল (খালি স্ক্রিন), ➕ bottom sheet
- [ ] l10n সেটআপ (`app_bn.arb`, `app_en.arb`), বাংলা সংখ্যা ও তারিখ ইউটিল
- [ ] Drift ডেটাবেস + মাইগ্রেশন কাঠামো
- [ ] Sentry init

**Go**
- [ ] `go mod init`, ফোল্ডার কাঠামো (`BACKEND_GO.md` §৩)
- [ ] config, slog, `/healthz`, মিডলওয়্যার (recover, request-id, logging, version gate)
- [ ] Neon প্রজেক্ট (সিঙ্গাপুর), `dev` ব্রাঞ্চ, মাইগ্রেশন `0001_init`
- [ ] sqlc সেটআপ, River মাইগ্রেশন, River client চালু
- [ ] Dockerfile, fly.toml, staging-এ প্রথম ডিপ্লয়
- [ ] CI: app ও api দুটো workflow

**ডেমো:** অ্যাপ খুলে ৪টি খালি ট্যাব ঘোরা যায়; staging API-র `/healthz` সবুজ।

---

## M1: অ্যাকাউন্ট ও পেয়ারিং (১.৫ সপ্তাহ)

- [ ] Firebase dev প্রজেক্ট: Email/Password, Google; `flutterfire configure`
- [ ] সাইন-ইন স্ক্রিন (Email/Password + Google), পাসওয়ার্ড রিসেট ফ্লো
- [ ] Go: Firebase টোকেন যাচাই মিডলওয়্যার, `POST /v1/me/bootstrap`, `GET/PATCH /v1/me`
- [ ] প্রোফাইল সেটআপ স্ক্রিন (নাম, ডাকনাম, রোল, জন্মদিন, ছবি)
- [ ] আপলোড পাইপলাইন: `POST /v1/uploads/presign` → PUT → confirm (Neon Object Storage) — অ্যাভাটার দিয়ে প্রথম টেস্ট
- [ ] পেয়ার কোড: তৈরি, QR, শেয়ার, ডিপ লিংক
- [ ] `POST /v1/pair/join` (ট্রানজ্যাকশন, সব এরর কোড), system special dates ও deed vault তৈরি
- [ ] বিয়ের তারিখ স্ক্রিন + `PUT /v1/couple/wedding-date`
- [ ] FCM: টোকেন রেজিস্টার, `PushJob`, "paired" পুশ
- [ ] পেয়ারিং অ্যানিমেশন
- [ ] নোটিফিকেশন পারমিশন প্রাইমার + ব্যাটারি গাইড

**ডেমো:** দুটো ফোনে সাইন-ইন → পেয়ার → দুজনেই "সংসার জুড়ে গেল" পুশ পায়।

---

## M2: বিশেষ দিন (১ সপ্তাহ)

- [ ] সিঙ্ক ইঞ্জিনের প্রথম ভার্সন: `change_log`, `RecordChange`, `/v1/sync/push`, `/v1/sync/pull`, ক্লায়েন্ট outbox + SyncEngine (special_date দিয়ে শুরু)
- [ ] `DateMath` + ইউনিট টেস্ট (লিপ ইয়ার, বছর শেষ, ঢাকা টাইমজোন)
- [ ] বিশেষ দিনের তালিকা ও যোগ/এডিট স্ক্রিন
- [ ] `LocalNotificationService` + `reconcileReminders` + Android চ্যানেল
- [ ] হোমে `CountdownCard` + `FlipCounter`; সেদিন কনফেটি
- [ ] Xiaomi/Samsung-এ অ্যাপ বন্ধ অবস্থায় রিমাইন্ডার টেস্ট

**ডেমো:** স্ত্রীর জন্মদিন ২ মিনিট পরে সেট করুন (ডেভ মোডে অফসেট মিনিটে) → স্বামীর ফোনে নোটিফিকেশন।

---

## M3: বাজারের ফর্দ (৩ সপ্তাহ) ⭐

**সপ্তাহ ১: ডেটা ও সিঙ্ক**
- [ ] মাইগ্রেশন `0002_dates_bazar` (bazar_lists, bazar_items, bazar_catalog)
- [ ] Go এনটিটি হ্যান্ডলার: `bazar_list` (স্ট্যাটাস ট্রানজিশন টেবিল), `bazar_item` (কাউন্টার পুনর্গণনা)
- [ ] Drift টেবিল, `BazarRepository`, প্রোভাইডার
- [ ] WebSocket: Go hub + `/v1/ws` + pg LISTEN; Flutter `WsClient` → `syncNow()`
- [ ] সিঙ্ক টেস্ট: idempotency, অফলাইন ১৫ টিক, সমান্তরাল লেখা

**সপ্তাহ ২: তৈরি ও পাঠানো**
- [ ] `quantity_parser` + টেস্ট (`TEST_PLAN.md` §২)
- [ ] বাজার ডিকশনারি JSON (`CONTENT_BN.md` §৮), সাজেশন ইঞ্জিন
- [ ] ফর্দ তৈরি স্ক্রিন: ইনপুট বার, সাজেশন, ঘনঘন চিপ, ক্যাটাগরি গ্রুপ, ড্র্যাগ, ডেডলাইন, বাজেট, নোট, ছবি
- [ ] পাঠানো → `bazar_sent` পুশ; কাগজের প্লেন অ্যানিমেশন
- [ ] WhatsApp/SMS শেয়ার টেক্সট
- [ ] ফর্দ তালিকা স্ক্রিন (সক্রিয় / পাঠানো / ইতিহাস)

**সপ্তাহ ৩: বাজার মোড ও লাইভ**
- [ ] বাজার মোড: `ShoppingItemTile`, সোয়াইপ, লম্বা চাপ, দাম, `BagProgress`, wakelock, অফলাইন ব্যানার
- [ ] লাইভ ভিউ (প্রেরক): পালস, বিকল্প বলা, জিনিস যোগ
- [ ] `POST /v1/bazar/{id}/nudge` + `NudgeButton` কুলডাউন
- [ ] `BazarDueCheck` জব
- [ ] শেষ করা: সারাংশ, রেটিং, কনফেটি, `BazarCatalogUpdate` জব
- [ ] "মামলা হবে" → মামলা স্ক্রিনে ফর্দ প্রমাণ হিসেবে (M5-এ সংযুক্ত)
- [ ] হোমে চলমান ফর্দ কার্ড

**ডেমো:** স্ত্রী ১২টি জিনিস পাঠান → স্বামী এয়ারপ্লেন মোডে ৬টি টিক → নেট চালু → স্ত্রীর স্ক্রিনে লাইভ আপডেট → বাজার শেষ → সারাংশ পুশ।

---

## M4: ভালোবাসার দলিল (৩ সপ্তাহ)

- [ ] মাইগ্রেশন `0003_deeds`
- [ ] `deed_entry` হ্যান্ডলার (`visible_to`), ভল্ট কাউন্টার ও স্ট্রিক
- [ ] **গোপনীয়তার টেস্ট চারটি পথে** (pull, entries API, files URL, WS) — এটা পাস না করে এগোবেন না
- [ ] দলিল হোম, লেখার স্ক্রিন, মুড, ছবি (`private_to`)
- [ ] দৈনিক প্রম্পট: ৭ দিনের রোলিং লোকাল নোটিফিকেশন, প্রম্পট JSON
- [ ] `ComputeUnlockAt` + টেস্ট, `PATCH /v1/deeds/vault`
- [ ] `DeliverDeed` + `DeedUnlockDaily` জব + `POST /v1/deeds/gift-now`
- [ ] রিভিল: খাম (Rive), Story ভিউ, open/thanks API
- [ ] `DeedPdfBuilder` + গোল্ডেন টেস্ট + আর্কাইভ
- [ ] FLAG_SECURE

**ডেমো:** ৭টি এন্ট্রি লিখে "এখনই উপহার" → সঙ্গীর ফোনে খাম → PDF প্রিন্ট করে বাংলা ঠিক আছে।

---

## M5: মামলা (১.৫ সপ্তাহ)

- [ ] মাইগ্রেশন `0004_cases_misc` (cases, case_replies, chore_logs)
- [ ] মামলা তালিকা, দায়ের, বিস্তারিত, সাফাই, রায় + শাস্তি সাজেশন
- [ ] হাতুড়ি (Rive) + স্ট্যাম্প + সাউন্ড/হ্যাপটিক
- [ ] কাজের লগ
- [ ] ফর্দ থেকে মামলা
- [ ] পুশ: case_filed, case_reply, case_verdict

---

## M6: মজার মডিউল ও রিপোর্ট (২ সপ্তাহ)

- [ ] ওয়ার্ডরোব কাউন্টার + "কাপড় নাই" রিপোর্ট
- [ ] ধার লেজার
- [ ] সরি জেনারেটর + ক্ষমা মঞ্জুর/নামঞ্জুর
- [ ] প্রতিশ্রুতি + লোকাল রিমাইন্ডার + `PromiseReminder` জব
- [ ] `MonthlyWrapped` জব + Wrapped স্ক্রিন + শেয়ার ছবি (`screenshot` + `share_plus`)
- [ ] (P1) ফর্দ টেমপ্লেট, ভয়েস ইনপুট, মাসিক বাজার খরচ

---

## M7: লঞ্চ প্রস্তুতি (১.৫ সপ্তাহ)

- [ ] সেটিংস: অ্যাপ লক, নোটিফিকেশন টগল, শান্ত সময়, ভাষা, সংখ্যা, থিম, সাউন্ড
- [ ] এক্সপোর্ট (`ExportJob`) ও অ্যাকাউন্ট ডিলিট (অ্যাপ + ওয়েব পেজ) + `AccountPurgeJob`
- [ ] `Cleanup` জব
- [ ] ফোর্স আপডেট (`/v1/config`, 426)
- [ ] রেট লিমিট, টাইমআউট, graceful shutdown
- [ ] প্রাইভেসি পলিসি ও টার্মস প্রকাশ
- [ ] prod Firebase, Neon `main`, Fly prod, ডোমেইন, মনিটরিং
- [ ] `RELEASE_CHECKLIST.md` §১–৪
- [ ] পূর্ণ `TEST_PLAN.md` ম্যানুয়াল পাস

---

## বিটা (২ সপ্তাহ)
- [ ] Play Closed Testing (কমপক্ষে ১২ টেস্টার, ১৪ দিন) + TestFlight
- [ ] ফিডব্যাক ফর্ম, সাপ্তাহিক ফিক্স রিলিজ
- [ ] সফলতার শর্ত পূরণ (`TEST_PLAN.md` §৬) → প্রোডাকশন
