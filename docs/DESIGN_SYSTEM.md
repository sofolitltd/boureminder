# Design System: বউ রিমাইন্ডার

| বিষয় | বিবরণ |
|---|---|
| ভার্সন | 1.0 |
| কনসেপ্ট | "খুনসুটির ডায়েরি" |
| ব্যবহার | Flutter-এ `ThemeExtension` টোকেন হিসেবে (`core/theme/`) |

---

## ১. ডিজাইন দর্শন

**"খুনসুটির ডায়েরি":** সংসারের একটা পুরনো ডায়েরি, যার পাতায় স্টিকি নোট সাঁটা, কোণায় রাবার স্ট্যাম্প, ভেতরে খামে ভরা চিঠি। কিন্তু সব কিছু আধুনিক, গোলাকার, নরম আর খেলাচ্ছলে।

**পাঁচটি নীতি**
1. **উষ্ণ, ঠান্ডা নয়:** সাদা ব্যাকগ্রাউন্ডের বদলে হালকা কাগজ-রং; কালো টেক্সটের বদলে গাঢ় কালি-নীল।
2. **এক হাতে চলবে:** বাজারে এক হাতে ব্যাগ, অন্য হাতে ফোন। গুরুত্বপূর্ণ বাটন নিচের দিকে, বড় টাচ টার্গেট।
3. **হাসি আছে, কিন্তু কাজ আগে:** মজার কপি ও অ্যানিমেশন কখনো কাজ ধীর করবে না; সব অ্যানিমেশন ট্যাপে স্কিপ করা যায়।
4. **বাংলা আগে:** সব লেআউট বাংলা টেক্সটে টেস্ট করা (বাংলা শব্দ ইংরেজির চেয়ে লম্বা ও উঁচু)।
5. **আবেগের জায়গায় ধীর:** দলিল সেকশনে অ্যানিমেশন ধীর ও নরম; ফর্দে দ্রুত ও চটপটে।

---

## ২. ব্র্যান্ড

- **নাম:** বউ রিমাইন্ডার (ইংরেজি: Bou Reminder)
- **ট্যাগলাইন:** "সংসারের সব জরুরি কথা, সময়মতো।"
- **লোগো আইডিয়া:** গোলাকার স্টিকি নোট, উপরের কোণ একটু ভাঁজ করা, ভেতরে হাতে লেখা স্টাইলে "বউ" আর ছোট্ট একটা লাল হার্ট-পিন দিয়ে আটকানো।
- **অ্যাপ আইকন:** গাঁদা-হলুদ (`#F4A259`) ব্যাকগ্রাউন্ডে কাগজ-রঙা স্টিকি নোট, লাল পিন। Android adaptive icon-এর foreground/background আলাদা লেয়ারে। ছোট সাইজে শুধু নোট + পিন (টেক্সট ছাড়া) যেন পরিষ্কার দেখায়।
- **মাস্কট:**
  - **গিন্নি:** গোল চশমা, খোঁপা, হাতে লম্বা কাগজের ফর্দ যা মাটি পর্যন্ত ঝুলে আছে। মুড: খুশি, অধৈর্য (পা ঠুকছে), গর্বিত।
  - **কর্তা:** হাতে বাজারের ব্যাগ (উঁকি দিচ্ছে লাউ), মাথা চুলকাচ্ছে। মুড: বিভ্রান্ত, ভয় পাওয়া (মামলায়), বিজয়ী (বাজার সম্পন্ন)।
  - দুজনেই গোলগাল, সরল রেখা, ২–৩টি রং; Rive-এ অ্যানিমেটেড।

---

## ৩. রং

### ৩.১. টোকেন

| টোকেন | লাইট | ডার্ক | ব্যবহার |
|---|---|---|---|
| `paper` | `#FFF8EE` | `#1C1714` | স্ক্রিনের ব্যাকগ্রাউন্ড |
| `paperDeep` | `#F6ECDC` | `#14100E` | সেকশন ব্যাকগ্রাউন্ড, ইনপুট ফিল |
| `surface` | `#FFFFFF` | `#2A231F` | কার্ড |
| `ink` | `#2B2A4C` | `#F3EDE4` | প্রধান টেক্সট |
| `inkMuted` | `#6B6880` | `#B5ADA3` | সেকেন্ডারি টেক্সট |
| `line` | `#E8DCCB` | `#3A322C` | বর্ডার, ডিভাইডার |
| `stamp` | `#D7263D` | `#FF5A6E` | প্রাইমারি অ্যাকশন, মামলা, স্ট্যাম্প |
| `onStamp` | `#FFFFFF` | `#1C1714` | stamp-এর উপর টেক্সট |
| `marigold` | `#F4A259` | `#F7B57A` | হাইলাইট, কাউন্টডাউন, স্ট্রিক, অ্যাপ আইকন |
| `sticky` | `#FFE58A` | `#5C4E1E` | রিমাইন্ডার স্টিকি নোট |
| `leaf` | `#3E8E41` | `#7BC96F` | বাজার, "কেনা হয়েছে", সফলতা |
| `mint` | `#2EC4B6` | `#4FD8CB` | "খালাস", শোধ, তথ্য |
| `blush` | `#F7C5CC` | `#5A3A40` | দলিল সেকশন |
| `gold` | `#C9A227` | `#E0BE4A` | সিল, দলিলের বর্ডার |
| `danger` | `#B3261E` | `#F2B8B5` | ডিলিট, এরর |

