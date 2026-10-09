# Backend Design (Go): বউ রিমাইন্ডার API

| বিষয় | বিবরণ |
|---|---|
| ভাষা | Go 1.27.1 |
| ডেটাবেস | Neon Postgres 17 (`aws-ap-southeast-1`) |
| ফাইল | Neon Object Storage (S3-compatible, path-style) |
| Auth | Firebase ID token যাচাই (Firebase Admin SDK for Go) |
| Push | FCM (Firebase Admin SDK for Go) |
| জব কিউ | River (Postgres-ভিত্তিক) |
| রিয়েলটাইম | WebSocket (`github.com/coder/websocket`) |
| হোস্টিং | Docker → Fly.io `sin` (সিঙ্গাপুর) |
| সংশ্লিষ্ট | `SYSTEM_DESIGN.md` (ক্লায়েন্ট ও সিঙ্ক) |

---

## ১. সার্ভারের দায়িত্ব

1. **ডেটার মালিক:** সব অ্যাপ-ডেটা Postgres-এ; সব অনুমতি (authorization) এখানে প্রয়োগ।
2. **সিঙ্ক:** ক্লায়েন্টের outbox অপারেশন গ্রহণ (push) ও পরিবর্তন পাঠানো (pull)।
3. **রিয়েলটাইম সিগন্যাল:** WebSocket-এ "changed" ইভেন্ট।
4. **ফাইল:** presigned আপলোড/ডাউনলোড URL দেওয়া; ক্লায়েন্ট কখনো স্টোরেজের কী দেখে না।
5. **পুশ:** সঙ্গীর কাজে FCM নোটিফিকেশন, রিট্রাইসহ।
6. **সময়-নির্ভর কাজ:** দলিল আনলক, ফর্দের ডেডলাইন, মাসিক রিপোর্ট, ক্লিনআপ।
7. **অনলাইন-অ্যাকশন:** পেয়ারিং, মনে করানো (nudge), দলিল "এখনই উপহার", এক্সপোর্ট, অ্যাকাউন্ট ডিলিট।

---

## ২. মডিউল (`go.mod`)

```go
module github.com/yourname/bou-reminder/api

go 1.27

require (
    firebase.google.com/go/v4 v4.22.0
    github.com/aws/aws-sdk-go-v2 v1.x            // core; service/s3 v1.114.x
    github.com/aws/aws-sdk-go-v2/config v1.x
    github.com/aws/aws-sdk-go-v2/credentials v1.x
    github.com/aws/aws-sdk-go-v2/service/s3 v1.114.1
    github.com/caarlos0/env/v11 v11.4.1
    github.com/coder/websocket v1.8.15
    github.com/getsentry/sentry-go v0.49.0
    github.com/google/uuid v1.x                  // UUIDv7: uuid.NewV7()
    github.com/jackc/pgx/v5 v5.11.0
    github.com/pressly/goose/v3 v3.28.0
    github.com/riverqueue/river v0.49.0
    github.com/riverqueue/river/riverdriver/riverpgxv5 v0.49.0
    github.com/robfig/cron/v3 v3.0.1
    golang.org/x/time v0.x                       // rate limiter
    google.golang.org/api v0.300.0
)

tool (
    github.com/sqlc-dev/sqlc/cmd/sqlc            // v1.31.x — `go tool sqlc generate`
    github.com/pressly/goose/v3/cmd/goose
)
```
`v1.x` লেখা জায়গাগুলোতে `go get <module>@latest` চালালে সর্বশেষ ভার্সন বসে যাবে। শুরুর পর নিয়মিত `go get -u ./... && go mod tidy`।

**কেন এই লাইব্রেরি:**
| লাইব্রেরি | কারণ |
|---|---|
| `net/http` (stdlib) | Go 1.22+ রাউটারে মেথড ও পাথ প্যারামিটার আছে (`"POST /v1/pair/{code}"`); আলাদা ফ্রেমওয়ার্ক লাগে না |
| pgx v5 + sqlc | টাইপ-সেফ SQL, ORM ছাড়া দ্রুত ও পরিষ্কার |
| goose | সরল SQL মাইগ্রেশন |
| River | জব কিউ একই Postgres-এ; **ট্রানজ্যাকশনের ভেতরে জব যোগ** করা যায় (ডেটা লেখা ও পুশ জব একসাথে commit বা rollback) |
| coder/websocket | আধুনিক, context-সমর্থিত WebSocket |
| aws-sdk-go-v2 | Neon Object Storage S3-compatible, তাই স্ট্যান্ডার্ড SDK |

---

## ৩. প্রজেক্ট স্ট্রাকচার

```
api/
├── cmd/
│   └── server/main.go            # একটাই বাইনারি: HTTP + WS + River workers
├── internal/
│   ├── config/config.go          # env → struct
│   ├── db/
│   │   ├── migrations/           # 0001_init.sql, 0002_bazar.sql ...
│   │   ├── queries/              # sqlc .sql ফাইল
│   │   ├── sqlc/                 # জেনারেটেড কোড (কমিট করুন)
│   │   └── tx.go                 # WithTx হেল্পার
│   ├── auth/
│   │   ├── firebase.go           # টোকেন যাচাই
│   │   └── middleware.go         # ctx-এ UserID, CoupleID
│   ├── httpx/
│   │   ├── errors.go             # {"error":{"code","message"}}
│   │   ├── json.go               # decode/validate/encode
│   │   └── middleware.go         # recover, logging, request-id, rate limit, version gate
│   ├── realtime/
│   │   ├── hub.go                # কাপল-ভিত্তিক সংযোগ
│   │   ├── ws.go                 # /v1/ws হ্যান্ডলার
│   │   └── pgnotify.go           # একাধিক ইন্সট্যান্সে LISTEN/NOTIFY
│   ├── storage/s3.go             # presign PUT/GET, delete
│   ├── push/fcm.go               # FCM পাঠানো, অচল টোকেন মোছা
│   ├── jobs/                     # River JobArgs + Workers
│   │   ├── push_job.go
│   │   ├── deed_unlock.go
│   │   ├── bazar_due.go
│   │   ├── bazar_catalog.go
│   │   ├── wrapped.go
│   │   ├── export.go
│   │   └── cleanup.go
│   ├── sync/
│   │   ├── push.go               # POST /v1/sync/push
│   │   ├── pull.go               # GET /v1/sync/pull
│   │   ├── changelog.go          # RecordChange (seq + NOTIFY)
│   │   └── entities/             # প্রতিটি এনটিটির ভ্যালিডেশন ও প্রয়োগ
│   │       ├── registry.go
│   │       ├── bazar_list.go
│   │       ├── bazar_item.go
│   │       ├── deed_entry.go
│   │       ├── special_date.go
│   │       ├── case.go
│   │       └── ...
│   └── features/                 # অনলাইন-অ্যাকশন হ্যান্ডলার
│       ├── me/
│       ├── pairing/
│       ├── bazar/                # nudge, share-text
│       ├── deeds/                # gift-now, open, thank
│       ├── files/
│       ├── account/              # export, delete
│       └── appconfig/            # /v1/config
├── sqlc.yaml
├── Dockerfile
├── fly.toml
├── Makefile
├── api.http                      # VS Code REST Client দিয়ে টেস্ট
└── .env.example
```

---

## ৪. কনফিগারেশন (`.env.example`)

```bash
# Server
PORT=8080
ENV=dev                                   # dev | staging | prod
MIN_APP_VERSION=1.0.0                     # এর নিচে হলে 426 + force update
LOG_LEVEL=info

# Neon Postgres
# pooled: অ্যাপের সাধারণ কোয়েরি (হোস্টে "-pooler" থাকে)
DATABASE_URL=postgresql://app:***@ep-xxx-pooler.ap-southeast-1.aws.neon.tech/bou?sslmode=require
# direct: River (LISTEN/NOTIFY) ও মাইগ্রেশনের জন্য — PgBouncer ট্রানজ্যাকশন মোডে LISTEN কাজ করে না
DATABASE_DIRECT_URL=postgresql://app:***@ep-xxx.ap-southeast-1.aws.neon.tech/bou?sslmode=require

# Neon Object Storage (Neon কনসোল / `neon env pull` থেকে)
AWS_ENDPOINT_URL_S3=https://<branch-s3-endpoint>
AWS_REGION=ap-southeast-1
AWS_ACCESS_KEY_ID=***
AWS_SECRET_ACCESS_KEY=***
S3_BUCKET=bou-private

# Firebase (Auth + FCM)
FIREBASE_PROJECT_ID=bou-reminder-prod
FIREBASE_CREDENTIALS_JSON='{"type":"service_account",...}'
# লোকাল ডেভে Auth emulator ব্যবহার করলে:
# FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099

# Monitoring
SENTRY_DSN=
```

