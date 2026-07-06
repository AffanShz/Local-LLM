# Panduan Umum Pengembangan Early Bird dengan TypeScript + Tauri

Dokumen ini adalah panduan umum untuk mengerjakan penugasan Early Bird menggunakan TypeScript dan Tauri. Karena setiap studi kasus sudah memiliki tutorial terpisah, dokumen ini tidak lagi membahas detail teknis per proyek secara panjang. Fokusnya adalah persiapan, cara kerja yang disarankan, best practice, kesalahan yang perlu dihindari, serta tujuan pembelajaran dari penugasan ini.

Tutorial detail per proyek tersedia di:

- `01-tutorial-rest-api-client-tauri.md`
- `02-tutorial-local-llm-chat-client-tauri.md`
- `03-tutorial-ssh-client-session-manager-tauri.md`
- `04-tutorial-document-qa-rag-tauri.md`
- `05-tutorial-system-resource-monitor-tauri.md`

---

## 1. Gambaran Umum Penugasan

Early Bird adalah penugasan proyek desktop berbasis Object-Oriented Programming. Mahasiswa memilih salah satu dari lima studi kasus yang tersedia, lalu membangun aplikasi desktop menggunakan bahasa statically-typed.

Dalam panduan ini, semua proyek diasumsikan menggunakan:

- TypeScript untuk logika aplikasi dan frontend
- Tauri sebagai desktop app shell
- SQLite atau file lokal untuk persistensi data
- Rust/Tauri command hanya jika diperlukan untuk akses native

Lima pilihan studi kasus:

1. REST API Client
2. Local LLM Chat Client
3. SSH Client dengan Session Manager
4. Document Q&A dengan RAG
5. System Resource Monitor

Semua studi kasus sengaja dipilih agar mahasiswa tidak hanya membuat aplikasi CRUD biasa. Masing-masing proyek melibatkan dependency eksternal atau sistem nyata, seperti HTTP, Ollama, SSH, dokumen, embedding, atau metrik sistem operasi.

---

## 2. Tujuan Utama Penugasan

Tujuan utama penugasan ini adalah melatih mahasiswa membangun aplikasi desktop yang rapi secara desain, bukan sekadar aplikasi yang tampak jalan.

Mahasiswa diharapkan mampu:

- menerapkan prinsip OOP dalam proyek nyata
- memisahkan model, service, repository, dan UI
- mengelola state aplikasi dengan baik
- menangani error dari sistem eksternal
- menyimpan data agar tetap ada setelah aplikasi ditutup
- menjelaskan keputusan desain yang dibuat
- membuat dokumentasi dan checklist testing yang jelas

Penilaian sebaiknya tidak hanya melihat banyaknya fitur, tetapi juga melihat apakah aplikasi dibangun dengan struktur yang bisa dipahami dan dirawat.

---

## 3. Tujuan Pendamping

Selain tujuan utama, ada beberapa tujuan pendamping:

- mahasiswa terbiasa membaca dokumentasi library
- mahasiswa memahami integrasi aplikasi dengan sistem luar
- mahasiswa belajar membuat MVP yang realistis
- mahasiswa belajar membuat commit bertahap
- mahasiswa belajar menulis README yang berguna
- mahasiswa belajar melakukan manual testing
- mahasiswa belajar menjelaskan class diagram dan arsitektur sederhana

Penugasan ini juga melatih mahasiswa membuat keputusan scope. Aplikasi kecil yang stabil lebih baik daripada aplikasi besar tetapi banyak fitur setengah jadi.

---

## 4. Persiapan Awal

Sebelum mulai mengerjakan proyek, pastikan environment sudah siap.

## 4.1 Software yang Perlu Disiapkan

Minimal siapkan:

- Node.js versi modern
- package manager: `npm`, `pnpm`, atau `bun`
- Rust toolchain
- Tauri prerequisites sesuai OS
- Git
- editor seperti VS Code

Tambahan sesuai proyek:

- Ollama untuk proyek LLM Chat dan RAG
- Docker atau server SSH uji untuk proyek SSH Client
- SQLite browser jika ingin memeriksa database lokal

## 4.2 Cek Instalasi Dasar