### ৩.২. মুড অনুযায়ী ব্যবহার
| সেকশন | প্রধান | সহকারী | অনুভূতি |
|---|---|---|---|
| হোম ও রিমাইন্ডার | `sticky`, `marigold` | `stamp` | উজ্জ্বল, মনে করিয়ে দেওয়া |
| বাজারের ফর্দ | `leaf`, `marigold` | `paperDeep` | চটপটে, কাজের |
| মামলা | `stamp`, `ink` | `paper` | "অফিশিয়াল" মজা |
| দলিল | `blush`, `gold` | `TiroBangla` ফন্ট | নরম, আবেগী |

### ৩.৩. কনট্রাস্ট নিয়ম
- বডি টেক্সট সবসময় `ink` বা `inkMuted`, `paper`/`surface`-এর উপর (WCAG AA ≥ ৪.৫:১)।
- `marigold`, `sticky`, `blush`, `mint` **টেক্সটের রং হিসেবে নয়**, শুধু ব্যাকগ্রাউন্ড; এদের উপর টেক্সট `ink`।
- ডার্ক মোডে বড় ব্লক রঙের বদলে ৪px রঙিন বর্ডার বা আইকনে রং ব্যবহার করুন (চোখে কম লাগে)।
- রং দিয়ে একা অর্থ বোঝাবেন না: "কেনা" = সবুজ + ✓ আইকন; "পাওয়া যায়নি" = লাল + ✕ + লাইন-থ্রু।

### ৩.৪. কোডে টোকেন

```dart
// core/theme/app_colors.dart
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.paper, required this.paperDeep, required this.surface,
    required this.ink, required this.inkMuted, required this.line,
    required this.stamp, required this.onStamp, required this.marigold,
    required this.sticky, required this.leaf, required this.mint,
    required this.blush, required this.gold, required this.danger,
  });

  final Color paper, paperDeep, surface, ink, inkMuted, line, stamp, onStamp,
      marigold, sticky, leaf, mint, blush, gold, danger;

  static const light = AppColors(
    paper: Color(0xFFFFF8EE), paperDeep: Color(0xFFF6ECDC), surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2B2A4C), inkMuted: Color(0xFF6B6880), line: Color(0xFFE8DCCB),
    stamp: Color(0xFFD7263D), onStamp: Color(0xFFFFFFFF), marigold: Color(0xFFF4A259),
    sticky: Color(0xFFFFE58A), leaf: Color(0xFF3E8E41), mint: Color(0xFF2EC4B6),
    blush: Color(0xFFF7C5CC), gold: Color(0xFFC9A227), danger: Color(0xFFB3261E),
  );

  static const dark = AppColors(
    paper: Color(0xFF1C1714), paperDeep: Color(0xFF14100E), surface: Color(0xFF2A231F),
    ink: Color(0xFFF3EDE4), inkMuted: Color(0xFFB5ADA3), line: Color(0xFF3A322C),
    stamp: Color(0xFFFF5A6E), onStamp: Color(0xFF1C1714), marigold: Color(0xFFF7B57A),
    sticky: Color(0xFF5C4E1E), leaf: Color(0xFF7BC96F), mint: Color(0xFF4FD8CB),
    blush: Color(0xFF5A3A40), gold: Color(0xFFE0BE4A), danger: Color(0xFFF2B8B5),
  );

  @override
  AppColors copyWith() => this;   // থিম রানটাইমে বদলাই না; দরকার হলে পূর্ণ copyWith লিখুন

  @override
  AppColors lerp(AppColors? o, double t) {
    if (o == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      paper: l(paper, o.paper), paperDeep: l(paperDeep, o.paperDeep), surface: l(surface, o.surface),
      ink: l(ink, o.ink), inkMuted: l(inkMuted, o.inkMuted), line: l(line, o.line),
      stamp: l(stamp, o.stamp), onStamp: l(onStamp, o.onStamp), marigold: l(marigold, o.marigold),
      sticky: l(sticky, o.sticky), leaf: l(leaf, o.leaf), mint: l(mint, o.mint),
      blush: l(blush, o.blush), gold: l(gold, o.gold), danger: l(danger, o.danger),
    );
  }
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppText get text => Theme.of(this).extension<AppText>()!;   // §৪-এর স্টাইলগুলো
}
```
`ThemeData`-তে `extensions: [AppColors.light, AppText.light]` এবং `ColorScheme.fromSeed(seedColor: AppColors.light.stamp)`-এর উপর `surface`/`primary` ইত্যাদি টোকেন দিয়ে ওভাররাইড করুন, যাতে Material উইজেটগুলোও একই রং নেয়।

