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
    // Grooming - Wajah & Badan
    ChecklistItem(
      id: 'teller_g_wb_1',
      question: 'Wajah bersih dan wajah terlihat segar',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
    ),
    ChecklistItem(
      id: 'teller_g_wb_2',
      question:
          'Wanita: Menggunakan make up natural (bedak, alis, eye liner, blush on, lipstick)',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'teller_g_wb_3',
      question: 'Tidak berbau badan, mulut, dan parfum menyengat',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
    ),

    // Grooming - Rambut (Non-Hijab)
    ChecklistItem(
      id: 'teller_g_r_1',
      question:
          'Rambut tertata rapi, warna rambut terlihat alami (hitam/cokelat tua) dan tidak menggunakan warna highlight/ombre mencolok',
      category: 'Grooming',
      subcategory: 'Rambut',
      forHijab: false,
    ),
    ChecklistItem(
      id: 'teller_g_r_2',
      question:
          'Tidak menggunakan aksesoris rambut warna-warni/ikat rambut karet/jedai',
      category: 'Grooming',
      subcategory: 'Rambut',
      forHijab: false,
    ),

    // Grooming - Rambut Seragam Korporat/Batik (Non-Hijab)
    ChecklistItem(
      id: 'teller_g_r_k_1',
      question:
          'Wanita: Rambut diikat/disanggul rapi dengan jaring rambut/hairnet warna hitam/sesuai warna rambut',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Korporat/Batik',
      forHijab: false,
    ),
    ChecklistItem(
      id: 'teller_g_r_k_2',
      question:
          'Pria: Rambut pendek rapi, tidak menyentuh kerah baju dan daun telinga',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Korporat/Batik',
      forHijab: false,
    ),

    // Grooming - Rambut Seragam Pakaian Casual (Non-Hijab)
    ChecklistItem(
      id: 'teller_g_r_c_1',
      question:
          'Wanita: Rambut pendek/sedang/panjang diikat rapi panjang maksimal sebahu, tidak diwarnai mencolok',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Casual',
      forHijab: false,
    ),
    ChecklistItem(
      id: 'teller_g_r_c_2',
      question:
          'Pria: Rambut pendek rapi, tidak menyentuh kerah baju dan daun telinga',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Casual',
      forHijab: false,
    ),

    // Grooming - Jilbab (Hijab)
    ChecklistItem(
      id: 'teller_g_j_1',
      question:
          'Jilbab dikenakan dengan rapi, tidak terlihat rambut atau leher',
      category: 'Grooming',
      subcategory: 'Jilbab',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'teller_g_j_2',
      question: 'Jilbab berwarna senada/sesuai dengan seragam',
      category: 'Grooming',
      subcategory: 'Jilbab',
      forHijab: true,
    ),

    // Grooming - Pakaian Seragam Korporat
    ChecklistItem(
      id: 'teller_g_p_k_1',
      question:
          'Menggunakan seragam korporat sesuai ketentuan pada hari Senin-Rabu',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Korporat',
    ),
    ChecklistItem(
      id: 'teller_g_p_k_2',
      question: 'Seragam bersih, rapi dan tidak kusut',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Korporat',
    ),

    // Grooming - Pakaian Seragam Batik
    ChecklistItem(
      id: 'teller_g_p_b_1',
      question: 'Menggunakan seragam batik sesuai ketentuan pada hari Kamis',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Batik',
    ),
    ChecklistItem(
      id: 'teller_g_p_b_2',
      question: 'Batik bersih, rapi dan tidak kusut',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Batik',
    ),

    // Grooming - Pakaian Casual
    ChecklistItem(
      id: 'teller_g_p_c_1',
      question: 'Menggunakan pakaian casual sesuai ketentuan pada hari Jumat',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Casual',
    ),
    ChecklistItem(
      id: 'teller_g_p_c_2',
      question: 'Pakaian casual bersih, rapi dan tidak kusut',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Casual',
    ),

    // Grooming - Atribut & Aksesoris
    ChecklistItem(
      id: 'teller_g_a_1',
      question: 'Menggunakan name tag secara benar dan terlihat jelas',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
    ),
    ChecklistItem(
      id: 'teller_g_a_2',
      question:
          'Wanita: Menggunakan aksesoris yang tidak berlebihan dan minimalis',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
    ),
    ChecklistItem(
      id: 'teller_g_a_3',
      question:
          'Pria: Tidak menggunakan aksesoris selain cincin kawin dan jam tangan',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
    ),

    // Standar Layanan
    ChecklistItem(
      id: 'teller_s_1',
      question: 'Teller menyambut nasabah dengan senyum dan salam',
      category: 'Standar Layanan',
      subcategory: 'Sambutan',
    ),
    ChecklistItem(
      id: 'teller_s_2',
      question: 'Teller berkomunikasi dengan jelas dan santun',
      category: 'Standar Layanan',
      subcategory: 'Komunikasi',
    ),
    ChecklistItem(
      id: 'teller_s_3',
      question: 'Teller menghitung uang dengan tepat dan teliti',
      category: 'Standar Layanan',
      subcategory: 'Transaksi',
    ),
    ChecklistItem(
      id: 'teller_s_4',
      question: 'Teller mengkonfirmasi jumlah transaksi kepada nasabah',
      category: 'Standar Layanan',
      subcategory: 'Transaksi',
    ),
    ChecklistItem(
      id: 'teller_s_5',
      question: 'Teller memproses transaksi dengan cepat dan efisien',
      category: 'Standar Layanan',
      subcategory: 'Transaksi',
    ),
    ChecklistItem(
      id: 'teller_s_6',
      question: 'Area kerja teller tertata rapi dan bersih',
      category: 'Standar Layanan',
      subcategory: 'Area Kerja',
    ),
    ChecklistItem(
      id: 'teller_s_7',
      question: 'Teller mengucapkan terima kasih di akhir layanan',
      category: 'Standar Layanan',
      subcategory: 'Penutupan',
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