Pastikan command berikut berjalan:

```text
node --version
npm --version
rustc --version
cargo --version
git --version
```

Jika menggunakan Tauri, ikuti dokumentasi resmi untuk setup OS masing-masing. Kebutuhan Linux, Windows, dan macOS bisa berbeda.

## 4.3 Buat Project Tauri

Buat project baru dengan Tauri. Pilih template yang paling nyaman.

Rekomendasi untuk pemula:

- Tauri + Vite + TypeScript
- frontend bebas: vanilla, React, Vue, atau Svelte

Setelah project dibuat, jalankan aplikasi kosong terlebih dahulu. Jangan mulai mengerjakan fitur sebelum aplikasi dasar berhasil berjalan.

---

## 5. Cara Memilih Studi Kasus

Pilih studi kasus berdasarkan minat dan kesiapan teknis, bukan karena terlihat paling keren.

Panduan memilih:

- Pilih REST API Client jika ingin fokus pada HTTP, request-response, collection, dan environment variable.
- Pilih Local LLM Chat Client jika tertarik dengan AI lokal, chat UI, streaming response, dan history conversation.
- Pilih SSH Client jika tertarik dengan server, terminal, remote access, dan credential management.
- Pilih Document Q&A dengan RAG jika tertarik dengan AI, dokumen, embedding, dan pencarian semantik.
- Pilih System Resource Monitor jika tertarik dengan sistem operasi, metrik resource, chart, dan alert.

Jangan memilih proyek hanya karena terdengar canggih. Pilih proyek yang bisa diselesaikan MVP-nya dalam waktu yang tersedia.

---

## 6. Prinsip MVP

MVP atau Minimum Viable Product adalah versi paling kecil dari aplikasi yang masih menunjukkan fungsi utama.

Contoh MVP:

- REST API Client: bisa kirim request GET dan tampilkan response
- LLM Chat: bisa kirim pesan ke Ollama dan tampilkan jawaban
- SSH Client: bisa menyimpan session dan connect ke server uji
- RAG: bisa upload file teks dan menjawab berdasarkan isi file
- Monitor: bisa menampilkan CPU dan RAM real-time

Setelah MVP berjalan, baru tambahkan fitur lain.

Urutan yang disarankan:

1. buat aplikasi dasar jalan
2. buat model utama
3. buat fitur inti paling kecil
4. tambahkan penyimpanan data
5. tambahkan error handling
6. tambahkan fitur MVP lain
7. rapikan UI
8. tulis dokumentasi
9. lakukan manual testing

---

## 7. Struktur Folder Umum

Struktur folder yang disarankan:

```text
src/
  components/
  pages/
  models/
  services/
  repositories/
  utils/
  errors/
```

Penjelasan:

- `components/` berisi komponen tampilan kecil
- `pages/` berisi halaman utama aplikasi
- `models/` berisi bentuk data utama
- `services/` berisi logika utama aplikasi
- `repositories/` berisi kode simpan dan baca data
- `utils/` berisi fungsi bantu
- `errors/` berisi custom error

Jika proyek membutuhkan akses native Tauri/Rust, tambahkan command di sisi `src-tauri`.

Prinsip utamanya: jangan menumpuk semua kode di satu file besar.

---

## 8. Pembagian Tanggung Jawab Kode

## 8.1 UI atau Component

UI bertugas:

- menampilkan data
- menerima input user
- menampilkan loading dan error
- memanggil service

UI sebaiknya tidak berisi logika panjang seperti parsing response, query database, atau koneksi eksternal.

## 8.2 Model

Model menjelaskan bentuk data utama.

Contoh:

```ts
type ApiRequest = {
  id: string
  method: 'GET' | 'POST'
  url: string
}
```

Model membantu aplikasi punya struktur data yang jelas.

## 8.3 Service

Service berisi logika utama.

Contoh tanggung jawab service:

- mengirim HTTP request
- mengirim chat ke Ollama
- memproses dokumen
- mengevaluasi alert
- mengatur alur koneksi SSH

## 8.4 Repository

Repository bertugas menyimpan dan membaca data.

Contoh:

- menyimpan conversation
- membaca daftar session SSH
- menyimpan alert rule
- menyimpan collection request