```go
// internal/config/config.go
type Config struct {
    Port            int    `env:"PORT" envDefault:"8080"`
    Env             string `env:"ENV" envDefault:"dev"`
    MinAppVersion   string `env:"MIN_APP_VERSION" envDefault:"1.0.0"`
    DatabaseURL     string `env:"DATABASE_URL,required"`
    DatabaseDirect  string `env:"DATABASE_DIRECT_URL,required"`
    S3Endpoint      string `env:"AWS_ENDPOINT_URL_S3,required"`
    S3Region        string `env:"AWS_REGION" envDefault:"ap-southeast-1"`
    S3AccessKey     string `env:"AWS_ACCESS_KEY_ID,required"`
    S3SecretKey     string `env:"AWS_SECRET_ACCESS_KEY,required"`
    S3Bucket        string `env:"S3_BUCKET,required"`
    FirebaseProject string `env:"FIREBASE_PROJECT_ID,required"`
    FirebaseCreds   string `env:"FIREBASE_CREDENTIALS_JSON"`
    SentryDSN       string `env:"SENTRY_DSN"`
}

func Load() (Config, error) { return env.ParseAs[Config]() }
```
সিক্রেট কখনো git-এ নয়। Fly.io-তে `fly secrets set KEY=value`।

---

## ৫. ডেটাবেস স্কিমা (Postgres)

### ৫.১. নিয়ম
- প্রাইমারি কী: `uuid` (UUIDv7, ক্লায়েন্ট বা সার্ভার তৈরি করে)।
- সময়: সবসময় `timestamptz` (UTC-তে রাখা, Asia/Dhaka-তে দেখানো)।
- জন্মদিন/বিয়ের তারিখ: `month`, `day`, `year` আলাদা কলাম (টাইমজোনের কারণে তারিখ সরে যাওয়া রোধে)।
- টাকা: `bigint` পয়সায়।
- ডিলিট: সিঙ্কযোগ্য টেবিলে soft delete (`deleted_at`), ক্লিনআপ জব ৩০ দিন পর আসল ডিলিট করে।
- প্রতিটি সিঙ্কযোগ্য টেবিলে `couple_id` (অনুমতি যাচাই ও ইনডেক্সের জন্য)।

### ৫.২. মাইগ্রেশন `0001_init.sql`

```sql
-- +goose Up
CREATE TABLE users (
    id               uuid PRIMARY KEY,
    firebase_uid     text NOT NULL UNIQUE,
    display_name     text NOT NULL DEFAULT '',
    nickname         text NOT NULL DEFAULT '',
    role             text CHECK (role IN ('wife','husband')),
    birthday_month   smallint CHECK (birthday_month BETWEEN 1 AND 12),
    birthday_day     smallint CHECK (birthday_day BETWEEN 1 AND 31),
    birthday_year    smallint,
    photo_key        text,
    couple_id        uuid,
    locale           text NOT NULL DEFAULT 'bn',
    settings         jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now(),
    deletion_requested_at timestamptz
);

CREATE TABLE couples (
    id                 uuid PRIMARY KEY,
    wedding_month      smallint,
    wedding_day        smallint,
    wedding_year       smallint,
    wedding_set_by     uuid REFERENCES users(id),
    wedding_confirmed  boolean NOT NULL DEFAULT false,
    change_seq         bigint NOT NULL DEFAULT 0,     -- কাপল-ভিত্তিক ক্রমিক সংখ্যা (সিঙ্ক)
    unpair_requested_at timestamptz,
    created_at         timestamptz NOT NULL DEFAULT now(),
    updated_at         timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE users ADD CONSTRAINT users_couple_fk
    FOREIGN KEY (couple_id) REFERENCES couples(id) ON DELETE SET NULL;
CREATE INDEX users_couple_idx ON users(couple_id);

CREATE TABLE pair_codes (
    code        text PRIMARY KEY,                -- ৬ অক্ষর, 0/O/1/I বাদ
    owner_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at  timestamptz NOT NULL,
    used_at     timestamptz
);

CREATE TABLE devices (
    token        text PRIMARY KEY,               -- FCM token
    user_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    platform     text NOT NULL CHECK (platform IN ('android','ios')),
    app_version  text NOT NULL,
    locale       text NOT NULL DEFAULT 'bn',
    last_seen_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX devices_user_idx ON devices(user_id);

-- সিঙ্ক
CREATE TABLE change_log (
    couple_id   uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    seq         bigint NOT NULL,
    entity      text NOT NULL,
    entity_id   uuid NOT NULL,
    op          text NOT NULL CHECK (op IN ('upsert','delete')),
    visible_to  uuid,                            -- NULL = দুজনেই; না হলে শুধু এই user (দলিল)
    changed_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (couple_id, seq)
);

CREATE TABLE processed_ops (
    op_id       uuid PRIMARY KEY,                -- ক্লায়েন্টের outbox opId
    user_id     uuid NOT NULL,
    result      jsonb NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE uploads (
    key          text PRIMARY KEY,               -- couples/{cid}/{purpose}/{uuid}.jpg
    owner_id     uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    couple_id    uuid,
    purpose      text NOT NULL,                  -- avatar | bazar_item | case_evidence | deed | chore | voice
    content_type text NOT NULL,
    size_bytes   bigint NOT NULL,
    private_to   uuid,                           -- দলিলের ছবি: শুধু লেখক
    confirmed_at timestamptz,
    created_at   timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE uploads, processed_ops, change_log, devices, pair_codes;
ALTER TABLE users DROP CONSTRAINT users_couple_fk;
DROP TABLE couples, users;
```

### ৫.৩. `0002_dates_bazar.sql`

```sql
-- +goose Up
CREATE TABLE special_dates (
    id               uuid PRIMARY KEY,
    couple_id        uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    kind             text NOT NULL CHECK (kind IN ('wife_birthday','husband_birthday','anniversary','custom')),
    title            text NOT NULL,
    emoji            text NOT NULL DEFAULT '🎉',
    month            smallint NOT NULL CHECK (month BETWEEN 1 AND 12),
    day              smallint NOT NULL CHECK (day BETWEEN 1 AND 31),
    year             smallint,
    repeats_yearly   boolean NOT NULL DEFAULT true,
    reminder_offsets smallint[] NOT NULL DEFAULT '{7,3,1,0}',
    reminder_time    time NOT NULL DEFAULT '08:00',
    notify_user_ids  uuid[] NOT NULL,
    is_system        boolean NOT NULL DEFAULT false,
    created_by       uuid NOT NULL REFERENCES users(id),
    updated_at       timestamptz NOT NULL DEFAULT now(),
    deleted_at       timestamptz
);
CREATE INDEX special_dates_couple_idx ON special_dates(couple_id) WHERE deleted_at IS NULL;

CREATE TABLE bazar_lists (
    id                 uuid PRIMARY KEY,
    couple_id          uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    kind               text NOT NULL DEFAULT 'bazar' CHECK (kind IN ('bazar','medicine','tasks')),
    title              text NOT NULL,
    status             text NOT NULL DEFAULT 'draft'
                       CHECK (status IN ('draft','sent','shopping','done','cancelled')),
    created_by         uuid NOT NULL REFERENCES users(id),
    assigned_to        uuid REFERENCES users(id),
    due_at             timestamptz,
    budget_paisa       bigint CHECK (budget_paisa >= 0),
    note               text CHECK (char_length(note) <= 300),
    item_count         int NOT NULL DEFAULT 0,
    done_count         int NOT NULL DEFAULT 0,
    total_spent_paisa  bigint NOT NULL DEFAULT 0,
    rating             text CHECK (rating IN ('great','ok','case')),
    sent_at            timestamptz,
    started_at         timestamptz,
    completed_at       timestamptz,
    last_nudge_at      timestamptz,
    due_reminded_at    timestamptz,
    template_name      text,                       -- নাম থাকলে এটি টেমপ্লেট (P1)
    updated_at         timestamptz NOT NULL DEFAULT now(),
    deleted_at         timestamptz
);
CREATE INDEX bazar_lists_couple_idx ON bazar_lists(couple_id, updated_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX bazar_lists_due_idx ON bazar_lists(due_at)
    WHERE status = 'sent' AND due_reminded_at IS NULL AND deleted_at IS NULL;

CREATE TABLE bazar_items (
    id               uuid PRIMARY KEY,
    list_id          uuid NOT NULL REFERENCES bazar_lists(id) ON DELETE CASCADE,
    couple_id        uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    name             text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 80),
    qty              numeric(10,3),
    unit             text CHECK (unit IN ('kg','g','l','ml','pcs','hali','dozen','ati','pack','pata','box','bottle')),
    category         text NOT NULL DEFAULT 'other'
                     CHECK (category IN ('veg','fish_meat','grocery','fruit','dairy_egg','medicine','household','other')),
    note             text CHECK (char_length(note) <= 200),
    photo_key        text,
    status           text NOT NULL DEFAULT 'pending'
                     CHECK (status IN ('pending','bought','unavailable','substituted')),
    substitute_note  text CHECK (char_length(substitute_note) <= 200),
    price_paisa      bigint CHECK (price_paisa >= 0),
    position         int NOT NULL DEFAULT 0,
    checked_by       uuid REFERENCES users(id),
    checked_at       timestamptz,
    updated_at       timestamptz NOT NULL DEFAULT now(),
    deleted_at       timestamptz
);
CREATE INDEX bazar_items_list_idx ON bazar_items(list_id, position) WHERE deleted_at IS NULL;

-- ঘনঘন কেনা জিনিস ও দামের ইতিহাস
CREATE TABLE bazar_catalog (
    couple_id         uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    normalized_name   text NOT NULL,             -- lower + trim + বাংলা/ইংরেজি সংখ্যা সমান
    display_name      text NOT NULL,
    unit              text,
    category          text NOT NULL,
    buy_count         int NOT NULL DEFAULT 0,
    last_price_paisa  bigint,
    last_qty          numeric(10,3),
    last_bought_at    timestamptz,
    PRIMARY KEY (couple_id, normalized_name)
);
CREATE INDEX bazar_catalog_top_idx ON bazar_catalog(couple_id, buy_count DESC);

-- +goose Down
DROP TABLE bazar_catalog, bazar_items, bazar_lists, special_dates;
```

