# LocalMind — Local LLM Chat Desktop App

Aplikasi desktop chat untuk LLM lokal menggunakan Ollama. Dibangun dengan Flutter + Riverpod.

---

## Fitur

- Terhubung ke Ollama lokal (`http://localhost:11434`)
- Menampilkan daftar model yang tersedia dan pemilihan model
- Membuat conversation baru dengan system prompt kustom
- Mengirim pesan dan menerima jawaban AI dengan **streaming**
- Tombol **Stop** untuk membatalkan generation
- Menyimpan history chat ke **SQLite** (persisten setelah restart)
- Render **Markdown** pada pesan assistant (code block, list, bold, dll.)
- Sidebar conversation dengan delete dan auto-title
- Error handling: Ollama offline, model kosong, input kosong

---

## Stack Teknologi

| Komponen         | Teknologi                                |
| ---------------- | ---------------------------------------- |
| Framework        | Flutter 3.35+ (Windows Desktop)          |
| State Management | **Riverpod** (`flutter_riverpod ^2.6.1`) |
| HTTP / Streaming | `http ^1.6.0`                            |
| Database         | SQLite via `sqflite_common_ffi ^2.3.7+1` |
| Markdown         | `flutter_markdown ^0.7.7+1`              |
| UUID             | `uuid ^4.5.3`                            |
| LLM Backend      | [Ollama](https://ollama.com)             |

---

## Arsitektur (Clean Architecture Dasar)

```
lib/
├── main.dart                          # Entry point, ProviderScope
├── core/
│   └── errors/
│       └── exceptions.dart            # Custom exceptions
├── data/
│   ├── local_db/
│   │   └── database_helper.dart       # SQLite singleton
│   ├── models/
│   │   ├── conversation.dart          # Model Conversation
│   │   ├── message.dart               # Model Message
│   │   └── model_info.dart            # Model ModelInfo
│   └── repositories/
│       ├── ollama_repository.dart     # Abstract interface (Abstraction)
│       └── ollama_repository_impl.dart # Implementasi HTTP + streaming
├── providers/
│   ├── models_provider.dart           # AsyncNotifier: daftar model
│   ├── conversation_provider.dart     # AsyncNotifier: daftar conversation
│   ├── chat_provider.dart             # AsyncNotifier: messages + streaming
│   └── providers.dart                 # Barrel export
└── presentation/
    ├── screens/
    │   └── home_chat_screen.dart      # Layar utama (layout 2-panel)
    └── widgets/
        ├── chat_bubble.dart           # Bubble pesan user/assistant
        ├── chat_input.dart            # Input bar + tombol Send/Stop
        ├── model_selector.dart        # Dropdown pilih model
        └── sidebar_conversations.dart # Sidebar riwayat conversation
```

### Pembagian tanggung jawab

| Layer                | Tugas                                     |
| -------------------- | ----------------------------------------- |
| `data/models/`       | Definisi data (encapsulation)             |
| `data/repositories/` | Komunikasi Ollama API + abstraksi kontrak |
| `data/local_db/`     | Persistensi SQLite                        |
| `providers/`         | State management dengan Riverpod          |
| `presentation/`      | UI — hanya tampilkan dan trigger aksi     |

---

## Prinsip OOP yang Diterapkan

- **Encapsulation**: Data dan operasi dikelompokkan dalam class (Conversation, Message, DatabaseHelper)
- **Abstraction**: `OllamaRepository` adalah abstract class; UI tidak tahu detail HTTP
- **Polymorphism**: `OllamaRepositoryImpl` mengimplementasi `OllamaRepository`; bisa diganti dengan implementasi lain
- **Inheritance**: `AppException` sebagai base class; `OllamaOfflineException`, `ModelNotFoundException`, dll. mewarisinya

---

## Cara Install dan Menjalankan

### Prasyarat

1. [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x
2. [Ollama](https://ollama.com) — harus berjalan di background
3. Minimal satu model Ollama sudah di-pull:

```bash
ollama pull llama3.2:1b
ollama serve
```

### Jalankan aplikasi

```bash
cd local_llm_chat
flutter pub get
flutter run -d windows
```

### Build executable

```bash
flutter build windows
```

Hasil build ada di `build/windows/x64/runner/Release/local_llm_chat.exe`

---

## Class Diagram

```
AppException
  ├── OllamaOfflineException
  ├── ModelNotFoundException
  ├── GenerationCancelledException
  └── DatabaseException

OllamaRepository (abstract)
  └── OllamaRepositoryImpl

Conversation ──── (1:many) ──── Message

DatabaseHelper
  ├── insertConversation / getAllConversations / deleteConversation
  └── insertMessage / getMessagesByConversation

Providers (Riverpod)
  ├── modelsProvider        → AsyncNotifier<List<String>>
  ├── selectedModelProvider → StateProvider<String>
  ├── conversationsProvider → AsyncNotifier<List<Conversation>>
  ├── activeConversationIdProvider → StateProvider<String?>
  └── chatProvider          → AsyncNotifier<ChatState>
```

---

## Manual Testing Checklist

| ID     | Fitur               | Langkah                                               | Hasil Diharapkan                                |
| ------ | ------------------- | ----------------------------------------------------- | ----------------------------------------------- |
| TC-001 | Koneksi Ollama      | Jalankan app dengan Ollama aktif                      | Daftar model muncul di dropdown                 |
| TC-002 | Ollama offline      | Jalankan app tanpa Ollama                             | Pesan "Ollama offline" + tombol "Coba lagi"     |
| TC-003 | New Chat            | Klik New Chat, isi system prompt, klik Buat Chat      | Chat baru muncul di sidebar                     |
| TC-004 | Kirim pesan         | Pilih model, ketik pesan, tekan Enter                 | Jawaban AI muncul dengan streaming              |
| TC-005 | Streaming           | Kirim pesan panjang                                   | Token muncul satu per satu                      |
| TC-006 | Tombol Stop         | Saat streaming aktif, klik Stop                       | Generation berhenti, partial response tersimpan |
| TC-007 | Persistensi         | Kirim pesan, restart app, buka conversation yang sama | History chat masih ada                          |
| TC-008 | Markdown            | Tanya "Beri contoh kode Python"                       | Code block tampil dengan syntax highlight       |
| TC-009 | System prompt       | Buat chat dengan system prompt "Jawab singkat"        | Gaya jawaban berubah sesuai instruksi           |
| TC-010 | Delete conversation | Klik ikon hapus di sidebar                            | Conversation hilang dari daftar                 |
| TC-011 | Input kosong        | Tekan Send tanpa teks                                 | Tidak terjadi apa-apa                           |
| TC-012 | Sidebar toggle      | Klik tombol menu                                      | Sidebar buka/tutup dengan animasi               |

---

## Known Issues / Batasan

- Tidak ada export chat ke Markdown (stretch goal)
- Tidak ada temperature / parameter generation lain
- Tidak ada regenerate response
- Auto-scroll saat streaming kadang butuh scroll manual jika window sangat kecil

---

## Struktur Database SQLite

**Tabel `conversations`**

| Kolom         | Tipe    | Keterangan                        |
| ------------- | ------- | --------------------------------- |
| id            | TEXT PK | UUID                              |
| title         | TEXT    | Auto-generated dari pesan pertama |
| system_prompt | TEXT    | Instruksi awal untuk model        |
| model         | TEXT    | Model yang digunakan              |
| created_at    | INTEGER | Unix timestamp ms                 |
| updated_at    | INTEGER | Unix timestamp ms                 |

**Tabel `messages`**

| Kolom           | Tipe    | Keterangan                    |
| --------------- | ------- | ----------------------------- |
| id              | TEXT PK | UUID                          |
| conversation_id | TEXT FK | Referensi ke conversations.id |
| role            | TEXT    | 'user', 'assistant', 'system' |
| content         | TEXT    | Isi pesan                     |
| status          | TEXT    | 'done', 'failed'              |