---

## ৪. টাইপোগ্রাফি

| স্টাইল | ফন্ট | সাইজ / লাইন-হাইট | ওজন | ব্যবহার |
|---|---|---|---|---|
| `display` | Baloo Da 2 | 36 / 1.25 | 800 | কাউন্টডাউন সংখ্যা, স্ট্যাম্প |
| `headline` | Baloo Da 2 | 26 / 1.3 | 700 | স্ক্রিন শিরোনাম |
| `title` | Baloo Da 2 | 20 / 1.35 | 600 | কার্ড শিরোনাম |
| `bodyLarge` | Hind Siliguri | 17 / 1.6 | 400 | বাজারের জিনিসের নাম, প্রধান টেক্সট |
| `body` | Hind Siliguri | 15 / 1.6 | 400 | সাধারণ টেক্সট |
| `label` | Hind Siliguri | 15 / 1.4 | 600 | বাটন |
| `caption` | Hind Siliguri | 13 / 1.5 | 500 | সময়, মেটা তথ্য |
| `letter` | Tiro Bangla | 18 / 1.75 | 400 | দলিলের চিঠি, PDF |

- বাংলায় line-height কমপক্ষে ১.৫, নইলে মাত্রা ও যুক্তাক্ষর কেটে যায়।
- সব ফন্ট অ্যাপে বান্ডেল (Google Fonts থেকে, Open Font License); নেটওয়ার্ক থেকে লোড নয়।
- Dynamic Type: `MediaQuery.textScalerOf` সম্মান করুন, সর্বোচ্চ ১.৩x পর্যন্ত লেআউট ভাঙবে না এমনভাবে টেস্ট করুন।
- সংখ্যা: ইউজারের সেটিং অনুযায়ী বাংলা (১২৩) বা ইংরেজি; টাকায় ৳ চিহ্ন আগে, হাজারে কমা (৳১,৮৫০)।

---

## ৫. স্পেসিং, রেডিয়াস, ছায়া

```dart
// core/theme/app_spacing.dart
abstract final class Space {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 24.0, xxl = 32.0;
  static const screen = 20.0;          // স্ক্রিনের দুই পাশের প্যাডিং
}

abstract final class Radii {
  static const sm = 10.0, md = 16.0, card = 20.0, sheet = 28.0, pill = 999.0;
}
```

| ছায়া | মান | ব্যবহার |
|---|---|---|
| `soft` | `0 6 18 ink@6%` | সাধারণ কার্ড |
| `lifted` | `0 10 28 ink@10%` | স্টিকি নোট, ড্র্যাগ করা আইটেম |
| `none` | — | ডার্ক মোডে (ছায়ার বদলে `line` বর্ডার) |

গ্রিড: ৪pt বেস। ন্যূনতম টাচ টার্গেট ৪৮×৪৮; বাজার মোডে চেকবক্স ৫৬×৫৬।

---

## ৬. কম্পোনেন্ট

### ৬.১. তালিকা

| কম্পোনেন্ট | বিবরণ |
|---|---|
| `PaperCard` | সাদা কার্ড, ২০ রেডিয়াস, উপরে ঐচ্ছিক ফাইল-ট্যাব লেবেল |
| `StickyNote` | হলুদ নোট, −২° থেকে +২° এলোমেলো ঘোরানো, উপরে লাল পিন; হোমে রিমাইন্ডার |
| `Stamp` | বাঁকা (−৮°) বর্ডারওয়ালা লেখা: "মঞ্জুর", "দোষী", "খালাস", "সম্পন্ন", "সংরক্ষিত" |
| `AppButton` | প্রাইমারি (stamp ফিল), সেকেন্ডারি (outline), টেক্সট; উচ্চতা ৫২, pill রেডিয়াস; চাপলে ০.৯৭ স্কেল |
| `BigCheck` | বাজার মোডের ৫৬px চেকবক্স; টিকে বাউন্স + হ্যাপটিক |
| `QtyChip` | "২ কেজি" টাইপ ছোট চিপ |
| `FrequentChip` | ঘনঘন কেনা জিনিস, `+` আইকনসহ |
| `BagProgress` | বাজারের ব্যাগ ভরে ওঠা প্রোগ্রেস (০–১০০%) |
| `FlipCounter` | ফ্লিপ-ক্লক সংখ্যা (কাউন্টডাউন) |
| `CountdownCard` | কাউন্টডাউন + ইমোজি + তারিখ |
| `Envelope` | দলিলের খাম (Rive), সিলসহ |
| `MascotState` | খালি/এরর/লোডিং স্টেটে মাস্কট + এক লাইন কপি + ঐচ্ছিক বাটন |
| `NudgeButton` | "একটা মিষ্টি খোঁচা দিন 👉"; কুলডাউনে বাকি সময় দেখায় |
| `AppToast` | উপর থেকে নামা ব্যানার (foreground পুশ, সফলতা) |
| `SkeletonList` | skeletonizer দিয়ে লোডিং |