### ৫.৪. `0003_deeds.sql`

```sql
-- +goose Up
CREATE TABLE deed_vaults (
    author_id              uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    couple_id              uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    recipient_id           uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cycle_type             text NOT NULL DEFAULT 'anniversary' CHECK (cycle_type IN ('1m','6m','anniversary')),
    cycle_started_at       timestamptz NOT NULL DEFAULT now(),
    unlock_at              timestamptz NOT NULL,
    entry_count            int NOT NULL DEFAULT 0,      -- চলতি সাইকেলের, সার্ভার গণনা করে
    streak                 int NOT NULL DEFAULT 0,
    last_entry_date        date,
    show_count_to_partner  boolean NOT NULL DEFAULT true,
    updated_at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX deed_vaults_unlock_idx ON deed_vaults(unlock_at);

CREATE TABLE delivered_deeds (
    id                uuid PRIMARY KEY,
    couple_id         uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    author_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_start      timestamptz NOT NULL,
    period_end        timestamptz NOT NULL,
    entry_count       int NOT NULL,
    trigger           text NOT NULL CHECK (trigger IN ('scheduled','gift_now')),
    delivered_at      timestamptz NOT NULL DEFAULT now(),
    opened_at         timestamptz,
    thank_you_message text CHECK (char_length(thank_you_message) <= 300),
    UNIQUE (author_id, period_start)                -- একই সাইকেল দুবার ডেলিভারি হবে না
);

CREATE TABLE deed_entries (
    id                uuid PRIMARY KEY,
    author_id         uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    couple_id         uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    entry_date        date NOT NULL,                -- Asia/Dhaka-র দিন
    text              text NOT NULL CHECK (char_length(text) BETWEEN 10 AND 500),
    mood              text NOT NULL CHECK (mood IN ('love','laugh','grateful','proud','care')),
    photo_key         text,
    prompt_id         text,
    delivered_deed_id uuid REFERENCES delivered_deeds(id) ON DELETE SET NULL,
    created_at        timestamptz NOT NULL DEFAULT now(),
    updated_at        timestamptz NOT NULL DEFAULT now(),
    deleted_at        timestamptz,
    UNIQUE (author_id, entry_date)
);
CREATE INDEX deed_entries_open_idx ON deed_entries(author_id) WHERE delivered_deed_id IS NULL AND deleted_at IS NULL;
CREATE INDEX deed_entries_delivered_idx ON deed_entries(delivered_deed_id);

-- +goose Down
DROP TABLE deed_entries, delivered_deeds, deed_vaults;
```

**দলিলের গোপনীয়তার মূল নিয়ম (একটাই জায়গায়):**
> একটি `deed_entries` সারি পড়তে পারবেন **(ক)** তার লেখক, অথবা **(খ)** প্রাপক, **শুধু যদি `delivered_deed_id IS NOT NULL`**।

ডেলিভারির সময় এন্ট্রি কপি করতে হয় না; শুধু `delivered_deed_id` সেট করলেই প্রাপক পড়তে পারেন। এই নিয়মটি `queries/deeds.sql`-এর প্রতিটি SELECT-এ প্রয়োগ হবে, এবং §১৫-এর টেস্ট দিয়ে যাচাই হবে।

### ৫.৫. `0004_cases_misc.sql` (সংক্ষেপে)

```sql
-- +goose Up
CREATE TABLE cases (
    id             uuid PRIMARY KEY,
    couple_id      uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    title          text NOT NULL CHECK (char_length(title) BETWEEN 3 AND 80),
    category       text NOT NULL,
    description    text CHECK (char_length(description) <= 1000),
    plaintiff_id   uuid NOT NULL REFERENCES users(id),
    defendant_id   uuid NOT NULL REFERENCES users(id),
    incident_date  date NOT NULL,
    evidence_keys  text[] NOT NULL DEFAULT '{}',
    bazar_list_id  uuid REFERENCES bazar_lists(id) ON DELETE SET NULL,
    status         text NOT NULL DEFAULT 'open' CHECK (status IN ('open','guilty','acquitted','settled')),
    punishment     text,
    verdict_at     timestamptz,
    created_at     timestamptz NOT NULL DEFAULT now(),
    updated_at     timestamptz NOT NULL DEFAULT now(),
    deleted_at     timestamptz
);

CREATE TABLE case_replies (
    id uuid PRIMARY KEY, case_id uuid NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
    couple_id uuid NOT NULL, author_id uuid NOT NULL REFERENCES users(id),
    text text NOT NULL CHECK (char_length(text) <= 1000),
    created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE chore_logs (
    id uuid PRIMARY KEY, couple_id uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    done_by uuid NOT NULL REFERENCES users(id), category text NOT NULL,
    note text, photo_key text, done_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz
);

CREATE TABLE wardrobe_items (
    id uuid PRIMARY KEY, couple_id uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    owner_id uuid NOT NULL REFERENCES users(id), category text NOT NULL,
    count int NOT NULL DEFAULT 0 CHECK (count >= 0), photo_keys text[] NOT NULL DEFAULT '{}',
    updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz
);

CREATE TABLE ledger_entries (
    id uuid PRIMARY KEY, couple_id uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    lender_id uuid NOT NULL REFERENCES users(id), borrower_id uuid NOT NULL REFERENCES users(id),
    kind text NOT NULL CHECK (kind IN ('money','promise')),
    amount_paisa bigint, description text NOT NULL, funny_interest text,
    settled_at timestamptz, created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz
);

CREATE TABLE apologies (
    id uuid PRIMARY KEY, couple_id uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    from_id uuid NOT NULL REFERENCES users(id), to_id uuid NOT NULL REFERENCES users(id),
    category text NOT NULL, message text NOT NULL,
    status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected')),
    created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);

CREATE TABLE promises (
    id uuid PRIMARY KEY, couple_id uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    by_id uuid NOT NULL REFERENCES users(id), to_id uuid NOT NULL REFERENCES users(id),
    text text NOT NULL, due_at timestamptz, done_at timestamptz,
    updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz
);

CREATE TABLE wrapped_reports (
    couple_id uuid NOT NULL REFERENCES couples(id) ON DELETE CASCADE,
    month char(7) NOT NULL,                       -- '2026-09'
    slides jsonb NOT NULL,
    generated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (couple_id, month)
);
```

River-এর নিজস্ব টেবিল তৈরি: `go run github.com/riverqueue/river/cmd/river migrate-up --database-url "$DATABASE_DIRECT_URL"` (অথবা `rivermigrate` প্যাকেজ দিয়ে স্টার্টআপে)।

---

## ৬. সিঙ্ক প্রোটোকল (সার্ভার)

### ৬.১. পরিবর্তন রেকর্ড করা

প্রতিটি সিঙ্কযোগ্য রেকর্ড লেখার **একই ট্রানজ্যাকশনে**:

```go
// internal/sync/changelog.go
func RecordChange(ctx context.Context, tx pgx.Tx, c Change) (int64, error) {
    // কাপলের সারি লক + ক্রমিক সংখ্যা বাড়ানো। এতে একই কাপলের ট্রানজ্যাকশনগুলো
    // ক্রমানুসারে commit হয়, তাই ক্লায়েন্টের cursor কখনো কোনো পরিবর্তন লাফিয়ে যায় না।
    var seq int64
    if err := tx.QueryRow(ctx,
        `UPDATE couples SET change_seq = change_seq + 1 WHERE id = $1 RETURNING change_seq`,
        c.CoupleID).Scan(&seq); err != nil {
        return 0, err
    }
    _, err := tx.Exec(ctx,
        `INSERT INTO change_log (couple_id, seq, entity, entity_id, op, visible_to)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        c.CoupleID, seq, c.Entity, c.EntityID, c.Op, c.VisibleTo)
    if err != nil {
        return 0, err
    }
    // commit হলে তবেই NOTIFY পৌঁছায়; rollback হলে কিছু যায় না
    _, err = tx.Exec(ctx, `SELECT pg_notify('couple_changes', $1)`,
        fmt.Sprintf("%s:%d:%s", c.CoupleID, seq, uuidOrEmpty(c.VisibleTo)))
    return seq, err
}
```

> কেন গ্লোবাল `bigserial` নয়: দুটো ট্রানজ্যাকশন seq 10 ও 11 পেয়ে উল্টো ক্রমে commit হলে ক্লায়েন্ট 11 দেখে cursor এগিয়ে নেবে আর 10 চিরতরে মিস করবে। কাপল-সারির লক এই সমস্যা দূর করে, আর কাপলপ্রতি লেখার হার কম বলে লক কোনো বাধা নয়।

### ৬.২. `POST /v1/sync/push`

**Request**
```json
{
  "ops": [
    {
      "op_id": "0192f3a1-...",
      "entity": "bazar_item",
      "entity_id": "0192f3a0-...",
      "op": "patch",
      "payload": { "status": "bought", "price_paisa": 12000, "client_updated_at": "2026-10-08T11:02:13Z" }
    }
  ]
}
```
**Response**
```json
{
  "results": [
    { "op_id": "0192f3a1-...", "ok": true, "seq": 1234 },
    { "op_id": "0192f3a2-...", "ok": false, "permanent": true, "error": { "code": "forbidden" } }
  ]
}
```

**প্রতিটি op-এর জন্য (নিজস্ব ট্রানজ্যাকশনে):**
1. `processed_ops`-এ `op_id` থাকলে আগের `result` ফেরত দিন (idempotent; নেট কেটে গিয়ে ক্লায়েন্ট আবার পাঠালেও দুবার প্রয়োগ হবে না)।
2. `entities.Registry[entity]` থেকে হ্যান্ডলার নিন; না থাকলে `permanent: unknown_entity`।
3. হ্যান্ডলার যাচাই করে: রেকর্ডটি কি এই ইউজারের কাপলের? এই ইউজার কি এই ফিল্ড বদলাতে পারেন? মানগুলো কি বৈধ?
4. প্রয়োগ → `RecordChange` → প্রয়োজনে River জব যোগ (`riverClient.InsertTx(ctx, tx, ...)`)।
5. `processed_ops`-এ ফলাফল লিখে commit।

**এরর শ্রেণী:** `permanent: true` (ভ্যালিডেশন, অনুমতি, অজানা এনটিটি; ক্লায়েন্ট op বাদ দেবে) বনাম অস্থায়ী (DB টাইমআউট ইত্যাদি; ক্লায়েন্ট পরে আবার চেষ্টা করবে)।

### ৬.৩. এনটিটি হ্যান্ডলার ইন্টারফেস

```go
// internal/sync/entities/registry.go
type Actor struct {
    UserID    uuid.UUID
    CoupleID  uuid.UUID
    PartnerID uuid.UUID
}

