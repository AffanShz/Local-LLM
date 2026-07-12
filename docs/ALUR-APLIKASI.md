# 📖 Alur Aplikasi Orange AI (LocalLLM Client)

Dokumen ini menjelaskan **alur kerja aplikasi dari awal sampai akhir**: dari mana kode dimulai, ke mana data mengalir, dan file mana yang bertanggung jawab atas setiap bagian. Semua path relatif terhadap folder `local_llm_chat/`.

---

## 1. Gambaran Besar (Arsitektur)

Aplikasi ini adalah **chat client Flutter (desktop Windows)** yang bisa bicara dengan tiga "otak" AI:

1. **Ollama** — LLM lokal yang jalan di komputer sendiri (`http://127.0.0.1:11434`), tanpa internet.
2. **Google Gemini** — LLM cloud, hanya muncul kalau ada koneksi internet.
3. **Anthropic Claude** — LLM cloud (endpoint diatur lewat `ANTHROPIC_BASE_URL` di `.env`), juga hanya muncul saat online.

Arsitekturnya dibagi 3 lapisan (pola *layered architecture*):

```
┌─────────────────────────────────────────────────────────┐
│  PRESENTATION (UI)          lib/presentation/           │
│  Screens & Widgets — apa yang dilihat & disentuh user   │
└──────────────────────┬──────────────────────────────────┘
                       │ watch / read (Riverpod)
┌──────────────────────▼──────────────────────────────────┐
│  STATE MANAGEMENT           lib/providers/              │
│  Otak aplikasi — menyimpan state & logika alur          │
└──────────┬──────────────────────────────┬───────────────┘
           │                              │
┌──────────▼───────────┐      ┌───────────▼───────────────┐
│  DATA / REPOSITORY   │      │  DATABASE LOKAL           │
│  lib/data/           │      │  lib/data/local_db/       │
│  repositories/       │      │  database_helper.dart     │
│  (Ollama, Gemini,    │      │  (SQLite)                 │
│   & Claude)          │      │                           │
└──────────────────────┘      └───────────────────────────┘
```

**Aturan arah panah:** UI **tidak pernah** memanggil HTTP/database langsung. UI hanya bicara ke **provider**, provider yang bicara ke **repository** (untuk AI) dan **DatabaseHelper** (untuk penyimpanan). Ini prinsip PBO: *encapsulation* dan *separation of concerns*.

---

## 2. Peta File Lengkap

| Lapisan | File | Tanggung Jawab |
|---|---|---|
| Entry point | `lib/main.dart` | Titik mulai aplikasi, load `.env`, setup tema |
| Screen | `lib/presentation/screens/splash_screen.dart` | Layar pembuka animasi |
| Screen | `lib/presentation/screens/home_chat_screen.dart` | Layar utama (sidebar + chat) |
| Widget | `lib/presentation/widgets/sidebar_conversations.dart` | Daftar riwayat chat, rename, edit prompt, delete |
| Widget | `lib/presentation/widgets/chat_input.dart` | Kotak ketik pesan + tombol kirim/stop |
| Widget | `lib/presentation/widgets/chat_bubble.dart` | Gelembung tampilan pesan |
| Widget | `lib/presentation/widgets/model_selector.dart` | Dropdown pilih model + badge online/offline |
| Widget | `lib/presentation/widgets/orb_widget.dart` | Logo bola animasi (splash & empty state) |
| Provider | `lib/providers/chat_provider.dart` | **Inti alur chat**: kirim pesan, streaming, stop |
| Provider | `lib/providers/conversation_provider.dart` | CRUD daftar percakapan + percakapan aktif |
| Provider | `lib/providers/models_provider.dart` | Daftar model + pilih repository Ollama/Gemini |
| Provider | `lib/providers/connectivity_provider.dart` | Deteksi online/offline real-time |
| Provider | `lib/providers/theme_provider.dart` | Mode gelap/terang |
| Provider | `lib/providers/providers.dart` | Barrel file (kumpulan export saja) |
| Repository | `lib/data/repositories/ollama_repository.dart` | **Kontrak abstrak** (interface) untuk semua LLM |
| Repository | `lib/data/repositories/ollama_repository_impl.dart` | Implementasi HTTP ke Ollama lokal |
| Repository | `lib/data/repositories/gemini_repository_impl.dart` | Implementasi SDK Google Gemini |
| Repository | `lib/data/repositories/claude_repository_impl.dart` | Implementasi HTTP/SSE ke API Anthropic Claude |
| Database | `lib/data/local_db/database_helper.dart` | Singleton SQLite (tabel & query) |
| Model | `lib/data/models/message.dart` | Objek 1 pesan (role, content, status) |
| Model | `lib/data/models/conversation.dart` | Objek 1 sesi chat (title, system prompt) |
| Error | `lib/core/errors/exceptions.dart` | Exception khusus (offline, cancel, dll.) |