### ৬.২. `Stamp`

```dart
class Stamp extends StatelessWidget {
  const Stamp({super.key, required this.label, this.color, this.animate = true});
  final String label;
  final Color? color;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.stamp;
    final stamp = Transform.rotate(
      angle: -0.14,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: c, width: 3),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Text(label, style: context.text.display.copyWith(fontSize: 26, color: c)),
        ),
      ),
    );
    if (!animate || MediaQuery.disableAnimationsOf(context)) return stamp;
    return stamp
        .animate()
        .scale(begin: const Offset(2.2, 2.2), end: const Offset(1, 1),
            duration: Motion.normal, curve: Motion.stamp)
        .fadeIn(duration: Motion.fast)
        .then()
        .shakeX(hz: 4, amount: 2, duration: 160.ms);
  }
}
```
স্ট্যাম্প নামার সাথে `HapticFeedback.heavyImpact()` ও হালকা "ঠাস" সাউন্ড (সেটিংসে সাউন্ড বন্ধ করা যাবে)।

### ৬.৩. `PaperCard`

```dart
class PaperCard extends StatelessWidget {
  const PaperCard({super.key, required this.child, this.tab, this.tabColor, this.onTap});
  final Widget child;
  final String? tab;
  final Color? tabColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (tab != null)
        Container(
          margin: const EdgeInsets.only(left: Space.xl),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: tabColor ?? c.marigold,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.sm)),
          ),
          child: Text(tab!, style: context.text.caption.copyWith(color: c.ink)),
        ),
      Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.card),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: c.line),
              boxShadow: dark ? null : [BoxShadow(color: c.ink.withValues(alpha: .06), blurRadius: 18, offset: const Offset(0, 6))],
            ),
            padding: const EdgeInsets.all(Space.lg + 2),
            child: child,
          ),
        ),
      ),
    ]);
  }
}
```

### ৬.৪. `ShoppingItemTile` (বাজার মোড)

```
┌──────────────────────────────────────────────┐
│  ◻️   আলু                          ২ কেজি    │   ← 72px উঁচু, পুরো সারি ট্যাপযোগ্য
│       "লাল আলু হলে ভালো"                       │   ← নোট (caption, inkMuted)
└──────────────────────────────────────────────┘
   → ডানে সোয়াইপ: সবুজ ব্যাকগ্রাউন্ডে "✓ কেনা হয়েছে"
   ← বামে সোয়াইপ: লাল ব্যাকগ্রাউন্ডে "✕ পাওয়া যায়নি"
   লম্বা চাপ: bottom sheet → বিকল্প নোট, দাম

কেনা হলে:
┌──────────────────────────────────────────────┐
│  ✅   আলু                ২ কেজি   ৳১২০  ✏️    │   ← leaf রঙের হালকা ফিল, টেক্সট inkMuted
└──────────────────────────────────────────────┘
```
`flutter_slidable` দিয়ে সোয়াইপ; সোয়াইপের ৪০% পার হলে হ্যাপটিক টিক ও অ্যাকশন সম্পন্ন। প্রতিটি টিকে সারিটা সংকুচিত হয়ে "কেনা" গ্রুপে নিচে নেমে যায় (`AnimatedList`), যাতে বাকি জিনিস সবসময় উপরে থাকে।

---

## ৭. মোশন

### ৭.১. টোকেন

```dart
// core/theme/app_motion.dart
abstract final class Motion {
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 450);
  static const emotional = Duration(milliseconds: 700);   // দলিল
  static const celebrate = Duration(milliseconds: 1400);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const spring = Curves.easeOutBack;
  static const stamp = Cubic(0.2, 1.4, 0.4, 1.0);          // একটু ওভারশুট
  static const gentle = Curves.easeInOutSine;              // দলিল
}
```

### ৭.২. মুহূর্ত অনুযায়ী অ্যানিমেশন