type Handler interface {
    // Apply প্রয়োগ করে এবং কোন change রেকর্ড হবে তা ফেরত দেয়
    Apply(ctx context.Context, tx pgx.Tx, a Actor, op Op) (Change, error)
}

var Registry = map[string]Handler{
    "special_date": specialDateHandler{},
    "bazar_list":   bazarListHandler{},
    "bazar_item":   bazarItemHandler{},
    "deed_entry":   deedEntryHandler{},
    "case":         caseHandler{},
    "case_reply":   caseReplyHandler{},
    "chore_log":    choreLogHandler{},
    "wardrobe_item": wardrobeHandler{},
    "ledger_entry": ledgerHandler{},
    "apology":      apologyHandler{},
    "promise":      promiseHandler{},
}
```

**উদাহরণ: `bazar_list` স্ট্যাটাস পরিবর্তনের সাইড-ইফেক্ট**

| পরিবর্তন | কে করতে পারেন | সাইড-ইফেক্ট (একই ট্রানজ্যাকশনে) |
|---|---|---|
| `draft → sent` | প্রেরক | `sent_at = now()`, `assigned_to = partner`; PushJob("bazar_sent") সঙ্গীকে |
| `sent → shopping` | প্রাপক (বা প্রথম টিকে স্বয়ংক্রিয়) | `started_at`; PushJob("bazar_started") প্রেরককে |
| `shopping/sent → done` | প্রাপক | `completed_at`; PushJob("bazar_done", সারাংশসহ) প্রেরককে; CatalogUpdateJob |
| `* → cancelled` | প্রেরক | PushJob("bazar_cancelled") প্রাপককে |
| `rating` সেট | প্রেরক, শুধু `done`-এর পরে | রেটিং "case" হলে কিছু নয় (ক্লায়েন্ট মামলা স্ক্রিন খোলে) |

**`bazar_item` হ্যান্ডলার:**
- `status` বদলালে `checked_by`, `checked_at` সার্ভার নিজে বসায়।
- একই ট্রানজ্যাকশনে তালিকার `item_count`, `done_count`, `total_spent_paisa` পুনর্গণনা (`UPDATE bazar_lists SET ... = (SELECT count(*) ...)`)। তালিকার জন্যও `RecordChange`।
- তালিকা `sent` অবস্থায় থাকলে প্রথম টিকে স্বয়ংক্রিয়ভাবে `shopping`।
- `status = unavailable` হলে PushJob("bazar_item_unavailable") প্রেরককে, River unique opts দিয়ে একই তালিকার জন্য ২ মিনিটে একবার।
- `sent` হওয়ার পর প্রেরক জিনিস যোগ/বাদ দিলে PushJob("bazar_updated"), unique by list, ৫ মিনিটের উইন্ডো, ২ মিনিট দেরিতে (একাধিক পরিবর্তন একসাথে)।

**`deed_entry` হ্যান্ডলার:**
- শুধু লেখক তৈরি/এডিট করতে পারেন; `delivered_deed_id` সেট থাকলে এডিট নিষেধ।
- `entry_date` আজ বা সর্বোচ্চ ২ দিন আগের (Asia/Dhaka) হতে হবে।
- `photo_key` থাকলে `uploads.private_to = author` যাচাই।
- `RecordChange(..., VisibleTo: &authorID)`: প্রাপক এই change দেখবেন না।
- ভল্টে `entry_count`, `streak`, `last_entry_date` আপডেট; ভল্টের change দুজনের জন্য (প্রাপক শুধু সংখ্যা দেখেন, তাও `show_count_to_partner` true হলে)।

### ৬.৪. `GET /v1/sync/pull?cursor=1200&limit=500`

```sql
-- name: PullChanges :many
SELECT seq, entity, entity_id, op
FROM change_log
WHERE couple_id = $1 AND seq > $2
  AND (visible_to IS NULL OR visible_to = $3)