Dengan repository, cara penyimpanan bisa diganti tanpa mengubah seluruh aplikasi.

## 8.5 Error

Gunakan error yang jelas. Jangan semua error dianggap sama.

Contoh kategori error:

- `ValidationError`
- `NetworkError`
- `StorageError`
- `AuthenticationError`
- `ExternalServiceError`

Pesan error harus bisa dipahami user.

---

## 9. Best Practice Pengembangan

## 9.1 Kerjakan Bertahap

Jangan mencoba membuat semua fitur sekaligus.

Kerjakan satu alur kecil sampai benar-benar jalan, lalu tambah fitur berikutnya.

## 9.2 Commit Secara Rutin

Gunakan Git sejak awal.

Contoh commit yang baik:

```text
init tauri project
add request model and service
implement basic GET request
add collection persistence
add manual testing checklist
```

Commit history menunjukkan proses kerja mahasiswa.

## 9.3 Pisahkan Data dan Tampilan

Jangan membuat data penting hanya tersimpan di state UI. Jika data harus bertahan setelah restart, simpan ke SQLite atau file.

## 9.4 Tulis README dari Awal

README tidak harus menunggu proyek selesai. Mulai dari kerangka dulu, lalu lengkapi seiring pengerjaan.

README minimal berisi:

- deskripsi aplikasi
- fitur MVP
- cara install
- cara menjalankan
- struktur folder
- teknologi yang dipakai
- screenshot jika ada
- known issues

## 9.5 Buat Checklist Testing

Manual testing checklist wajib membantu orang lain menguji aplikasi.

Format sederhana:

```text
ID: TC-001
Fitur: Kirim request GET
Langkah:
1. Buka aplikasi
2. Isi URL valid
3. Klik Send
Hasil yang diharapkan:
Response tampil
Status: Lulus / Gagal
```

## 9.6 Tangani Error Sejak Awal

Jangan menunggu akhir proyek untuk error handling.

Uji kondisi seperti:

- input kosong
- koneksi gagal
- file rusak
- database gagal
- service eksternal mati

---

## 10. Hal yang Sebaiknya Dilakukan

Lakukan hal berikut:

- mulai dari MVP kecil
- buat struktur folder rapi
- gunakan model untuk data utama
- gunakan service untuk logika utama
- gunakan repository untuk penyimpanan
- gunakan TypeScript type dengan serius
- simpan data penting secara persisten
- tampilkan loading state
- tampilkan pesan error yang jelas
- tulis README dan checklist testing
- buat class diagram sederhana
- commit secara bertahap
- jelaskan batasan aplikasi di README

---

## 11. Hal yang Sebaiknya Dihindari

Hindari hal berikut:

- menaruh semua kode di satu file besar
- membuat UI dulu tanpa memikirkan data dan alur
- menunda persistensi sampai akhir
- menyalin kode tanpa paham cara kerjanya
- membuat terlalu banyak fitur sebelum MVP stabil
- menyimpan password atau token secara plain text
- mengabaikan error dari service eksternal
- menganggap semua response pasti JSON
- membiarkan aplikasi crash saat input salah
- membuat README hanya berisi cara install dependency
- menggunakan library berat tanpa memahami kebutuhan
- mengejar stretch goal sebelum fitur wajib selesai

---

## 12. Prinsip OOP yang Harus Terlihat

Karena ini tugas Pemrograman Berorientasi Objek, aplikasi harus menunjukkan prinsip OOP secara nyata.

## 12.1 Encapsulation

Data dan perilaku yang berkaitan dikelompokkan dengan jelas.

Contoh: logika validasi request tidak tersebar di semua komponen UI, tetapi berada di service atau model yang sesuai.

## 12.2 Abstraction

Gunakan interface atau class untuk menyembunyikan detail teknis.

Contoh: UI tidak perlu tahu detail cara data disimpan di SQLite. UI cukup memanggil repository/service.

## 12.3 Polymorphism

Jika relevan, gunakan beberapa implementasi untuk kontrak yang sama.

Contoh:

- storage JSON dan storage SQLite
- parser dokumen teks dan parser PDF
- notification toast dan notification native

## 12.4 Inheritance