| মুহূর্ত | অ্যানিমেশন | সময় | টুল |
|---|---|---|---|
| স্প্ল্যাশ | স্টিকি নোট উড়ে এসে পিনে আটকায়, পিন একটু দোলে | 900ms | Rive |
| পেয়ারিং সম্পন্ন | দুটি নোট দুই দিক থেকে এসে একটা হার্ট-পিনে জুড়ে যায় + "সংসার জুড়ে গেল!" | 1400ms | Rive |
| হোম কার্ড লোড | স্ট্যাগার্ড fade + ১২px slide up, প্রতিটিতে ৪০ms দেরি | 280ms | flutter_animate |
| কাউন্টডাউন | সংখ্যা ফ্লিপ-ক্লক স্টাইলে উল্টায় | 450ms | কাস্টম `FlipCounter` |
| জিনিস যোগ (ফর্দ) | নতুন সারি উপর থেকে নেমে বসে, চিপ ছোট হয়ে তালিকায় উড়ে যায় | 280ms | `AnimatedList` + Hero |
| ফর্দ পাঠানো | কাগজ ভাঁজ হয়ে কাগজের প্লেন হয়ে উড়ে যায় | 900ms | Rive |
| টিক দেওয়া | চেকবক্স বাউন্স, সারি সংকুচিত হয়ে নিচে নামে, ব্যাগে একটা জিনিস পড়ে | 280ms | flutter_animate + Rive |
| পাওয়া যায়নি | সারি একবার হালকা কাঁপে, লাইন-থ্রু আঁকা হয় বাম থেকে ডানে | 280ms | flutter_animate |
| বাজার সম্পন্ন | কনফেটি + "সম্পন্ন" স্ট্যাম্প + কর্তার বিজয়ী পোজ | 1400ms | confetti + Rive |
| মনে করানো | বাটন থেকে একটা আঙুল-খোঁচা ইমোজি ছিটকে যায় | 450ms | flutter_animate |
| দলিল সাবমিট | চিঠি ভাঁজ হয়ে খামে ঢোকে, ছোট হার্ট ভেসে ওঠে | 1200ms | Rive |
| দলিল রিভিল | মোমের সিল কাঁপে → ট্যাপে ভাঙে → ফ্ল্যাপ খোলে → চিঠি উঠে আসে | ~2s (ইউজার-চালিত) | Rive |
| রায় | হাতুড়ি পড়ে, স্ক্রিন হালকা কাঁপে, স্ট্যাম্প নামে | 900ms | Rive + Stamp |
| জন্মদিন/বার্ষিকী | পুরো স্ক্রিন কনফেটি + বেলুন উঠে যায় | 1400ms | Lottie |
| স্ট্রিক বাড়া | 🔥 বাউন্স + সংখ্যা কাউন্ট-আপ | 450ms | flutter_animate |
| স্ক্রিন ট্রানজিশন | সাধারণ: shared axis (horizontal); ডিটেইল: container transform | 280ms | animations প্যাকেজ |
| Bottom sheet | নিচ থেকে spring | 280ms | Material 3 |

### ৭.৩. নিয়ম
- সাধারণ ট্রানজিশন ১৮০–৩০০ms; উদযাপন সর্বোচ্চ ১.৫ সেকেন্ড।
- উদযাপন অ্যানিমেশন ট্যাপ করলে সাথে সাথে শেষ অবস্থায় চলে যায়।
- `MediaQuery.disableAnimationsOf(context)` true হলে: Rive/Lottie বাদ, শুধু ১৫০ms fade; কনফেটি নেই।
- একসাথে একটার বেশি "বড়" অ্যানিমেশন নয়।
- ৬০fps নিশ্চিত করতে বড় অ্যানিমেশনের পেছনের উইজেট `RepaintBoundary`-তে।

### ৭.৪. হ্যাপটিক ও সাউন্ড
| মুহূর্ত | হ্যাপটিক | সাউন্ড |
|---|---|---|
| টিক | `selectionClick` | হালকা "টুক" |
| স্ট্যাম্প/রায় | `heavyImpact` | "ঠাস" |
| ফর্দ পাঠানো | `mediumImpact` | "ফুস" (উড়ে যাওয়া) |
| দলিল সিল ভাঙা | `mediumImpact` | কাগজ খোলার শব্দ |
| এরর | `vibrate` (ছোট) | নেই |

সাউন্ড ডিফল্টে চালু, সেটিংসে বন্ধ করা যায়; ফোন সাইলেন্টে থাকলে বাজবে না। সব সাউন্ড < ৩০KB (`assets/sounds/`)।

---

## ৮. স্ক্রিন লেআউট

### ৮.১. হোম