---

## 3. Alur #1 — Aplikasi Dinyalakan (Startup)

```
main()  →  load .env  →  ProviderScope  →  OrangeAIApp  →  SplashScreen  →  (3 detik)  →  HomeChatScreen
```

**Langkah demi langkah:**

1. **`lib/main.dart:7`** — fungsi `main()` dieksekusi. Ini pintu masuk seluruh aplikasi.
   - `WidgetsFlutterBinding.ensureInitialized()` menyiapkan engine Flutter.
   - `dotenv.load(fileName: '.env')` (baris 9) membaca file `.env` yang berisi `GEMINI_API_KEY`. Kunci ini nanti dipakai di `gemini_repository_impl.dart:19`.
   - `runApp(ProviderScope(...))` (baris 10–12) — `ProviderScope` adalah "wadah" Riverpod; semua provider hidup di dalamnya.

2. **`lib/main.dart:15-61`** — widget `OrangeAIApp` membangun `MaterialApp`:
   - `ref.watch(themeProvider)` (baris 20) memantau mode tema. Kalau user ganti tema, seluruh app otomatis rebuild.
   - Tema terang & gelap didefinisikan di baris 25–56 (warna oranye `0xFFFF8A3D`).
   - `home: SplashScreen()` (baris 58) — layar pertama yang tampil.

3. **`lib/presentation/screens/splash_screen.dart:18-49`** — splash screen:
   - Animasi fade + scale logo orb selama 1 detik (baris 20–33).
   - `Future.delayed(Duration(seconds: 3))` (baris 36) — setelah 3 detik, `Navigator.pushReplacement` pindah ke `HomeChatScreen` dengan transisi fade (baris 38–46). *pushReplacement* artinya splash dibuang dari stack, user tidak bisa "back" ke splash.