ORDER BY seq
LIMIT $4;
```
তারপর প্রতিটি এনটিটি টাইপের জন্য আলাদা আইডিগুলো একটি কোয়েরিতে লোড করে বর্তমান অবস্থা পাঠান (একই রেকর্ড একাধিকবার বদলালে একবারই পাঠান)। দলিল এন্ট্রি লোডের কোয়েরিতেও §৫.৪-এর নিয়ম আবার প্রয়োগ হবে (দুই স্তরের সুরক্ষা)।

**Response**
```json
{
  "changes": [
    { "entity": "bazar_item", "id": "0192...", "op": "upsert", "data": { "...": "..." } },
    { "entity": "bazar_item", "id": "0193...", "op": "delete" }
  ],
  "next_cursor": 1234,
  "has_more": false
}
```
- `cursor = 0` হলে পূর্ণ স্ন্যাপশট (নতুন ডিভাইস বা লগইন)।
- ক্লিনআপ জব ৯০ দিনের পুরনো change_log মুছে ফেলে। ক্লায়েন্টের cursor তার চেয়ে পুরনো হলে `410 Gone {"code":"resync_required"}` → ক্লায়েন্ট লোকাল ডেটা মুছে `cursor=0` থেকে আবার আনবে।

---

## ৭. API রেফারেন্স

সব এন্ডপয়েন্ট `Authorization: Bearer <Firebase ID token>` ও `X-App-Version` চায় (ব্যতিক্রম: `/healthz`, `/v1/config`)।

**এরর ফরম্যাট (সব জায়গায় একই):**
```json
{ "error": { "code": "pair_code_expired", "message": "Pair code has expired" } }
```
`code` স্থির ইংরেজি স্ট্রিং; ক্লায়েন্ট এটা দেখে বাংলা মেসেজ দেখায় (`CONTENT_BN.md` §৯)। `message` শুধু ডিবাগের জন্য।

| মেথড ও পাথ | কাজ | নোট |
|---|---|---|
| `GET /healthz` | হেলথ চেক | DB পিং |
| `GET /v1/config` | ন্যূনতম অ্যাপ ভার্সন, মেইনটেন্যান্স, ফিচার ফ্ল্যাগ | auth ছাড়া |
| `POST /v1/me/bootstrap` | প্রথম লগইনে ইউজার তৈরি/ফেরত | idempotent |
| `GET /v1/me` | প্রোফাইল + কাপল + সঙ্গীর পাবলিক প্রোফাইল | |
| `PATCH /v1/me` | নাম, ডাকনাম, রোল, জন্মদিন, ছবি, সেটিংস | জন্মদিন বদলালে system special_date আপডেট |
| `POST /v1/devices` | FCM টোকেন রেজিস্টার | upsert |
| `DELETE /v1/devices/{token}` | লগআউটে টোকেন মোছা | |
| `POST /v1/pair/codes` | নতুন পেয়ার কোড | পুরনো অব্যবহৃত কোড বাতিল |
| `POST /v1/pair/join` | `{code}` দিয়ে যুক্ত হওয়া | §৮.১ |
| `PUT /v1/couple/wedding-date` | বিয়ের তারিখ সেট/কনফার্ম | anniversary special_date তৈরি |
| `POST /v1/couple/unpair` | আনপেয়ার অনুরোধ | ৩০ দিনের গ্রেস |
| `POST /v1/sync/push` | outbox অপারেশন | §৬.২ |
| `GET /v1/sync/pull` | পরিবর্তন আনা | §৬.৪ |
| `GET /v1/ws` | WebSocket | §৯ |
| `POST /v1/uploads/presign` | আপলোড URL | §১০ |
| `POST /v1/uploads/{key}/confirm` | আপলোড সম্পন্ন | HEAD দিয়ে সাইজ যাচাই |
| `GET /v1/files/url?key=` | ১৫ মিনিটের ডাউনলোড URL | অনুমতি যাচাই |
| `POST /v1/bazar/{id}/nudge` | সঙ্গীকে মনে করানো | ৩০ মিনিটে একবার |
| `GET /v1/bazar/{id}/share-text` | WhatsApp/SMS-এর জন্য ফরম্যাট করা টেক্সট | |
| `GET /v1/bazar/catalog/top` | ঘনঘন কেনা ১৫টি | সাজেশন চিপ |
| `GET /v1/bazar/stats?month=2026-09` | মাসিক খরচ (P1) | |
| `PATCH /v1/deeds/vault` | সাইকেল টাইপ, কাউন্ট দেখানো | unlock_at পুনর্গণনা |
| `POST /v1/deeds/gift-now` | এখনই উপহার | ≥ ৭টি এন্ট্রি |
| `GET /v1/deeds/delivered` | প্রাপ্ত ও পাঠানো দলিলের তালিকা | |
| `GET /v1/deeds/delivered/{id}/entries` | একটি দলিলের এন্ট্রি | শুধু লেখক বা প্রাপক |
| `POST /v1/deeds/delivered/{id}/open` | খোলা হয়েছে | লেখককে পুশ |
| `POST /v1/deeds/delivered/{id}/thanks` | ধন্যবাদ মেসেজ | লেখককে পুশ |
| `GET /v1/wrapped/{month}` | মাসিক রিপোর্ট | |
| `POST /v1/account/export` | এক্সপোর্ট শুরু | জব; শেষ হলে পুশ + ডাউনলোড লিংক |
| `DELETE /v1/account` | অ্যাকাউন্ট ডিলিট | §৮.৪ |

**ভার্সন গেট মিডলওয়্যার:** `X-App-Version < MIN_APP_VERSION` হলে `426 Upgrade Required {"code":"update_required"}` → অ্যাপ ফোর্স আপডেট স্ক্রিন।

---

## ৮. গুরুত্বপূর্ণ ফ্লো

### ৮.১. পেয়ারিং

```go
// internal/features/pairing/join.go
func (s *Service) Join(ctx context.Context, me uuid.UUID, code string) (uuid.UUID, error) {
    code = strings.ToUpper(strings.TrimSpace(code))
    var coupleID uuid.UUID
    err := db.WithTx(ctx, s.pool, func(tx pgx.Tx) error {
        var owner uuid.UUID
        var expires time.Time
        var used *time.Time
        err := tx.QueryRow(ctx,
            `SELECT owner_id, expires_at, used_at FROM pair_codes WHERE code = $1 FOR UPDATE`,
            code).Scan(&owner, &expires, &used)
        switch {
        case errors.Is(err, pgx.ErrNoRows):
            return httpx.ErrCode(404, "pair_code_not_found")
        case err != nil:
            return err
        case used != nil:
            return httpx.ErrCode(409, "pair_code_used")
        case time.Now().After(expires):
            return httpx.ErrCode(410, "pair_code_expired")
        case owner == me:
            return httpx.ErrCode(400, "pair_code_own")
        }

        // দুজনের কেউ আগে থেকে পেয়ারড কিনা (দুজনকেই লক করে)
        var paired int
        if err := tx.QueryRow(ctx,
            `SELECT count(*) FROM users WHERE id = ANY($1) AND couple_id IS NOT NULL FOR UPDATE`,
            []uuid.UUID{me, owner}).Scan(&paired); err != nil {
            return err
        }
        if paired > 0 {
            return httpx.ErrCode(409, "already_paired")
        }

        coupleID = uuid.Must(uuid.NewV7())
        if _, err := tx.Exec(ctx, `INSERT INTO couples (id) VALUES ($1)`, coupleID); err != nil {
            return err
        }
        if _, err := tx.Exec(ctx,
            `UPDATE users SET couple_id = $1, updated_at = now() WHERE id = ANY($2)`,
            coupleID, []uuid.UUID{me, owner}); err != nil {
            return err
        }
        if _, err := tx.Exec(ctx, `UPDATE pair_codes SET used_at = now() WHERE code = $1`, code); err != nil {
            return err
        }
        if err := s.createSystemDates(ctx, tx, coupleID, me, owner); err != nil {   // দুজনের জন্মদিন
            return err
        }
        if err := s.createDeedVaults(ctx, tx, coupleID, me, owner); err != nil {
            return err
        }
        _, err = s.river.InsertTx(ctx, tx, jobs.PushArgs{
            UserIDs: []uuid.UUID{me, owner},
            Kind:    "paired",
            Route:   "/",
        }, nil)
        return err
    })
    return coupleID, err
}
```

### ৮.২. দলিল আনলক

```go
// নিয়ম
func ComputeUnlockAt(cycle string, start time.Time, wedding *MonthDay, loc *time.Location) time.Time {
    s := start.In(loc)
    midnight := func(t time.Time) time.Time {
        return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, loc)
    }
    switch cycle {
    case "1m":
        return midnight(addMonthsClamped(s, 1))
    case "6m":
        return midnight(addMonthsClamped(s, 6))
    default: // anniversary
        if wedding == nil {
            return midnight(addMonthsClamped(s, 6))  // বিয়ের তারিখ না থাকলে ৬ মাস
        }
        next := NextOccurrence(wedding.Month, wedding.Day, s, loc)
        if next.Sub(s) < 30*24*time.Hour {           // খুব কাছে হলে পরের বছর
            next = NextOccurrence(wedding.Month, wedding.Day, next.AddDate(0, 0, 1), loc)
        }
        return next
    }
}

// Go-র AddDate ৩১ জানুয়ারি + ১ মাস = ৩ মার্চ বানায়; আমরা মাসের শেষ দিনে আটকাই (২৮/২৯ ফেব্রুয়ারি)
func addMonthsClamped(t time.Time, months int) time.Time {
    first := time.Date(t.Year(), t.Month()+time.Month(months), 1, t.Hour(), t.Minute(), 0, 0, t.Location())
    lastDay := first.AddDate(0, 1, -1).Day()
    return first.AddDate(0, 0, min(t.Day(), lastDay)-1)
}
```

**`DeliverDeed(tx, vault, trigger)`** (দৈনিক জব ও gift-now দুটোই এটা ডাকে):
```
1. SELECT ... FROM deed_vaults WHERE author_id = $1 FOR UPDATE
2. open entries = deed_entries WHERE author_id = $1 AND delivered_deed_id IS NULL AND deleted_at IS NULL
3. যদি 0টি: শুধু নতুন সাইকেল শুরু (cycle_started_at = now, unlock_at = Compute...), শেষ
4. INSERT delivered_deeds (... period_start = vault.cycle_started_at ...)
   ON CONFLICT (author_id, period_start) DO NOTHING   ← রিট্রাইয়েও দুবার হবে না
5. UPDATE deed_entries SET delivered_deed_id = $new WHERE id = ANY(open_ids)
6. প্রতিটি এন্ট্রির জন্য RecordChange(visible_to = NULL) ← এখন প্রাপকও সিঙ্কে পাবেন
7. uploads.private_to = NULL (ঐ এন্ট্রির ছবিগুলো) ← প্রাপক ডাউনলোড URL পাবেন
8. vault রিসেট: cycle_started_at = now, unlock_at = Compute(...), entry_count = 0
9. River: PushArgs(recipient, "deed_delivered", route=/deed/reveal/{id})
         PushArgs(author, "deed_delivered_author")
```

### ৮.৩. ফর্দে মনে করানো (nudge)

```go
func (s *Service) Nudge(ctx context.Context, a auth.Actor, listID uuid.UUID) error {
    return db.WithTx(ctx, s.pool, func(tx pgx.Tx) error {
        // শর্তসহ আপডেট: এক কোয়েরিতেই রেট লিমিট, রেস কন্ডিশন ছাড়া
        tag, err := tx.Exec(ctx, `
            UPDATE bazar_lists SET last_nudge_at = now(), updated_at = now()
            WHERE id = $1 AND couple_id = $2 AND created_by = $3
              AND status IN ('sent','shopping') AND deleted_at IS NULL
              AND (last_nudge_at IS NULL OR last_nudge_at < now() - interval '30 minutes')`,
            listID, a.CoupleID, a.UserID)
        if err != nil {
            return err
        }
        if tag.RowsAffected() == 0 {
            return httpx.ErrCode(429, "nudge_too_soon")   // বা not found; ক্লায়েন্ট বাকি সময় দেখায়
        }
        if _, err := syncpkg.RecordChange(ctx, tx, syncpkg.Change{
            CoupleID: a.CoupleID, Entity: "bazar_list", EntityID: listID, Op: "upsert",
        }); err != nil {
            return err
        }
        _, err = s.river.InsertTx(ctx, tx, jobs.PushArgs{
            UserIDs: []uuid.UUID{a.PartnerID}, Kind: "bazar_nudge",
            Route: fmt.Sprintf("/bazar/%s/shop", listID),
        }, nil)
        return err
    })
}
```

### ৮.৪. অ্যাকাউন্ট ডিলিট
1. `users.deletion_requested_at = now()`, সব ডিভাইস টোকেন মোছা, কাপল থাকলে আনপেয়ার শুরু।
2. Firebase Admin SDK দিয়ে Firebase ইউজার ডিলিট (`auth.DeleteUser`)।
3. `AccountPurgeJob` (৩০ দিন পরে শিডিউল): ইউজারের সব সারি ও `uploads`-এর অবজেক্ট (S3 `DeleteObjects`, ১০০০টি করে) মুছে ফেলা।
4. সঙ্গীর অংশ: শেয়ার্ড কাপল ডেটা আনপেয়ার গ্রেস শেষে মুছবে; সঙ্গীকে আগে এক্সপোর্টের সুযোগ দিয়ে পুশ।

---

## ৯. রিয়েলটাইম (WebSocket)

### ৯.১. প্রোটোকল
```
client → {"type":"auth","token":"<Firebase ID token>"}       (সংযোগের ১০ সেকেন্ডের মধ্যে)
server → {"type":"ready","seq":1234}                         (সর্বশেষ seq; ক্লায়েন্ট পিছিয়ে থাকলে pull)
server → {"type":"changed","seq":1240}
client → {"type":"ping"}   server → {"type":"pong"}           (প্রতি ২৫ সেকেন্ডে)
```

### ৯.২. Hub

```go
// internal/realtime/hub.go
type conn struct {
    userID uuid.UUID
    send   chan []byte          // buffered; ভরে গেলে সংযোগ বন্ধ (ধীর ক্লায়েন্ট)
}

