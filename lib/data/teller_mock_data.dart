import 'package:bri_cek/models/checklist_item.dart';

// Mock data for Teller based on similar structure to CS
// This is a template - replace with Firestore data when ready

List<ChecklistItem> getTellerMockData() {
  return [
    // GROOMING - Wajah & Badan
    ChecklistItem(
      id: 'teller_grooming_wb_1',
      question: 'Wajah bersih dan wajah terlihat segar',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
    ),
    ChecklistItem(
      id: 'teller_grooming_wb_2',
      question:
          'Wanita: Menggunakan make up natural (bedak, alis, eye liner, blush on, lipstick)',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'teller_grooming_wb_3',
      question: 'Tidak berbau badan, mulut, dan parfum menyengat',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
    ),
    ChecklistItem(
      id: 'teller_grooming_wb_4',
      question:
          'Pria: Wajah tidak diperkenankan berjenggot, berkumis, berjambang & alis dikerik',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
      forHijab: false,
    ),

    // GROOMING - Rambut
    ChecklistItem(
      id: 'teller_grooming_r_1',
      question:
          'Rambut tertata rapi, warna rambut terlihat alami (hitam/cokelat tua) dan tidak menggunakan warna highlight/ombre mencolok',
      category: 'Grooming',
      subcategory: 'Rambut',
      forHijab: false,
    ),
    ChecklistItem(
      id: 'teller_grooming_r_2',
      question:
          'Tidak menggunakan aksesoris rambut warna-warni/ikat rambut karet/jedai',
      category: 'Grooming',
      subcategory: 'Rambut',
      forHijab: false,
    ),
    ChecklistItem(
      id: 'teller_grooming_r_k_1',
      question:
          'Wanita: Rambut diikat/disanggul rapi dengan jaring rambut/hairnet warna hitam/sesuai warna rambut',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Korporat/Batik',
      forHijab: false,
    ),
    ChecklistItem(
      id: 'teller_grooming_r_k_2',
      question:
          'Pria: Rambut pendek rapi, tidak menyentuh kerah baju dan daun telinga',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Korporat/Batik',
      forHijab: false,
    ),

    // GROOMING - Jilbab
    ChecklistItem(
      id: 'teller_grooming_j_1',
      question:
          'Jilbab dikenakan dengan rapi, tidak terlihat rambut atau leher',
      category: 'Grooming',
      subcategory: 'Jilbab',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'teller_grooming_j_2',
      question: 'Jilbab berwarna senada/sesuai dengan seragam',
      category: 'Grooming',
      subcategory: 'Jilbab',
      forHijab: true,
    ),

    // GROOMING - Pakaian
    ChecklistItem(
      id: 'teller_grooming_p_k_1',
      question:
          'Menggunakan seragam korporat sesuai ketentuan pada hari Senin-Rabu',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Korporat',
    ),
    ChecklistItem(
      id: 'teller_grooming_p_k_2',
      question: 'Seragam bersih, rapi dan tidak kusut',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Korporat',
    ),
    ChecklistItem(
      id: 'teller_grooming_p_b_1',
      question: 'Menggunakan seragam batik sesuai ketentuan pada hari Kamis',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Batik',
    ),
    ChecklistItem(
      id: 'teller_grooming_p_c_1',
      question: 'Menggunakan pakaian casual sesuai ketentuan pada hari Jumat',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Casual',
    ),

    // GROOMING - Atribut & Aksesoris
    ChecklistItem(
      id: 'teller_grooming_a_1',
      question: 'Menggunakan name tag secara benar dan terlihat jelas',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
    ),
    ChecklistItem(
      id: 'teller_grooming_a_2',
      question:
          'Wanita: Menggunakan aksesoris yang tidak berlebihan dan minimalis',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'teller_grooming_a_3',
      question:
          'Pria: Tidak menggunakan aksesoris selain cincin kawin dan jam tangan',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
      forHijab: false,
    ),

    // SIGAP
    ChecklistItem(
      id: 'teller_sigap_1',
      question: 'Teller segera menyambut nasabah saat tiba di counter',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'teller_sigap_2',
      question: 'Teller responsif terhadap kebutuhan nasabah',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'teller_sigap_3',
      question: 'Teller menangani transaksi dengan cepat tanpa menunda',
      category: 'Sigap',
    ),

    // MUDAH
    ChecklistItem(
      id: 'teller_mudah_1',
      question: 'Teller memberikan informasi dengan bahasa yang mudah dipahami',
      category: 'Mudah',
    ),
    ChecklistItem(
      id: 'teller_mudah_2',
      question: 'Teller menjelaskan langkah-langkah transaksi dengan jelas',
      category: 'Mudah',
    ),
    ChecklistItem(
      id: 'teller_mudah_3',
      question: 'Teller menyederhanakan proses yang rumit bagi nasabah',
      category: 'Mudah',
    ),

    // AKURAT
    ChecklistItem(
      id: 'teller_akurat_1',
      question: 'Teller menghitung uang dengan tepat dan teliti',
      category: 'Akurat',
    ),
    ChecklistItem(
      id: 'teller_akurat_2',
      question: 'Teller mengkonfirmasi jumlah transaksi kepada nasabah',
      category: 'Akurat',
    ),
    ChecklistItem(
      id: 'teller_akurat_3',
      question:
          'Teller memastikan data transaksi sesuai dengan permintaan nasabah',
      category: 'Akurat',
    ),

    // RAMAH
    ChecklistItem(
      id: 'teller_ramah_1',
      question: 'Teller menyambut nasabah dengan senyum dan salam',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'teller_ramah_2',
      question: 'Teller berkomunikasi dengan nada suara yang ramah dan santun',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'teller_ramah_3',
      question: 'Teller mengucapkan terima kasih di akhir layanan',
      category: 'Ramah',
    ),

    // TERAMPIL
    ChecklistItem(
      id: 'teller_terampil_1',
      question: 'Teller menguasai penggunaan sistem dengan baik',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'teller_terampil_2',
      question: 'Teller mampu menangani masalah transaksi dengan tepat',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'teller_terampil_3',
      question: 'Area kerja teller tertata rapi dan bersih',
      category: 'Terampil',
    ),
  ];
}