```
┌────────────────────────────────────┐
│ শুভ সন্ধ্যা, ম্যাডাম 👋        🔔   │  ← headline + নোটিফিকেশন আইকন
│                                    │
│  ┌──── স্টিকি নোট (sticky) ─────┐  │
│  │ 📌                           │  │
│  │  বিবাহবার্ষিকী               │  │
│  │  ┌──┐┌──┐                    │  │
│  │  │১ ││২ │  দিন বাকি   💍     │  │  ← FlipCounter
│  │  └──┘└──┘                    │  │
│  │  ৯ ফেব্রুয়ারি, সোমবার        │  │
│  └──────────────────────────────┘  │
│                                    │
│  ╭ চলমান ফর্দ ─────────────────╮   │  ← PaperCard, tab = leaf
│  │ 🛒 আজকের বাজার               │   │
│  │ ▓▓▓▓▓▓▓░░░░  ৭/১২ কেনা       │   │
│  │ জনাব বাজারে আছেন • ৫ মিনিট আগে │   │
│  ╰──────────────────────────────╯   │
│                                    │
│  ╭ আজকের দলিল ─────────────────╮   │  ← tab = blush
│  │ ✍️ "আজ সঙ্গীর কোন কথাটা     │   │
│  │    মনে রাখার মতো?"           │   │
│  │ 🔥 ১২ দিন    [ লিখুন ]       │   │
│  ╰──────────────────────────────╯   │
│                                    │
│  সাম্প্রতিক মামলা           সব →   │
│  ⚖️ মশারি মামলা • রায় বাকি          │
│                                    │
├────────────────────────────────────┤
│  🏠     🛒     (➕)     💌     ☰    │  ← ➕ একটু উঁচু, stamp রঙের গোল
│  হোম   ফর্দ           দলিল   আরও   │
└────────────────────────────────────┘
```
কার্ডের ক্রম গতিশীল: আজ বিশেষ দিন হলে সেটা সবার উপরে বড় করে কনফেটিসহ; চলমান ফর্দ থাকলে দ্বিতীয়; দলিল লেখা হয়ে গেলে কার্ড ছোট হয়ে "আজকের দলিল লেখা হয়েছে ✓"।

### ৮.২. ফর্দ তৈরি

```
┌────────────────────────────────────┐
│ ←  নতুন ফর্দ                 টেমপ্লেট │
│                                    │
│  [🛒 বাজার] [💊 ওষুধ] [✅ কাজ]      │  ← segmented
│                                    │
│  আজকের বাজার ✏️                    │
│  ⏰ সন্ধ্যা ৭টার মধ্যে    💰 ৳২,০০০  │  ← ট্যাপে পিকার
│                                    │
│  ঘনঘন কেনা:                        │
│  (+ আলু) (+ পেঁয়াজ) (+ ডিম) (+ দুধ) →│  ← horizontal scroll
│                                    │
│  সবজি                              │
│   ⋮⋮ আলু              ২ কেজি   ✕   │  ← ড্র্যাগ হ্যান্ডেল, মুছুন
│   ⋮⋮ কাঁচা মরিচ        ২৫০ গ্রাম ✕   │
│  মাছ-মাংস                          │
│   ⋮⋮ ইলিশ             ১টা  📷  ✕   │
│                                    │
│  📝 নোট: "মাছ যেন টাটকা হয় 🐟"     │
│                                    │
├────────────────────────────────────┤
│ ┌──────────────────────────┐ 🎤    │  ← কীবোর্ডের উপরে লেগে থাকে
│ │ জিনিস লিখুন, যেমন "আলু ২ কেজি"│      │
│ └──────────────────────────┘       │
│  সাজেশন: আলু • আলুবোখারা • আলু (লাল)  │
│                                    │
│  [        পাঠিয়ে দিন  ✈️        ]   │  ← stamp রঙ, ৫২px
└────────────────────────────────────┘
```
- এন্টার চাপলে জিনিস যোগ হয়, ইনপুট খালি হয়ে আবার ফোকাস (দ্রুত একটার পর একটা লেখা)।
- `quantity_parser`: "আলু ২ কেজি", "২ কেজি আলু", "ডিম ১ ডজন", "potato 2kg" সব বোঝে; বাংলা ও ইংরেজি সংখ্যা দুটোই।
- পাঠানোর আগে প্রিভিউ: সঙ্গীর নাম, জিনিসের সংখ্যা, সময়।

### ৮.৩. বাজার মোড

```
┌────────────────────────────────────┐
│ ←  আজকের বাজার           ⋮         │
│ ম্যাডাম পাঠিয়েছেন • সন্ধ্যা ৭টার মধ্যে  │
│                                    │
│     🛍️  ▓▓▓▓▓▓▓▓░░░░  ৭/১২          │  ← BagProgress (ব্যাগ ভরে ওঠে)
│     খরচ ৳১,২৪০ / বাজেট ৳২,০০০         │
│                                    │
│  বাকি (৫)                           │
│  ┌──────────────────────────────┐  │
│  │ ◻️  ইলিশ               ১টা    │  │
│  │     "মাঝারি সাইজ"   📷       │  │
│  ├──────────────────────────────┤  │
│  │ ◻️  কাঁচা মরিচ        ২৫০ গ্রাম │  │
│  └──────────────────────────────┘  │
│  কেনা হয়েছে (৬) ▾                    │
│  পাওয়া যায়নি (১) ▾                   │
│                                    │
│  📶 অফলাইন — টিকগুলো ফোনে জমা আছে    │  ← শুধু অফলাইনে, sticky রঙ
│                                    │
│  [      বাজার শেষ ✓       ]        │
└────────────────────────────────────┘
```
- বাজার মোডে স্ক্রিন জেগে থাকে (`wakelock_plus`), বের হলে বন্ধ।
- সব কিছু নিচের অর্ধেকে রাখার চেষ্টা (বুড়ো আঙুলের নাগালে)।
- ছবিতে ট্যাপে পূর্ণ স্ক্রিনে দেখায় (দোকানদারকে দেখানোর জন্য)।
- "বাজার শেষ" চাপলে বাকি জিনিস থাকলে জিজ্ঞেস: "৩টি জিনিস বাকি। এগুলো 'পাওয়া যায়নি' হিসেবে শেষ করবেন?"