type Hub struct {
    mu      sync.RWMutex
    couples map[uuid.UUID]map[*conn]struct{}
}

func (h *Hub) Publish(coupleID uuid.UUID, seq int64, visibleTo *uuid.UUID) {
    msg := []byte(fmt.Sprintf(`{"type":"changed","seq":%d}`, seq))
    h.mu.RLock()
    defer h.mu.RUnlock()
    for c := range h.couples[coupleID] {
        if visibleTo != nil && c.userID != *visibleTo {
            continue                 // দলিল: শুধু লেখককে সিগন্যাল
        }
        select {
        case c.send <- msg:
        default:                     // বাফার ভর্তি: এই সংযোগ বাদ, ক্লায়েন্ট reconnect করে pull করবে
        }
    }
}
```

### ৯.৩. একাধিক সার্ভার ইন্সট্যান্স
`RecordChange` প্রতিটি পরিবর্তনে `pg_notify('couple_changes', ...)` পাঠায়। প্রতিটি ইন্সট্যান্স **direct** সংযোগে `LISTEN couple_changes` করে এবং নিজের Hub-এ `Publish` করে। ফলে কোন ইন্সট্যান্সে লেখা হলো আর কোনটায় সঙ্গী সংযুক্ত, তাতে কিছু যায় আসে না। MVP-তে একটি ইন্সট্যান্স হলেও একই কোড চলবে।

```go
// internal/realtime/pgnotify.go
func Listen(ctx context.Context, directURL string, hub *Hub) error {
    for {
        if err := listenOnce(ctx, directURL, hub); err != nil && ctx.Err() == nil {
            slog.Warn("pg listen dropped, retrying", "err", err)
            time.Sleep(2 * time.Second)
            continue
        }
        return ctx.Err()
    }
}

func listenOnce(ctx context.Context, url string, hub *Hub) error {
    c, err := pgx.Connect(ctx, url)
    if err != nil {
        return err
    }
    defer c.Close(context.Background())
    if _, err := c.Exec(ctx, "LISTEN couple_changes"); err != nil {
        return err
    }
    for {
        n, err := c.WaitForNotification(ctx)
        if err != nil {
            return err
        }
        coupleID, seq, visibleTo, ok := parsePayload(n.Payload)
        if ok {
            hub.Publish(coupleID, seq, visibleTo)
        }
    }
}
```

---

## ১০. ফাইল স্টোরেজ (Neon Object Storage)

### ১০.১. ক্লায়েন্ট সেটআপ

```go
// internal/storage/s3.go
func New(ctx context.Context, c config.Config) (*Store, error) {
    cfg, err := awsconfig.LoadDefaultConfig(ctx,
        awsconfig.WithRegion(c.S3Region),
        awsconfig.WithCredentialsProvider(
            credentials.NewStaticCredentialsProvider(c.S3AccessKey, c.S3SecretKey, "")),
    )
    if err != nil {
        return nil, err
    }
    client := s3.NewFromConfig(cfg, func(o *s3.Options) {
        o.BaseEndpoint = aws.String(c.S3Endpoint)
        o.UsePathStyle = true   // Neon শুধু path-style সমর্থন করে
        // নতুন SDK ডিফল্টে CRC32 checksum যোগ করে, যা S3-compatible সার্ভিস ও
        // presigned PUT-এ সমস্যা করতে পারে। শুধু দরকার হলে checksum।
        o.RequestChecksumCalculation = aws.RequestChecksumCalculationWhenRequired
        o.ResponseChecksumValidation = aws.ResponseChecksumValidationWhenRequired
    })
    return &Store{client: client, presign: s3.NewPresignClient(client), bucket: c.S3Bucket}, nil
}

func (s *Store) PresignPut(ctx context.Context, key, contentType string, size int64) (*v4.PresignedHTTPRequest, error) {
    return s.presign.PresignPutObject(ctx, &s3.PutObjectInput{
        Bucket:        &s.bucket,
        Key:           &key,
        ContentType:   aws.String(contentType),
        ContentLength: aws.Int64(size),     // সাইন হয়ে যায়: ক্লায়েন্ট বড় ফাইল পাঠাতে পারবে না
    }, s3.WithPresignExpires(10*time.Minute))
}

func (s *Store) PresignGet(ctx context.Context, key string) (string, error) {
    req, err := s.presign.PresignGetObject(ctx, &s3.GetObjectInput{Bucket: &s.bucket, Key: &key},
        s3.WithPresignExpires(15*time.Minute))
    if err != nil {
        return "", err
    }
    return req.URL, nil
}
```

### ১০.২. নিয়ম
- বাকেট **প্রাইভেট** (`private` access mode)। কোনো পাবলিক URL নেই।
- কী-এর ফরম্যাট: `couples/{coupleId}/{purpose}/{uuidv7}.{ext}`, অ্যাভাটার `users/{userId}/avatar/{uuidv7}.jpg`।
- অনুমোদিত টাইপ ও সর্বোচ্চ সাইজ:

| purpose | টাইপ | সর্বোচ্চ |
|---|---|---|
| avatar, bazar_item, case_evidence, deed, chore, wardrobe | image/jpeg, image/png, image/webp | ৩MB |
| voice (P2) | audio/m4a, audio/aac | ১MB (৩০ সেকেন্ড) |
| export | application/zip | সার্ভার নিজে লেখে |

- `GET /v1/files/url` অনুমতি: `uploads.couple_id = me.couple_id` এবং (`private_to IS NULL` অথবা `private_to = me`)।
- ২৪ ঘণ্টায় confirm না হওয়া আপলোড ক্লিনআপ জব মুছে দেয়।
- **CORS** লাগবে না (মোবাইল অ্যাপ ব্রাউজার নয়); ভবিষ্যতে ওয়েব ক্লায়েন্ট হলে বাকেটে CORS রুল যোগ করবেন।
- Neon-এ ব্রাঞ্চ অনুযায়ী আলাদা স্টোরেজ থাকে, তাই dev/staging-এর ছবি prod-এ যায় না।

---

## ১১. ব্যাকগ্রাউন্ড জব (River)

### ১১.১. জব তালিকা

| জব | ট্রিগার | কাজ |
|---|---|---|
| `PushJob` | অন্য ট্রানজ্যাকশন থেকে `InsertTx` | FCM পাঠানো; শান্ত সময় মানা; অচল টোকেন মোছা; ৫ বার রিট্রাই |
| `BazarDueCheck` | প্রতি ৫ মিনিটে | ডেডলাইনের ≤৩০ মিনিট বাকি, এখনো `sent` → প্রাপককে পুশ, `due_reminded_at` সেট |
| `BazarCatalogUpdate` | ফর্দ `done` হলে | কেনা জিনিসগুলো `bazar_catalog`-এ upsert (buy_count, last_price) |
| `DeedUnlockDaily` | প্রতিদিন ০০:০৫ (ঢাকা) | `unlock_at <= now()` এমন সব ভল্টে `DeliverDeed` |
| `PromiseReminder` | প্রতি ১৫ মিনিটে | due হওয়া প্রতিশ্রুতিতে পুশ (লোকাল নোটিফিকেশনের ব্যাকআপ) |
| `MonthlyWrapped` | প্রতি মাসের ১ তারিখ ০৮:০০ (ঢাকা) | আগের মাসের পরিসংখ্যান → `wrapped_reports` → পুশ |
| `ExportJob` | ইউজারের অনুরোধে | JSON + ছবি ZIP → স্টোরেজ → পুশ (৭ দিনের লিংক) |
| `AccountPurgeJob` | ডিলিটের ৩০ দিন পর | সব ডেটা ও ফাইল মোছা |
| `Cleanup` | প্রতিদিন ০৩:০০ (ঢাকা) | মেয়াদোত্তীর্ণ পেয়ার কোড, অসম্পূর্ণ আপলোড, ৩০ দিনের পুরনো `processed_ops`, ৯০ দিনের পুরনো `change_log`, soft-deleted সারি (৩০ দিন), আনপেয়ার গ্রেস শেষ হওয়া কাপল |

### ১১.২. River সেটআপ

```go
// cmd/server/main.go (অংশ)
dhaka, _ := time.LoadLocation("Asia/Dhaka")   // Docker ইমেজে tzdata লাগবে (নিচে)
every := func(spec string) cron.Schedule {
    s, err := cron.ParseStandard("CRON_TZ=Asia/Dhaka " + spec)
    if err != nil {
        panic(err)
    }
    return s
}

