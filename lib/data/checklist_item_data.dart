import 'package:bri_cek/models/checklist_item.dart';

// Fungsi untuk mendapatkan daftar checklist berdasarkan kategori
List<ChecklistItem> getChecklistForCategory(String category) {
  switch (category) {
    case 'Satpam':
      return _getSatpamChecklist();
    case 'Teller':
      return _getTellerChecklist();
    case 'Customer Service':
      return _getCustomerServiceChecklist();
    case 'Banking Hall':
      return _getBankingHallChecklist();
    case 'Gallery e-Channel':
      return _getGalleryEChannelChecklist();
    case 'Fasad Gedung':
      return _getFasadGedungChecklist();
    case 'Ruang BRIMEN':
      return _getBrimenRoomChecklist();
    case 'Toilet':
      return _getToiletChecklist();
    default:
      return [];
  }
}

// Daftar checklist untuk Satpam
List<ChecklistItem> _getSatpamChecklist() {
  return [
    ChecklistItem(
      id: 'satpam_1',
      question: 'Satpam menggunakan seragam lengkap dan rapi',
    ),
    ChecklistItem(
      id: 'satpam_2',
      question: 'Satpam memberi salam dan menyapa nasabah',
    ),
    ChecklistItem(
      id: 'satpam_3',
      question: 'Satpam berdiri dengan postur tegak dan sigap',
    ),
    ChecklistItem(
      id: 'satpam_4',
      question: 'Satpam membantu membukakan pintu untuk nasabah',
    ),
    ChecklistItem(
      id: 'satpam_5',
      question: 'Satpam mengarahkan nasabah sesuai kebutuhan',
    ),
    ChecklistItem(
      id: 'satpam_6',
      question: 'Satpam dapat menjawab pertanyaan dasar nasabah',
    ),
    ChecklistItem(
      id: 'satpam_7',
      question: 'Satpam terlihat waspada dan mengawasi area sekitar',
    ),
    ChecklistItem(
      id: 'satpam_8',
      question: 'Satpam menggunakan bahasa yang sopan dan ramah',
    ),
  ];
}

// Daftar checklist untuk Teller
List<ChecklistItem> _getTellerChecklist() {
  return [
    ChecklistItem(
      id: 'teller_1',
      question: 'Teller menggunakan seragam rapi dan name tag',
    ),
    ChecklistItem(
      id: 'teller_2',
      question: 'Teller menyambut nasabah dengan senyum dan salam',
    ),
    ChecklistItem(
      id: 'teller_3',
      question: 'Teller berkomunikasi dengan jelas dan santun',
    ),
    ChecklistItem(
      id: 'teller_4',
      question: 'Teller menghitung uang dengan tepat dan teliti',
    ),
    ChecklistItem(
      id: 'teller_5',
      question: 'Teller mengkonfirmasi jumlah transaksi kepada nasabah',
    ),
    ChecklistItem(
      id: 'teller_6',
      question: 'Teller memproses transaksi dengan cepat dan efisien',
    ),
    ChecklistItem(
      id: 'teller_7',
      question: 'Area kerja teller tertata rapi dan bersih',
    ),
    ChecklistItem(
      id: 'teller_8',
      question: 'Teller mengucapkan terima kasih di akhir layanan',
    ),
  ];
}

// Daftar checklist untuk Customer Service
List<ChecklistItem> _getCustomerServiceChecklist() {
  return [
    ChecklistItem(
      id: 'cs_1',
      question: 'CS menggunakan seragam rapi dan name tag',
    ),
    ChecklistItem(
      id: 'cs_2',
      question: 'CS menyambut nasabah dengan senyum dan salam',
    ),
    ChecklistItem(
      id: 'cs_3',
      question:
          'CS mendengarkan keluhan/kebutuhan nasabah dengan penuh perhatian',
    ),
    ChecklistItem(
      id: 'cs_4',
      question: 'CS dapat menjelaskan produk dan layanan dengan baik',
    ),
    ChecklistItem(
      id: 'cs_5',
      question: 'CS memberikan solusi yang tepat untuk kebutuhan nasabah',
    ),
    ChecklistItem(
      id: 'cs_6',
      question: 'CS memproses pengajuan/keluhan dengan teliti dan efisien',
    ),
    ChecklistItem(
      id: 'cs_7',
      question: 'CS menggunakan bahasa yang mudah dipahami nasabah',
    ),
    ChecklistItem(
      id: 'cs_8',
      question: 'CS mengucapkan terima kasih dan menawarkan bantuan lain',
    ),
  ];
}