### ৮.৪. ফর্দ লাইভ ভিউ (প্রেরক)
- বাজার মোডের মতোই, কিন্তু শুধু-দেখার; উপরে সঙ্গীর অবস্থা: "জনাব বাজারে আছেন • শেষ টিক ২ মিনিট আগে"।
- নতুন টিক এলে ঐ সারিতে হালকা সবুজ পালস (৪৫০ms)।
- "পাওয়া যায়নি" সারির নিচে "বিকল্প বলুন" ইনপুট।
- নিচে: `[ + জিনিস যোগ ]` ও `[ একটা মিষ্টি খোঁচা 👉 ]` (কুলডাউনে "২৩ মিনিট পর আবার")।

### ৮.৫. দলিল লেখা

```
┌────────────────────────────────────┐   ← ব্যাকগ্রাউন্ড blush, হালকা কাগজ টেক্সচার
│ ✕                        🔥 ১২ দিন  │
│                                    │
│   "আজ সঙ্গীর কোন কথাটা মনে রাখার মতো?" │  ← title, Baloo
│                                    │
│  ┌──────────────────────────────┐  │
│  │ আজ অফিস থেকে ফিরে দেখি ও     │  │  ← letter স্টাইল (Tiro Bangla),
│  │ আমার প্রিয় চা বানিয়ে রেখেছে…  │  │     রুলড পেপারের লাইন
│  │                              │  │
│  └──────────────────────────────┘  │
│                         ১২৪/৫০০    │
│                                    │
│  ❤️  😂  🙏  🌟  🫶                  │  ← মুড, বাছাই করলে বড় হয়
│  📷 ছবি যোগ করুন                    │
│                                    │
│  🔒 শুধু আপনি দেখতে পাচ্ছেন।          │
│     ৯ ফেব্রুয়ারি তাঁর কাছে পৌঁছাবে। │
│                                    │
│  [     দলিলে রাখুন  💌      ]       │
└────────────────────────────────────┘
```

### ৮.৬. দলিল রিভিল
1. পুরো স্ক্রিন অন্ধকার হয়ে মাঝখানে খাম ভেসে ওঠে (gold সিল)।
2. "সিল ভাঙতে ট্যাপ করুন" (সিল হালকা কাঁপছে)।
3. ট্যাপ → সিল ভাঙা → খাম খোলা → চিঠির স্তূপ উঠে আসে।
4. Story-ভিউ: উপরে প্রোগ্রেস দাগ, প্রতিটি কার্ডে তারিখ, মুড, টেক্সট, ছবি; ট্যাপে পরের, চেপে ধরলে থামে।
5. শেষ কার্ড: পরিসংখ্যান + `[PDF ডাউনলোড]` `[ধন্যবাদ জানান ❤️]`।

### ৮.৭. খালি স্টেট
| স্ক্রিন | মাস্কট | কপি |
|---|---|---|
| কোনো ফর্দ নেই | গিন্নি খালি কাগজ হাতে | "এখনো কোনো ফর্দ নেই। প্রথম বাজারের লিস্টটা বানিয়ে ফেলুন!" |
| কোনো মামলা নেই | কর্তা স্বস্তির নিঃশ্বাস | "এখনো কোনো মামলা নেই। সংসারে শান্তি! 🕊️" |
| দলিল খালি | খাম | "প্রথম চিঠিটা আজই লিখুন। ছোট্ট একটা ভালো কথাই যথেষ্ট।" |
| নেট নেই | কর্তা ফোন উঁচিয়ে নেট খুঁজছে | "নেট নেই, তবে চিন্তা নেই। সব কিছু ফোনে জমা থাকবে।" |

পুরো কপি `CONTENT_BN.md` §৭-এ।

---

## ৯. দলিলের PDF ডিজাইন (A5)