workers := river.NewWorkers()
river.AddWorker(workers, &jobs.PushWorker{FCM: fcm, DB: pool})
river.AddWorker(workers, &jobs.DeedUnlockWorker{DB: pool, Deeds: deedSvc})
river.AddWorker(workers, &jobs.BazarDueWorker{DB: pool})
// ... বাকিগুলো

riverClient, err := river.NewClient(riverpgxv5.New(directPool), &river.Config{
    Queues: map[string]river.QueueConfig{
        river.QueueDefault: {MaxWorkers: 20},
        "push":             {MaxWorkers: 50},
    },
    Workers: workers,
    PeriodicJobs: []*river.PeriodicJob{
        river.NewPeriodicJob(river.PeriodicInterval(5*time.Minute),
            func() (river.JobArgs, *river.InsertOpts) { return jobs.BazarDueArgs{}, nil }, nil),
        river.NewPeriodicJob(river.PeriodicInterval(15*time.Minute),
            func() (river.JobArgs, *river.InsertOpts) { return jobs.PromiseReminderArgs{}, nil }, nil),
        river.NewPeriodicJob(every("5 0 * * *"),
            func() (river.JobArgs, *river.InsertOpts) { return jobs.DeedUnlockArgs{}, nil },
            &river.PeriodicJobOpts{RunOnStart: true}),     // সার্ভার ডাউন থাকলেও রিস্টার্টে মিস হবে না
        river.NewPeriodicJob(every("0 8 1 * *"),
            func() (river.JobArgs, *river.InsertOpts) { return jobs.MonthlyWrappedArgs{}, nil }, nil),
        river.NewPeriodicJob(every("0 3 * * *"),
            func() (river.JobArgs, *river.InsertOpts) { return jobs.CleanupArgs{}, nil }, nil),
    },
})
```
> একাধিক ইন্সট্যান্সেও River leader election করে, তাই periodic জব একবারই চলে। সব জব **idempotent** লিখুন (DeliverDeed-এর UNIQUE, nudge-এর শর্তসহ UPDATE ইত্যাদি), কারণ রিট্রাই হতে পারে।

### ১১.৩. PushJob

```go
// internal/jobs/push_job.go
type PushArgs struct {
    UserIDs []uuid.UUID       `json:"user_ids"`
    Kind    string            `json:"kind"`     // CONTENT_BN.md §৩-এর কী
    Vars    map[string]string `json:"vars"`     // {"nickname":"ম্যাডাম","count":"১২"}
    Route   string            `json:"route"`
}

func (PushArgs) Kind() string { return "push" }

func (PushArgs) InsertOpts() river.InsertOpts {
    return river.InsertOpts{Queue: "push", MaxAttempts: 5}
}

type PushWorker struct {
    river.WorkerDefaults[PushArgs]
    FCM *push.FCM
    DB  *pgxpool.Pool
}