// Daftar checklist untuk Banking Hall
List<ChecklistItem> _getBankingHallChecklist() {
  return [
    ChecklistItem(id: 'hall_1', question: 'Banking Hall bersih dan rapi'),
    ChecklistItem(id: 'hall_2', question: 'Pencahayaan Banking Hall memadai'),
    ChecklistItem(id: 'hall_3', question: 'Suhu ruangan Banking Hall nyaman'),
    ChecklistItem(
      id: 'hall_4',
      question: 'Kursi antre tersedia dalam jumlah cukup',
    ),
    ChecklistItem(id: 'hall_5', question: 'Tersedia air minum untuk nasabah'),
    ChecklistItem(
      id: 'hall_6',
      question: 'Sistem antrean berfungsi dengan baik',
    ),
    ChecklistItem(id: 'hall_7', question: 'Brosur dan formulir tertata rapi'),
    ChecklistItem(
      id: 'hall_8',
      question: 'Tersedia pena yang berfungsi di meja formulir',
    ),
    ChecklistItem(
      id: 'hall_9',
      question: 'Tampilan informasi digital berfungsi dengan baik',
    ),
  ];
}

// Daftar checklist untuk Gallery e-Channel
List<ChecklistItem> _getGalleryEChannelChecklist() {
  return [
    ChecklistItem(id: 'channel_1', question: 'Area e-Channel bersih dan rapi'),
    ChecklistItem(
      id: 'channel_2',
      question: 'Semua mesin ATM menyala dan berfungsi',
    ),
    ChecklistItem(
      id: 'channel_3',
      question: 'Mesin setor tunai berfungsi dengan baik',
    ),
    ChecklistItem(
      id: 'channel_4',
      question: 'Tersedia petunjuk penggunaan yang jelas',
    ),
    ChecklistItem(
      id: 'channel_5',
      question: 'Kamera pengawas berfungsi dan terawat',
    ),
    ChecklistItem(
      id: 'channel_6',
      question: 'Pencahayaan area e-Channel memadai',
    ),
    ChecklistItem(
      id: 'channel_7',
      question: 'Pintu akses e-Channel berfungsi dengan baik',
    ),
    ChecklistItem(
      id: 'channel_8',
      question: 'Tersedia nomor kontak bantuan yang jelas',
    ),
  ];
}

// Daftar checklist untuk Fasad Gedung
List<ChecklistItem> _getFasadGedungChecklist() {
  return [
    ChecklistItem(
      id: 'fasad_1',
      question: 'Papan nama bank terpasang dengan baik dan terlihat jelas',
    ),
    ChecklistItem(
      id: 'fasad_2',
      question: 'Cat dinding luar gedung bersih dan tidak kusam',
    ),
    ChecklistItem(
      id: 'fasad_3',
      question: 'Kaca jendela bersih dan tidak rusak',
    ),
    ChecklistItem(
      id: 'fasad_4',
      question: 'Area depan gedung bersih dari sampah',
    ),
    ChecklistItem(
      id: 'fasad_5',
      question: 'Pencahayaan luar gedung berfungsi dengan baik',
    ),
    ChecklistItem(
      id: 'fasad_6',
      question: 'Taman atau tanaman di sekitar gedung terawat',
    ),
    ChecklistItem(
      id: 'fasad_7',
      question: 'Tidak ada kerusakan pada struktur luar gedung',
    ),
    ChecklistItem(id: 'fasad_8', question: 'Area parkir bersih dan tertata'),
  ];
}

// Daftar checklist untuk Ruang BRIMEN
List<ChecklistItem> _getBrimenRoomChecklist() {
  return [
    ChecklistItem(id: 'brimen_1', question: 'Ruang BRIMEN bersih dan rapi'),
    ChecklistItem(
      id: 'brimen_2',
      question: 'Meja dan kursi dalam kondisi baik',
    ),
    ChecklistItem(
      id: 'brimen_3',
      question: 'Peralatan presentasi berfungsi dengan baik',
    ),
    ChecklistItem(id: 'brimen_4', question: 'Pencahayaan ruangan memadai'),
    ChecklistItem(id: 'brimen_5', question: 'Suhu ruangan nyaman'),
    ChecklistItem(
      id: 'brimen_6',
      question: 'Materi presentasi tersedia dan terorganisir',
    ),
    ChecklistItem(
      id: 'brimen_7',
      question: 'Koneksi internet berfungsi dengan baik',
    ),
  ];
}

// Daftar checklist untuk Toilet
List<ChecklistItem> _getToiletChecklist() {
  return [
    ChecklistItem(id: 'toilet_1', question: 'Toilet bersih dan tidak berbau'),
    ChecklistItem(id: 'toilet_2', question: 'Wastafel berfungsi dengan baik'),
    ChecklistItem(
      id: 'toilet_3',
      question: 'Toilet flush berfungsi dengan baik',
    ),
    ChecklistItem(id: 'toilet_4', question: 'Tersedia sabun cuci tangan'),
    ChecklistItem(id: 'toilet_5', question: 'Tersedia tisu toilet yang cukup'),
    ChecklistItem(
      id: 'toilet_6',
      question: 'Tersedia tempat sampah yang bersih',
    ),
    ChecklistItem(
      id: 'toilet_7',
      question: 'Lantai toilet kering dan tidak licin',
    ),
    ChecklistItem(id: 'toilet_8', question: 'Pencahayaan toilet memadai'),
    ChecklistItem(
      id: 'toilet_9',
      question: 'Pintu toilet dapat dikunci dengan baik',
    ),
  ];
}