Inheritance boleh digunakan, tetapi jangan dipaksakan. Gunakan jika memang ada hubungan yang jelas.

Contoh yang wajar:

- base error class
- base model/entity
- base repository sederhana

---

## 13. Persistensi Data

Persistensi berarti data tetap ada setelah aplikasi ditutup.

Pilihan umum:

## 13.1 File JSON

Cocok untuk data sederhana.

Kelebihan:

- mudah dibuat
- mudah dicek
- cocok untuk MVP kecil

Kekurangan:

- kurang cocok untuk data banyak
- rawan konflik jika penulisan tidak hati-hati

## 13.2 SQLite

Cocok untuk data yang lebih terstruktur.

Kelebihan:

- data lebih rapi
- cocok untuk history, chat, document chunk, dan alert
- mudah di-query

Kekurangan:

- perlu membuat schema tabel
- perlu memahami SQL dasar

Saran umum: jika proyek punya banyak data atau history, gunakan SQLite.

---

## 14. Penggunaan Tauri dan Rust

Dalam proyek ini, TypeScript tetap menjadi bagian utama untuk logika aplikasi dan UI. Rust/Tauri digunakan jika butuh akses native.

Gunakan Rust/Tauri command untuk:

- membaca metrik sistem
- koneksi SSH
- akses file/native tertentu
- notifikasi OS
- operasi yang sulit dilakukan dari frontend

Jangan memindahkan semua logika ke Rust jika tidak perlu. Tujuan mata kuliah tetap menilai pemahaman OOP dan struktur aplikasi yang bisa dijelaskan mahasiswa.

---

## 15. Dokumentasi yang Harus Dikumpulkan

Minimal kumpulkan:

- source code dalam Git repository
- README.md
- class diagram
- manual testing checklist

README harus cukup jelas agar orang lain bisa menjalankan aplikasi dari awal.

Class diagram tidak perlu terlalu rumit. Minimal tampilkan:

- model utama
- service utama
- repository utama
- hubungan antar class

Manual testing checklist harus menunjukkan bahwa mahasiswa benar-benar menguji aplikasi.

---

## 16. Rencana Kerja 2 Minggu

Contoh pembagian waktu:

## Hari 1-2

- pilih studi kasus
- baca tutorial proyek terkait
- setup Tauri
- buat struktur folder
- buat model utama

## Hari 3-5

- implementasi MVP paling kecil
- pastikan alur utama berjalan
- belum perlu tampilan terlalu bagus

## Hari 6-8

- tambahkan persistensi
- tambahkan fitur MVP lain
- mulai tangani error penting

## Hari 9-11

- rapikan UI
- tambahkan fitur pendukung
- uji skenario gagal

## Hari 12-13

- tulis README
- buat class diagram
- buat manual testing checklist
- perbaiki bug

## Hari 14

- finalisasi demo
- cek aplikasi bisa dijalankan dari awal
- jangan menambah fitur besar baru

---

## 17. Kriteria Aplikasi yang Baik

Aplikasi Early Bird yang baik adalah aplikasi yang:

- MVP-nya berjalan
- data penting tersimpan
- error ditangani dengan jelas
- struktur folder rapi
- UI cukup mudah dipakai
- README bisa diikuti
- class diagram sesuai implementasi
- manual testing checklist jelas
- mahasiswa bisa menjelaskan cara kerja aplikasinya

Aplikasi tidak harus sempurna. Yang penting stabil, bisa dijalankan, dan desainnya bisa dipertanggungjawabkan.

---

## 18. Penutup

Penugasan Early Bird bukan sekadar membuat aplikasi desktop. Penugasan ini melatih mahasiswa menghadapi masalah nyata: koneksi jaringan, service eksternal, data lokal, parsing, state aplikasi, error handling, dan dokumentasi.

Kunci keberhasilan:

1. pilih scope yang realistis
2. mulai dari MVP kecil
3. pisahkan UI, model, service, dan repository
4. simpan data dengan benar
5. tangani error
6. dokumentasikan proses dan hasil

Lebih baik aplikasi sederhana yang stabil dan rapi daripada aplikasi besar yang sulit dijalankan dan sulit dijelaskan.