func (w *PushWorker) Work(ctx context.Context, job *river.Job[PushArgs]) error {
    targets, err := loadPushTargets(ctx, w.DB, job.Args.UserIDs, job.Args.Kind)
    // targets: প্রতিটি ডিভাইসের token, locale, এবং ইউজারের সেটিংসে এই kind চালু কিনা, শান্ত সময় কিনা
    if err != nil {
        return err
    }
    for _, t := range targets {
        title, body := copydeck.Render(job.Args.Kind, t.Locale, job.Args.Vars)
        msg := &messaging.MulticastMessage{
            Tokens:       t.Tokens,
            Notification: &messaging.Notification{Title: title, Body: body},
            Data:         map[string]string{"route": job.Args.Route, "sync": "1", "kind": job.Args.Kind},
            Android: &messaging.AndroidConfig{
                Priority:     "high",
                Notification: &messaging.AndroidNotification{ChannelID: channelFor(job.Args.Kind)},
            },
            APNS: &messaging.APNSConfig{Payload: &messaging.APNSPayload{Aps: &messaging.Aps{
                Sound: soundFor(t.Quiet), // শান্ত সময়ে sound নেই
            }}},
        }
        br, err := w.FCM.Client.SendEachForMulticast(ctx, msg)
        if err != nil {
            return err                    // River রিট্রাই করবে
        }
        for i, r := range br.Responses {
            if r.Error != nil && messaging.IsUnregistered(r.Error) {
                _, _ = w.DB.Exec(ctx, `DELETE FROM devices WHERE token = $1`, t.Tokens[i])
            }
        }
    }
    return nil
}
```
নোটিফিকেশনের টেক্সট সার্ভারে `internal/copydeck/` প্যাকেজে (`CONTENT_BN.md` §৩ থেকে), ইউজারের `locale` অনুযায়ী বাংলা বা ইংরেজি। সংখ্যা বাংলায় রূপান্তরও এখানে।

### ১১.৪. Firebase Admin সেটআপ

```go
// internal/auth/firebase.go
func NewFirebase(ctx context.Context, c config.Config) (*auth.Client, *messaging.Client, error) {
    var opts []option.ClientOption
    if c.FirebaseCreds != "" {
        // google.golang.org/api-এর নতুন ভার্সনে WithCredentialsJSON deprecated;
        // WithAuthCredentialsJSON টাইপসহ ক্রেডেনশিয়াল নেয়
        opts = append(opts, option.WithAuthCredentialsJSON(option.ServiceAccount, []byte(c.FirebaseCreds)))
    }
    app, err := firebase.NewApp(ctx, &firebase.Config{ProjectID: c.FirebaseProject}, opts...)
    if err != nil {
        return nil, nil, err
    }
    a, err := app.Auth(ctx)
    if err != nil {
        return nil, nil, err
    }
    m, err := app.Messaging(ctx)
    return a, m, err
}
```

```go
// internal/auth/middleware.go
func (m *Middleware) Require(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        raw, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
        if !ok {
            httpx.WriteErr(w, httpx.ErrCode(401, "unauthenticated"))
            return
        }
        tok, err := m.fb.VerifyIDToken(r.Context(), raw)   // Google-এর public key ক্যাশ করে, দ্রুত
        if err != nil {
            httpx.WriteErr(w, httpx.ErrCode(401, "invalid_token"))
            return
        }
        actor, err := m.users.ActorByFirebaseUID(r.Context(), tok.UID)  // ছোট in-memory ক্যাশ (৩০s)
        if err != nil && !errors.Is(err, ErrUserNotFound) {
            httpx.WriteErr(w, err)
            return
        }
        ctx := WithActor(r.Context(), actor, tok.UID)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
```
সংবেদনশীল অপারেশনে (অ্যাকাউন্ট ডিলিট, এক্সপোর্ট) `VerifyIDTokenAndCheckRevoked` ব্যবহার করুন।

---

## ১২. লোকাল ডেভেলপমেন্ট

### ১২.১. যা লাগবে
- Go 1.27, Docker (শুধু টেস্টের Postgres-এর জন্য), Firebase CLI (Auth emulator), Neon CLI।
- **ডেভ ডেটাবেস:** Neon-এ `dev` ব্রাঞ্চ (ফ্রি প্ল্যানে চলবে)। নেট ছাড়া কাজ করতে চাইলে Docker Postgres (`make db-local`)।

### ১২.২. Makefile

```makefile
include .env
export

dev:            ## সার্ভার চালু (ফাইল বদলালে রিস্টার্ট চাইলে `air` ব্যবহার করুন)
	go run ./cmd/server

migrate-up:
	go tool goose -dir internal/db/migrations postgres "$(DATABASE_DIRECT_URL)" up
	go run github.com/riverqueue/river/cmd/river@latest migrate-up --database-url "$(DATABASE_DIRECT_URL)"

migrate-new:    ## make migrate-new name=add_templates
	go tool goose -dir internal/db/migrations create $(name) sql

sqlc:
	go tool sqlc generate

test:
	go test -race -count=1 ./...

lint:
	go vet ./... && go run honnef.co/go/tools/cmd/staticcheck@latest ./...

auth-emulator:
	firebase emulators:start --only auth

db-local:
	docker run --rm -d --name bou-pg -e POSTGRES_PASSWORD=dev -e POSTGRES_DB=bou -p 5432:5432 postgres:17
```

### ১২.৩. Flutter থেকে লোকাল সার্ভার
- Android emulator: `http://10.0.2.2:8080`; আসল ফোন: কম্পিউটারের LAN IP, অথবা `adb reverse tcp:8080 tcp:8080`।
- Auth emulator ব্যবহার করলে Flutter-এ `FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099)` এবং সার্ভারে `FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099` (Admin SDK তখন emulator-এর টোকেন গ্রহণ করে)।
- FCM-এর emulator নেই: ডেভে আসল Firebase dev প্রজেক্টের FCM ব্যবহার করুন।

### ১২.৪. `api.http` (VS Code REST Client)

```http
@base = http://localhost:8080
@token = {{$dotenv DEV_ID_TOKEN}}

### Health
GET {{base}}/healthz

### Me
GET {{base}}/v1/me
Authorization: Bearer {{token}}
X-App-Version: 1.0.0

### Create pair code
POST {{base}}/v1/pair/codes
Authorization: Bearer {{token}}
X-App-Version: 1.0.0
```

---

## ১৩. ডিপ্লয়মেন্ট

### ১৩.১. Dockerfile

```dockerfile
FROM golang:1.27-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/server /server
# Asia/Dhaka টাইমজোনের জন্য: distroless/static-এ tzdata আছে; না থাকলে main.go-তে `import _ "time/tzdata"`
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/server"]
```
নিশ্চিত থাকতে `cmd/server/main.go`-তে `import _ "time/tzdata"` রাখুন (বাইনারিতে ~৪৫০KB যোগ হয়, কিন্তু কোনো ইমেজে টাইমজোন হারাবে না)।

### ১৩.২. `fly.toml`

```toml
app = "bou-reminder-api"
primary_region = "sin"

[build]

[env]
  ENV = "prod"
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "off"     # WebSocket ও River জবের জন্য সবসময় চালু
  auto_start_machines = true
  min_machines_running = 1

  [http_service.concurrency]
    type = "connections"
    soft_limit = 800
    hard_limit = 1000

  [[http_service.checks]]
    method = "GET"
    path = "/healthz"
    interval = "15s"
    timeout = "3s"
    grace_period = "10s"

[[vm]]
  size = "shared-cpu-1x"
  memory = "512mb"

[deploy]
  release_command = "/server migrate"    # main.go-তে `migrate` সাবকমান্ড: goose + river মাইগ্রেশন
  strategy = "rolling"
```

```bash
fly launch --no-deploy --region sin
fly secrets set DATABASE_URL=... DATABASE_DIRECT_URL=... AWS_ENDPOINT_URL_S3=... \
  AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... S3_BUCKET=bou-private \
  FIREBASE_PROJECT_ID=... FIREBASE_CREDENTIALS_JSON="$(cat sa.json)" SENTRY_DSN=...
fly deploy
fly certs add api.<your-domain>
```
Fly.io ছাড়াও এই Docker ইমেজ যেকোনো জায়গায় চলবে (Railway, Render, DigitalOcean/Vultr সিঙ্গাপুর VPS)। শর্ত একটাই: **সার্ভার সবসময় চালু থাকতে হবে** (WebSocket ও জবের কারণে), তাই "scale to zero" প্ল্যাটফর্ম এড়িয়ে চলুন।

### ১৩.৩. Neon সেটিংস
- প্রজেক্ট রিজিয়ন: **AWS Asia Pacific (Singapore)**।
- ব্রাঞ্চ: `main` (prod), `staging`, `dev`।
- রোল: `app` (অ্যাপের জন্য, শুধু DML), `migrator` (DDL)। prod-এ অ্যাপ কখনো owner রোলে চলবে না।
- **Compute autosuspend:** সার্ভার সারাক্ষণ direct সংযোগ (LISTEN, River) রাখে বলে prod compute ঘুমাবে না। এটা স্বাভাবিক; খরচ হিসাবে ছোট compute (0.25–0.5 CU) সবসময় চালু ধরে রাখুন। dev ব্রাঞ্চে সার্ভার বন্ধ থাকলে ঘুমিয়ে যাবে, খরচ বাঁচবে।
- **Pooled সংযোগ ও prepared statement:** pgx ডিফল্টে prepared statement ক্যাশ করে। Neon-এর pooler এটা সমর্থন করে; তবু `prepared statement already exists` ধরনের এরর দেখলে pooled URL-এ `default_query_exec_mode=cache_describe` যোগ করুন।
- পয়েন্ট-ইন-টাইম রিস্টোর (PITR) উইন্ডো প্ল্যান অনুযায়ী; prod-এ কমপক্ষে ৭ দিন রাখুন।

### ১৩.৪. CI/CD (GitHub Actions, সংক্ষেপে)
```
api.yml:  push → go vet, staticcheck, go test (service: postgres:17) → main-এ merge হলে fly deploy
app.yml:  push → flutter analyze, flutter test → tag দিলে appbundle/ipa বিল্ড
```
বিস্তারিত `RELEASE_CHECKLIST.md`-এ।

---

## ১৪. নিরাপত্তা ও নির্ভরযোগ্যতা

| বিষয় | ব্যবস্থা |
|---|---|
| Auth | প্রতিটি অনুরোধে Firebase ID token যাচাই |
| Authorization | প্রতিটি কোয়েরিতে `couple_id = actor.couple_id`; দলিল এন্ট্রিতে §৫.৪-এর নিয়ম; কোনো এন্ডপয়েন্টে ক্লায়েন্টের পাঠানো couple_id বিশ্বাস করা হয় না |
| রেট লিমিট | ইউজারপ্রতি token bucket (`x/time/rate`): সাধারণ ২০ req/s, burst ৪০; presign ১০/মিনিট; pair join ৫/মিনিট (কোড অনুমান ঠেকাতে) |
| ইনপুট | JSON বডি সর্বোচ্চ ১MB (`http.MaxBytesReader`), unknown field প্রত্যাখ্যান, টেক্সট দৈর্ঘ্য DB CHECK ও কোড দুটোতেই |
| SQL | শুধু প্যারামিটারাইজড কোয়েরি (sqlc/pgx) |
| সিক্রেট | Fly secrets; লগে কখনো টোকেন বা কী নয় |
| টাইমআউট | `http.Server{ReadHeaderTimeout: 5s, ReadTimeout: 15s, WriteTimeout: 30s, IdleTimeout: 120s}`; প্রতিটি DB কলে context timeout |
| Graceful shutdown | SIGTERM → নতুন সংযোগ বন্ধ, WS ক্লায়েন্টকে close, River `StopAndCancel` ৩০ সেকেন্ডে |
| লগ | `log/slog` JSON; প্রতিটি অনুরোধে request_id, user_id, latency, status |
| এরর | Sentry (panic + 5xx), রিলিজ ভার্সন ট্যাগসহ |
| মেট্রিক্স | Fly-এর বিল্ট-ইন Prometheus মেট্রিক্স; River-এর জব সংখ্যা ও ব্যর্থতা |
| ব্যাকআপ | Neon PITR; মাসে একবার রিস্টোর মহড়া (নতুন ব্রাঞ্চে রিস্টোর করে যাচাই) |

---

## ১৫. টেস্ট

| স্তর | কী | কীভাবে |
|---|---|---|
| ইউনিট | `ComputeUnlockAt`, `NextOccurrence` (লিপ ইয়ার, বছর শেষ), quantity parser, copydeck রেন্ডার | `go test`, টেবিল-ড্রিভেন |
| DB ইন্টিগ্রেশন | প্রতিটি sqlc কোয়েরি, মাইগ্রেশন up/down | CI-তে Postgres 17 কন্টেইনার; প্রতিটি টেস্ট নিজের ট্রানজ্যাকশনে, শেষে rollback |
| সিঙ্ক | push idempotency (একই op দুবার), pull cursor, seq-এর ক্রম (সমান্তরাল লেখায় কোনো seq বাদ পড়ে না) | goroutine দিয়ে ১০০টি সমান্তরাল লেখা, তারপর pull যাচাই |
| **দলিলের গোপনীয়তা** | প্রাপক কোনো পথে আনলকের আগে এন্ট্রি, change বা ছবির URL পায় না | pull, `/deeds/delivered/{id}/entries`, `/files/url`, WS — চারটি পথেই টেস্ট |
| অনুমতি | কাপল A-র টোকেন দিয়ে কাপল B-র যেকোনো আইডি → 403/404 | প্রতিটি এনটিটি হ্যান্ডলারে |
| জব | DeliverDeed দুবার চালালে একটাই দলিল; nudge রেট লিমিট | River-এর `rivertest` প্যাকেজ |
| E2E | দুটি টেস্ট ইউজার: পেয়ার → ফর্দ পাঠানো → টিক → শেষ | `api.http` + স্ক্রিপ্ট, staging-এ |

**সবচেয়ে গুরুত্বপূর্ণ টেস্ট (উদাহরণ):**
```go
func TestRecipientCannotReadUndeliveredDeed(t *testing.T) {
    env := testenv.New(t)                          // নতুন কাপল: husband, wife
    env.As(env.Husband).WriteDeedEntry("আজ ও আমার জন্য চা বানিয়েছিল, খুব ভালো লেগেছে")

    changes := env.As(env.Wife).Pull(0)
    require.Empty(t, changes.OfEntity("deed_entry"))

    res := env.As(env.Wife).Get("/v1/deeds/delivered/" + env.AnyDeedID() + "/entries")
    require.Equal(t, http.StatusNotFound, res.StatusCode)
}
```

---

## ১৬. খরচের আনুমানিক হিসাব (MVP, ~১,০০০ সক্রিয় কাপল)

| সার্ভিস | আনুমানিক |
|---|---|
| Fly.io (১টি shared-cpu-1x, 512MB) | মাসে কয়েক ডলার |
| Neon (ছোট compute সবসময় চালু + কয়েক GB স্টোরেজ) | Launch প্ল্যানের ভেতরে |
| Neon Object Storage (ছবি ~৫–১০GB) | ফ্রি ৫GB, তারপর প্রতি GB মিটারড |
| Firebase Auth | Google ও Email/Password ফ্রি |
| FCM | ফ্রি |
| Sentry | ফ্রি টিয়ার যথেষ্ট |

দাম বদলায়, তাই চূড়ান্ত বাজেটের আগে প্রতিটি সার্ভিসের বর্তমান প্রাইসিং পেজ দেখে নিন।
