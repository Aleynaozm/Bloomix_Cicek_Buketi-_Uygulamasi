# Bloomix — Supabase Auth Kurulumu

Bu dosya, Supabase tabanlı auth sistemini çalıştırmak için yapman gereken adımları sırayla anlatıyor. Kod tarafı hazır; bu sadece konfigürasyon.

---

## 1. Supabase Projesi & Anahtarlar

1. [supabase.com](https://supabase.com) → yeni proje oluştur (zaten varsa atla).
2. Project Settings → **API**
   - **Project URL** → `https://xxxxx.supabase.co`
   - **anon public key** → `eyJ...`

Bu iki değeri uygulamaya geçirmenin **iki yolu** var:

### A) `--dart-define` (önerilen, anahtarlar repo'ya girmez)

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
```

VS Code kullanıyorsan `.vscode/launch.json`'da `toolArgs` ekle:

```json
{
  "configurations": [
    {
      "name": "bloomix",
      "request": "launch",
      "type": "dart",
      "toolArgs": [
        "--dart-define=SUPABASE_URL=https://xxxxx.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=eyJhbGci..."
      ]
    }
  ]
}
```

### B) `lib/services/supabase_service.dart` içinde değiştir (hızlı test için)

`_url` ve `_anonKey` sabitlerinin `defaultValue`'larını gerçek değerlerle değiştir.
**Production'a göndermeden önce A yöntemine geç.**

---

## 2. `profiles` Tablosu (SQL)

Supabase Dashboard → **SQL Editor**'da çalıştır:

```sql
-- Profiles tablosu
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS aç
alter table public.profiles enable row level security;

-- Kullanıcı kendi profilini okuyabilir
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

-- Kullanıcı kendi profilini ekleyebilir
create policy "profiles_insert_own"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Kullanıcı kendi profilini güncelleyebilir
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id);

-- (Opsiyonel) Yeni signup'ta otomatik profile oluşturma trigger'ı
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', ''))
  on conflict (id) do nothing;
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
```

> Trigger'ı kurarsan kod tarafındaki manuel `_upsertProfile` çağrıları yine de zarar vermez (`upsert` idempotent).

---

## 3. Email/Password Auth

Hiçbir ayar gerekmez — Supabase'de **default açık**.

### E-posta doğrulama

Default'ta yeni kayıtlarda doğrulama maili gönderilir.

- **Geliştirme sırasında kapatmak istersen:** Authentication → Providers → **Email** → "Confirm email" kapat.
- Açık bırakırsan, kullanıcı kayıt sonrası bir doğrulama maili alır; tıklayınca giriş yapabilir.

Kayıt ekranı her iki durumu da handle ediyor (session varsa doğrudan main'e geçer, yoksa "e-postanı kontrol et" mesajı gösterir).

---

## 4. Google Sign-In

### Supabase tarafı

Authentication → Providers → **Google** → enable.

İki şey lazım:
- **Client ID** (Web) → Google Cloud Console'dan alınacak
- **Client Secret** (Web) → aynı yerden

### Google Cloud Console

1. [console.cloud.google.com](https://console.cloud.google.com) → proje oluştur
2. APIs & Services → **OAuth consent screen** → External, doldur
3. Credentials → **Create Credentials → OAuth client ID**

   3 farklı client ID oluştur:
   - **Web** (Supabase'e gir)
     - Authorized redirect URI: `https://xxxxx.supabase.co/auth/v1/callback`
   - **iOS** (uygulama için)
     - Bundle ID: `com.bloomix.app` (kendi bundle id'in)
     - Reversed client ID'yi al: `com.googleusercontent.apps.123-abc`
   - **Android** (uygulama için)
     - Package name + SHA-1 (debug/release ayrı)

### Flutter tarafı

Şu üç değeri `--dart-define` ile geçir:

```bash
--dart-define=GOOGLE_IOS_CLIENT_ID=123-abc.apps.googleusercontent.com
--dart-define=GOOGLE_WEB_CLIENT_ID=456-def.apps.googleusercontent.com
```

> `serverClientId` olarak Web Client ID kullanılır (Android & iOS için id token doğrulamasında).

### iOS — `Info.plist`

`ios/Runner/Info.plist`'e ekle (Reversed Client ID'yi URL scheme olarak):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.123-abc</string>
    </array>
  </dict>
</array>
```

### Android — `google-services.json`

1. Firebase'e gerek yok; sadece OAuth client kurulumu yeter.
2. SHA-1 fingerprint Google Cloud Console'a tanımlı olmalı:
   ```bash
   cd android && ./gradlew signingReport
   ```

---

## 5. Test Akışı

```bash
flutter clean
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=GOOGLE_IOS_CLIENT_ID=... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=...
```

**Beklenen:**
1. Splash → Onboarding → Login ekranı
2. Kayıt Ol → e-posta + şifre → (doğrulama maili kapalıysa) doğrudan ana ekrana
3. Çıkış yap → Login ekranına geri dön
4. Tekrar açtığında oturum hala varsa doğrudan ana ekran (AuthGate session'ı algılar)

---

## 6. Kod Yapısı (özet)

| Dosya | Görev |
|---|---|
| `lib/services/supabase_service.dart` | Supabase init + auth helper'ları (signIn, signUp, Google, signOut, profiles) |
| `lib/screens/auth/auth_gate.dart` | Session var/yok kontrolü → Login veya MainShell |
| `lib/screens/auth/login_screen.dart` | E-posta/şifre + Google + "Kayıt Ol" linki |
| `lib/screens/auth/signup_screen.dart` | E-posta/şifre kayıt + profile insert + "Giriş Yap" linki |
| `lib/providers/app_provider.dart` | `AppUser`'ı Supabase session'dan türetir, auth stream'i dinler |
| `lib/main.dart` | `SupabaseService.init()` → splash → onboarding → AuthGate |

---

## 7. Bilinen Eksikler / TODO

- [ ] E-posta doğrulama deep link handler (uygulamayı kapatıp linke tıklayınca uygulama açılsın).
- [ ] Şifre sıfırlama flow'unda kullanıcı yeni şifre girerken yönlenecek bir ekran (şu an sadece reset maili gönderiliyor).
- [ ] Profil avatar yükleme (Supabase Storage).