4. Begitu `HomeChatScreen` tampil, provider-provider mulai bekerja **otomatis** karena di-`watch`:
   - `modelsProvider` → mengambil daftar model (lihat Alur #2).
   - `conversationsProvider` → membaca riwayat chat dari SQLite (lihat Alur #3).
   - `connectivityProvider` → mulai memantau internet.

---

## 4. Alur #2 — Mengambil Daftar Model AI

Saat header layar utama tampil, widget `ModelSelector` butuh daftar model.

```
ModelSelector (UI)
   │ ref.watch(modelsProvider)
   ▼
ModelsNotifier.build()                     ← lib/providers/models_provider.dart:42
   ├── OllamaRepositoryImpl.getAvailableModels()   → GET http://127.0.0.1:11434/api/tags
   │      (ollama_repository_impl.dart:14, timeout 5 detik)
   │      gagal? → daftar Ollama dikosongkan saja, app tetap jalan
   │
   ├── isOnlineProvider == true ?
   │      → GeminiRepositoryImpl.getAvailableModels()   → hardcoded list
   │        (gemini_repository_impl.dart:12 → ['gemini-3.5-flash', 'gemini-2.5-flash'])
   │
   └── isOnlineProvider == true ?
          → ClaudeRepositoryImpl.getAvailableModels()   → hardcoded list
            (claude_repository_impl.dart:26 → ['claude-sonnet-4-6'])

Hasil digabung: [model ollama..., model gemini..., model claude...]
```

**Penjelasan file:**

- **`lib/providers/models_provider.dart`** — `ModelsNotifier.build()` menggabungkan tiga sumber. Kalau Ollama mati, `catch (_)` membuat daftarnya kosong tanpa error. Kalau offline, model Gemini dan Claude tidak dimasukkan.
- **`lib/providers/models_provider.dart:71`** — `selectedModelProvider` menyimpan model yang sedang dipilih (awalnya string kosong). `selectedModelSyncProvider` (baris 75–85) otomatis mengisi ke model pertama saat daftar pertama kali tersedia, tapi tidak menimpa pilihan manual user.
- **`lib/providers/models_provider.dart`** — ⭐ `activeRepositoryProvider`, **saklar penting**: kalau nama model diawali `gemini-` → `GeminiRepositoryImpl`, diawali `claude-` → `ClaudeRepositoryImpl`, selain itu → `OllamaRepositoryImpl`. Inilah alasan seluruh app bisa gonta-ganti backend tanpa mengubah kode lain.
- **`lib/presentation/widgets/model_selector.dart:54-81`** — dropdown UI. Saat user memilih model baru, baris 79 menulis ke `selectedModelProvider` → `activeRepositoryProvider` otomatis ikut berubah.

**Konsep PBO di sini:** `ollama_repository.dart:6-15` adalah **abstract class** (kontrak). `OllamaRepositoryImpl`, `GeminiRepositoryImpl`, dan `ClaudeRepositoryImpl` sama-sama `implements OllamaRepository` — ini **polymorphism**: kode pemanggil (chat_provider) tidak peduli implementasinya yang mana.

---

## 5. Alur #3 — Membuat Chat Baru

Pemicu: user klik tombol **"New Chat"** (di sidebar atau di empty state).

```
Tombol "New Chat" diklik
   ▼
_showNewChatDialog()                       ← home_chat_screen.dart:72
   │  dialog muncul, user isi System Prompt (opsional)
   ▼  klik "Create Chat" (home_chat_screen.dart:118)
   │
   ├─ 1. conversationsProvider.createConversation(systemPrompt)
   │        ← conversation_provider.dart:26
   │        → buat objek Conversation (UUID baru, judul "Obrolan Baru")
   │        → DatabaseHelper.insertConversation()   ← database_helper.dart:58
   │        → INSERT ke tabel `conversations` di SQLite
   │
   ├─ 2. activeConversationIdProvider = id baru     ← home_chat_screen.dart:128
   │        (menandai chat ini sebagai yang aktif)
   │
   └─ 3. chatProvider.clearMessages() + loadMessages(id)
            → area chat dikosongkan, siap dipakai
```

**Detail penting:**

- Kalau user mengosongkan system prompt, ada default: `'Kamu adalah asisten AI yang membantu dalam Bahasa Indonesia.'` (`home_chat_screen.dart:120-122`).
- `activeConversationIdProvider` (`conversation_provider.dart:70`) hanyalah `StateProvider<String?>` sederhana — nilai `null` berarti belum ada chat dipilih, sehingga UI menampilkan *empty state* ("Good Morning! How can I help?") — lihat `home_chat_screen.dart:332-333`.

---

## 6. Alur #4 — Mengirim Pesan & Streaming Jawaban ⭐ (Alur Paling Penting)

Ini jantung aplikasi. Pemicu: user mengetik lalu tekan Enter/tombol kirim.

```
ChatInput._handleSend()                        ← chat_input.dart:43
   │ (validasi: teks tidak kosong & tidak sedang streaming)
   ▼
HomeChatScreen._onSendMessage(text)            ← home_chat_screen.dart:45
   │ (validasi: ada chat aktif? sudah pilih model? kalau belum → SnackBar)
   ▼
ChatNotifier.sendMessage()                     ← chat_provider.dart:69   ⭐ INTI
   │
   ├─ [a] Ambil system prompt terbaru dari DB          (baris 78-79)
   │        → getConversationById() — selalu fresh, jadi hasil edit prompt langsung terpakai
   │
   ├─ [b] Pesan pertama? → judul chat dibuat otomatis  (baris 82-86)
   │        dari 30 karakter pertama pesan → sidebar ikut ter-refresh
   │
   ├─ [c] Simpan pesan user ke SQLite                  (baris 89-96)
   │        → insertMessage() ke tabel `messages`
   │
   ├─ [d] Set state: isStreaming = true                (baris 98-106)
   │        → UI langsung menampilkan bubble user + progress bar
   │
   ├─ [e] Susun daftar pesan untuk API                 (baris 109-120)
   │        [system prompt] + [seluruh riwayat pesan] — urutan penting!
   │
   ├─ [f] STREAMING                                    (baris 125-133)
   │        await for (token in _repository.streamChat(...))
   │        setiap token datang → streamingText bertambah → UI rebuild
   │        → efek "AI sedang mengetik" muncul kata per kata
   │
   └─ [g] Selesai → simpan jawaban lengkap ke SQLite   (baris 136-154)
            → isStreaming = false, pesan masuk daftar permanen
```

### Ke mana `streamChat` pergi? Tergantung model yang dipilih:

**Jalur Ollama** (`lib/data/repositories/ollama_repository_impl.dart:35-67`):
- Kirim `POST http://127.0.0.1:11434/api/chat` dengan body JSON `{model, messages, stream: true}` (baris 36–42).
- Respons datang sebagai **stream baris-baris JSON** (NDJSON). Setiap baris di-decode, diambil `message.content`-nya, lalu di-`yield` sebagai token (baris 47–61).

**Jalur Gemini** (`lib/data/repositories/gemini_repository_impl.dart:16-66`):
- Ambil API key dari `.env` (baris 19).
- System prompt dipisah jadi `systemInstruction` (baris 21–26), riwayat pesan diubah ke format `Content` Gemini (baris 35–43).
- `chat.sendMessageStream(...)` (baris 49) mengalirkan potongan teks yang di-`yield` satu per satu.

**Jalur Claude** (`lib/data/repositories/claude_repository_impl.dart`):
- Ambil `ANTHROPIC_API_KEY` dan `ANTHROPIC_BASE_URL` dari `.env`.
- Kirim `POST {base}/v1/messages` dengan header `x-api-key` + `anthropic-version: 2023-06-01`. System prompt dikirim sebagai field `system` terpisah (bukan role di dalam `messages` — beda dengan Ollama).
- Respons berupa **SSE (Server-Sent Events)**: setiap baris `data: {...}` di-decode; event `content_block_delta` dengan `text_delta` di-`yield` sebagai token. Event `error` atau `stop_reason: refusal` dilempar sebagai exception dan tampil di kotak merah UI.

### Bagaimana UI menampilkan streaming?

Di `home_chat_screen.dart:483-502`: kalau `isStreaming == true`, `ListView` menambahkan **1 item ekstra** di paling bawah — `ChatBubble` berisi `streamingText` + `LinearProgressIndicator` kecil. Karena `streamingText` berubah setiap token, bubble ini "tumbuh" secara live. `ref.listen(chatProvider, ...)` di baris 145 membuat layar auto-scroll ke bawah setiap ada perubahan.

---

## 7. Alur #5 — Menghentikan Generasi (Tombol Stop)

```
Tombol Stop (chat_input) → HomeChatScreen (home_chat_screen.dart:358-359)
   ▼
ChatNotifier.stopGeneration()              ← chat_provider.dart:195
   ▼
_repository.cancelGeneration()
   ├─ Ollama: _client.close() → koneksi HTTP diputus paksa, client baru dibuat
   │           (ollama_repository_impl.dart:70-73)
   ├─ Gemini: _cancelled = true → loop stream melempar GenerationCancelledException
   │           (gemini_repository_impl.dart:69-71 & 52)
   └─ Claude: _client.close() → koneksi SSE diputus paksa, client baru dibuat
              (claude_repository_impl.dart, sama seperti Ollama)
```

Lalu di `chat_provider.dart:155-182`, blok `on GenerationCancelledException` menangkap pembatalan:
- Kalau AI sudah sempat menjawab sebagian → **jawaban parsial tetap disimpan** ke database (baris 157–173).
- Kalau belum ada teks sama sekali → state cukup direset (baris 174–181).

Kalau errornya bukan pembatalan (misal Gemini API error), blok `catch (e)` di baris 183–191 menyimpan pesan error ke `state.errorMessage`, dan UI menampilkannya sebagai kotak merah (`home_chat_screen.dart:457-481`).

---

## 8. Alur #6 — Berpindah / Mengelola Percakapan (Sidebar)

Semua ini ada di `lib/presentation/widgets/sidebar_conversations.dart`, datanya dari `conversationsProvider`.

**Memilih chat lama:**
```
Klik item di sidebar
   → activeConversationIdProvider = id itu
   → HomeChatScreen._onConversationSelected(id)      ← home_chat_screen.dart:40
   → ChatNotifier.loadMessages(id)                   ← chat_provider.dart:60
   → DatabaseHelper.getMessagesByConversation(id)    ← database_helper.dart:134
   → SELECT * FROM messages WHERE conversation_id = ? ORDER BY rowid
   → seluruh riwayat tampil, auto-scroll ke bawah
```

**Rename chat** (`sidebar_conversations.dart:11-56`):
dialog → `renameConversation()` (`conversation_provider.dart:46`) → `UPDATE conversations SET title` → daftar sidebar di-reload.

**Edit System Prompt** (`sidebar_conversations.dart:58` dst.):
dialog → `updateSystemPrompt()` (`conversation_provider.dart:52`) → `UPDATE conversations SET system_prompt`. Karena `sendMessage` selalu membaca prompt **fresh dari DB** (`chat_provider.dart:78`), pesan berikutnya langsung memakai prompt baru.

**Hapus chat:**
`deleteConversation()` (`conversation_provider.dart:58`) → `DELETE FROM conversations`. Pesan-pesannya ikut terhapus otomatis karena foreign key `ON DELETE CASCADE` (`database_helper.dart:50-51`).

---

## 9. Alur #7 — Deteksi Online/Offline & Ganti Tema

**Konektivitas** (`lib/providers/connectivity_provider.dart`):
- `connectivityProvider` (baris 5–9) adalah `StreamProvider` yang mendengarkan event dari package `connectivity_plus` secara real-time.
- `isOnlineProvider` (baris 12–17) menyederhanakannya jadi `bool`.
- Dipakai di 2 tempat: badge hijau/merah di `model_selector.dart`, dan penentu apakah model cloud ditampilkan (`models_provider.dart:53-59` — cek `isOnline` untuk Gemini di baris 53 dan Claude di baris 57). **Jadi kalau internet putus, model Gemini dan Claude otomatis hilang dari dropdown.**

**Tema** (`lib/providers/theme_provider.dart`):
- Satu `StateProvider<ThemeMode>` saja, default `system`.
- Tombol matahari/bulan di header (`home_chat_screen.dart:309-323`) menuliskan `ThemeMode.light`/`dark` → `main.dart:20` yang me-`watch` provider ini otomatis membangun ulang seluruh app dengan tema baru.

---

## 10. Database SQLite — Tempat Semua Data Disimpan

File: `lib/data/local_db/database_helper.dart`. Menggunakan pola **Singleton** (baris 9–13): berapa kali pun `DatabaseHelper()` dipanggil, objeknya selalu sama — hanya ada 1 koneksi database.

File fisik: `local_llm_chat.db` (dibuka via `sqflite_common_ffi` agar jalan di Windows desktop, baris 21–29).

```
┌────────────────────────┐         ┌─────────────────────────────┐
│ conversations          │ 1     N │ messages                    │
├────────────────────────┤◄────────┤─────────────────────────────┤
│ id (PK, UUID)          │         │ id (PK, UUID)               │
│ title                  │         │ conversation_id (FK)        │
│ system_prompt          │         │ role  (user/assistant)      │
│ model                  │         │ content                     │
│ created_at, updated_at │         │ status                      │
└────────────────────────┘         └─────────────────────────────┘
                    ON DELETE CASCADE
```

Konversi objek ⇄ tabel dilakukan model-nya sendiri: `Message.toMap()/fromMap()` (`message.dart:28-52`) dan `Conversation.toMap()/fromMap()` (`conversation.dart:21-42`). `Message` juga punya `toApiMap()` (`message.dart:39-41`) — versi ringkas `{role, content}` khusus untuk dikirim ke API Ollama.

---

## 11. Ringkasan Satu Halaman: "Kalau Saya Mau Mengubah X, Ke File Mana?"

| Ingin mengubah... | Buka file... |
|---|---|
| Alamat server Ollama | `ollama_repository_impl.dart:10` (`_baseUrl`) |
| Daftar model Gemini | `gemini_repository_impl.dart:12` |
| Daftar model Claude | `claude_repository_impl.dart` → `getAvailableModels()` |
| API key Gemini | file `.env` (variabel `GEMINI_API_KEY`) |
| API key / base URL Claude | file `.env` (variabel `ANTHROPIC_API_KEY` & `ANTHROPIC_BASE_URL`) |
| Logika kirim pesan / streaming | `chat_provider.dart` → `sendMessage()` |
| Default system prompt chat baru | `home_chat_screen.dart:121` |
| Panjang judul otomatis (30 karakter) | `chat_provider.dart:83` |
| Warna/tema aplikasi | `main.dart:25-56` (seed color `0xFFFF8A3D`) |
| Durasi splash screen (3 detik) | `splash_screen.dart:36` |
| Tampilan bubble pesan | `chat_bubble.dart` |
| Struktur tabel database | `database_helper.dart` → `_onCreate()` |
| Pesan error berbahasa Indonesia | `core/errors/exceptions.dart` |
| Menambah backend LLM baru (misal OpenAI) | buat class baru `implements OllamaRepository`, daftarkan di `models_provider.dart` (`activeRepositoryProvider`) |

---

## 12. Diagram Alur Utama (End-to-End)

```
                        ┌──────────────┐
                        │   main.dart  │  load .env, tema
                        └──────┬───────┘
                               ▼
                        ┌──────────────┐
                        │ SplashScreen │  animasi 3 detik
                        └──────┬───────┘
                               ▼
      ┌────────────────────────────────────────────────┐
      │                HomeChatScreen                  │
      │  ┌──────────────┐        ┌───────────────────┐ │
      │  │   Sidebar    │        │    Area Chat      │ │
      │  │ (riwayat)    │        │  header/bubble/   │ │
      │  └──────┬───────┘        │      input        │ │
      └─────────┼────────────────┴─────────┬─────────┘ │
                │                          │
   conversationsProvider              chatProvider ◄── selectedModelProvider
   activeConversationIdProvider           │                    │
                │                         │           activeRepositoryProvider
                ▼                         ▼                    │
        ┌───────────────┐        ┌────────────────┐   ┌────────┴────────┐
        │ DatabaseHelper│◄───────┤ ChatNotifier   │   │ pilih otomatis: │
        │   (SQLite)    │ simpan │ .sendMessage() ├──►│ Ollama / Gemini │
        │               │        │                │   │    / Claude     │
        └───────────────┘        └────────────────┘   └────────┬────────┘
                                                               │ stream token
                                                               ▼
                                                  http://127.0.0.1:11434  (Ollama — lokal)
                                                  Google Gemini API       (cloud)
                                                  Anthropic Claude API    (cloud, via ANTHROPIC_BASE_URL)
```

**Cara membaca:** user berinteraksi lewat kotak paling atas (UI), permintaan turun ke provider, provider menyimpan ke SQLite dan meneruskan ke repository yang tepat, token jawaban mengalir balik ke atas dan tampil live di layar.

---

## 13. ⭐ File-File Penting — Wajib Dipahami untuk Presentasi

Berikut file yang paling krusial untuk dijelaskan ke dosen, dikelompokkan per konsep PBO.

### 🔴 Sangat Penting (jelaskan ini duluan)

| File | Baris Kunci | Kenapa Penting |
|---|---|---|
| `lib/data/repositories/ollama_repository.dart` | 1–15 | **Abstract class / interface** — kontrak yang harus dipatuhi semua backend AI. Ini inti konsep *abstraction* dan *polymorphism* PBO. |
| `lib/providers/models_provider.dart` | 21–33 | **`activeRepositoryProvider`** — saklar otomatis Ollama/Gemini/Claude berdasarkan nama model. Bukti nyata polymorphism: `chatProvider` memanggil satu interface, tapi eksekusinya bisa berbeda-beda. |
| `lib/providers/chat_provider.dart` | 69–191 | **`sendMessage()`** — alur kirim pesan end-to-end: ambil prompt dari DB → simpan pesan user → streaming token → simpan jawaban. Jantung aplikasi. |
| `lib/data/local_db/database_helper.dart` | 8–13 | **Singleton pattern** — `factory DatabaseHelper()` selalu mengembalikan instance yang sama. Contoh design pattern klasik PBO. |

### 🟠 Penting (dukung penjelasan arsitektur)

| File | Baris Kunci | Kenapa Penting |
|---|---|---|
| `lib/main.dart` | 7–13 | Entry point: load `.env`, bungkus app dengan `ProviderScope` (Riverpod). |
| `lib/data/repositories/ollama_repository_impl.dart` | 35–67 | Implementasi streaming NDJSON ke Ollama. Contoh *concrete class* yang mengimplementasi abstract class. |
| `lib/data/repositories/gemini_repository_impl.dart` | 7–72 | Implementasi SDK Gemini. Class lain yang juga `implements OllamaRepository` — inilah polymorphism bekerja. |
| `lib/data/repositories/claude_repository_impl.dart` | 11–137 | Implementasi SSE ke Anthropic API. Sama-sama `implements OllamaRepository`, beda protokol (SSE vs NDJSON vs SDK). |
| `lib/providers/conversation_provider.dart` | 10–70 | CRUD percakapan + `activeConversationIdProvider`. Mengelola state "mana chat yang sedang aktif". |

### 🟡 Pendukung (jelaskan kalau ada waktu)

| File | Baris Kunci | Kenapa Penting |
|---|---|---|
| `lib/data/models/message.dart` | semua | Model data pesan: `toMap()`/`fromMap()` untuk SQLite, `toApiMap()` untuk API. *Encapsulation* data. |
| `lib/data/models/conversation.dart` | semua | Model data percakapan: title, system prompt, timestamps. |
| `lib/providers/connectivity_provider.dart` | 5–17 | `StreamProvider` real-time + `isOnlineProvider`. Menentukan model cloud tampil atau tidak. |
| `lib/presentation/screens/home_chat_screen.dart` | 40–69, 72–137 | Layar utama: `_onSendMessage` dan `_showNewChatDialog`. UI layer yang hanya bicara ke provider, tidak langsung ke DB. |
| `lib/core/errors/exceptions.dart` | semua | Custom exceptions: `GenerationCancelledException`, `OllamaOfflineException`, `AppException`. |

### Urutan Penjelasan yang Disarankan ke Dosen

```
1. Tunjukkan ollama_repository.dart  → "ini kontraknya (interface/abstract)"
2. Tunjukkan 3 file *_impl.dart      → "ini 3 implementasi berbeda dari kontrak yang sama = polymorphism"
3. Tunjukkan models_provider.dart    → "ini yang memilih implementasi mana yang dipakai secara otomatis"
4. Tunjukkan chat_provider.dart      → "ini yang menggunakan interface itu untuk streaming"
5. Tunjukkan database_helper.dart    → "ini Singleton untuk persistensi data"
6. Tunjukkan main.dart + home_chat_screen.dart → "ini lapisan UI, tidak tahu apapun soal HTTP"
```