```
কভার                                   এন্ট্রি পাতা
┌─────────────────────────┐            ┌─────────────────────────┐
│ ╔═════════════════════╗ │            │  ১৪ মার্চ ২০২৭     ❤️    │
│ ║                     ║ │            │  ─────────────────────  │
│ ║   ❦ ভালোবাসার দলিল ❦  ║ │            │  আজ অফিস থেকে ফিরে দেখি  │
│ ║                     ║ │            │  ও আমার প্রিয় চা বানিয়ে  │
│ ║      ( গোল্ড সিল )    ║ │            │  রেখেছে। ছোট্ট কাজ, কিন্তু│
│ ║                     ║ │            │  মনটা ভরে গেল।           │
│ ║  প্রাপক: নুসরাত       ║ │            │                         │
│ ║  লেখক:  রাফি         ║ │            │  ১৫ মার্চ ২০২৭     😂    │
│ ║                     ║ │            │  ─────────────────────  │
│ ║ অক্টো ২০২৬ – মার্চ ২০২৭ ║ │            │  রান্না পুড়িয়েও যেভাবে  │
│ ╚═════════════════════╝ │            │  হাসছিল…                │
│   কাগজের টেক্সচার        │            │                 — ৩ —   │
└─────────────────────────┘            └─────────────────────────┘
```
- ব্যাকগ্রাউন্ড: `paper` + হালকা কাগজ টেক্সচার; বর্ডার `gold` ডাবল লাইন।
- টেক্সট: Tiro Bangla ১৪pt (প্রিন্টে পড়তে আরাম)।
- ছবিসহ এন্ট্রি: একটি পাতায় একটি, ছবি উপরে ৪:৩, নিচে লেখা।
- শেষ পাতা: "১৮০ দিনে ১৫৪টি প্রশংসা", সবচেয়ে বেশি ব্যবহৃত মুড, প্রথম ও শেষ চিঠির তারিখ, সমাপনী লাইন: "এই দলিলের প্রতিটি কথা সত্য, এবং ভালোবাসায় সিলমোহর করা।"
- PDF কখনো ডার্ক মোডে নয়।

---

## ১০. আইকন ও ইলাস্ট্রেশন

- UI আইকন: Material Symbols **Rounded** (Flutter-এর `Icons.*_rounded`), স্ট্রোক ২px অনুভূতি।
- ক্যাটাগরি ও মুডে ইমোজি (🛒💊✅🦟🧹❤️😂) — বাংলাদেশি ইউজারদের কাছে পরিচিত ও দ্রুত বোঝা যায়। iOS ও Android-এ ইমোজি দেখতে আলাদা, এটা গ্রহণযোগ্য।
- ইলাস্ট্রেশন: মাস্কট ও খাম Rive-এ; স্থির ছবি SVG থেকে PNG (2x, 3x)।

### Rive অ্যাসেট স্পেক
| ফাইল | Artboard | ViewModel ইনপুট |
|---|---|---|
| `splash.riv` | Splash | `play` (trigger) |
| `pairing.riv` | Pairing | `join` (trigger) |
| `paper_plane.riv` | Send | `fly` (trigger) |
| `bag.riv` | Bag | `progress` (number ০–১০০), `drop` (trigger) |
| `envelope.riv` | Envelope | `insert`, `breakSeal`, `open` (triggers) |
| `gavel.riv` | Gavel | `strike` (trigger) |
| `mascots.riv` | Ginni, Korta | `mood` (enum: idle, happy, impatient, proud / idle, confused, scared, victorious) |

শুরুতে নিজে না বানালে Rive Community বা LottieFiles থেকে লাইসেন্স দেখে ফ্রি অ্যাসেট দিয়ে প্রোটোটাইপ করুন। প্রতিটি অ্যানিমেশনের একটি স্থির ফলব্যাক রাখুন (Rive লোড ব্যর্থ বা Reduce Motion হলে)।

---

## ১১. ডার্ক মোড

- `paper` গাঢ় উষ্ণ বাদামি (`#1C1714`), খাঁটি কালো নয়।
- কার্ডে ছায়ার বদলে `line` বর্ডার।
- স্টিকি নোট ডার্কে গাঢ় সরিষা (`#5C4E1E`), টেক্সট `ink` (হালকা)।
- ছবি ও মাস্কট অপরিবর্তিত; শুধু তাদের পেছনে হালকা গোল আলো যাতে হারিয়ে না যায়।
- Wrapped শেয়ার ছবি ও PDF সবসময় লাইট থিমে।

---

## ১২. অ্যাক্সেসিবিলিটি চেকলিস্ট

- [ ] প্রতিটি আইকন-বাটনে `Semantics(label:)` বাংলায় ("ফর্দ পাঠান", "জিনিস মুছুন")
- [ ] বাজার মোডের সারিতে স্ক্রিন রিডার পড়বে: "আলু, ২ কেজি, বাকি। কেনা হিসেবে চিহ্নিত করতে ডাবল ট্যাপ।"
- [ ] সোয়াইপ অ্যাকশনের বিকল্প: সারিতে ট্যাপ = কেনা; লম্বা চাপের মেনুতে বাকি অপশন
- [ ] টেক্সট ১.৩x করলে কোনো টেক্সট কাটে না
- [ ] সব রঙের জোড়া AA কনট্রাস্ট পাস করে
- [ ] Reduce Motion সম্মানিত
- [ ] ফোকাস অর্ডার যুক্তিসঙ্গত (উপর থেকে নিচে)
