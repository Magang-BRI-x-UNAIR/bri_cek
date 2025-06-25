import 'package:bri_cek/models/checklist_item.dart';

// Mock data for Customer Service based on CSV format
// This is a template - replace with Firestore data when ready

List<ChecklistItem> getCustomerServiceMockData() {
  return [
    // GROOMING - Wajah & Badan
    ChecklistItem(
      id: 'cs_grooming_wb_1',
      question:
          'wajah & badan terlihat bersih, segar & wangi (soft) dan secara berkala melakukan touch-up agar tetap terlihat segar dan bersih.',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
      forHijab: true, // For women
    ),
    ChecklistItem(
      id: 'cs_grooming_wb_2',
      question:
          'wajah menggunakan make-up elegan dengan warna natural. Make-up yang digunakan seperti foundation, bedak, lipstick, blush-on, pensil alis, eye-liner, eye-shadow, dsb.',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
      forHijab: true, // For women
    ),
    ChecklistItem(
      id: 'cs_grooming_wb_3',
      question: 'kuku bersih, tidak panjang dan tidak dicat berwarna',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
    ),

    // GROOMING - Rambut
    ChecklistItem(
      id: 'cs_grooming_r_1',
      question:
          'Rambut harus tertata harus rapi, warna rambut harus terlihat alami (hitam/cokelat tua) dan tidak diperkenankan warna highlight/ombre, mencolok seperti cokelat terang, merah, blonde, neon, dsb.',
      category: 'Grooming',
      subcategory: 'Rambut',
    ),
    ChecklistItem(
      id: 'cs_grooming_r_2',
      question:
          'tidak diperkenankan menggunakan aksesoris rambut warna-warni/ ikat rambut karet/ jedai',
      category: 'Grooming',
      subcategory: 'Rambut',
    ),
    ChecklistItem(
      id: 'cs_grooming_r_k_1',
      question:
          'rambut yang menyentuh bahu harus dicepol & poni dijepit dengan penjepit bobby pin warna hitam',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Korporat/Batik',
    ),
    ChecklistItem(
      id: 'cs_grooming_r_c_1',
      question:
          'rambut diperkenankan dicepol/ digerai rapi & poni yang menghalangi mata di jepit menggunakan bobby pin',
      category: 'Grooming',
      subcategory: 'Rambut',
      uniformType: 'Casual',
    ),

    // GROOMING - Jilbab
    ChecklistItem(
      id: 'cs_grooming_j_1',
      question: 'jilbab harus terlihat rapi, tidak kusut',
      category: 'Grooming',
      subcategory: 'Jilbab',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'cs_grooming_j_2',
      question: 'jilbab tidak diperkenankan berbahan kaos, spandex, bergo',
      category: 'Grooming',
      subcategory: 'Jilbab',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'cs_grooming_j_3',
      question:
          'jilbab tidak diperkenakan model bertumpuk/ berlapis, kunciran jilbab tinggi punuk onta dan tidak diperkenakan menggunakan aksesoris jilbab',
      category: 'Grooming',
      subcategory: 'Jilbab',
      forHijab: true,
    ),

    // GROOMING - Pakaian
    ChecklistItem(
      id: 'cs_grooming_p_1',
      question:
          'atasan dan bawahan ukuran fit-body, tidak terlalu ketat/ longgar',
      category: 'Grooming',
      subcategory: 'Pakaian',
    ),
    ChecklistItem(
      id: 'cs_grooming_p_k_1',
      question:
          'atasan blazer biru list batik dengan desain seragam sesuai ketentuan',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Korporat',
    ),
    ChecklistItem(
      id: 'cs_grooming_p_k_2',
      question:
          'atasan panjang lengan (non-hijab 3/4, hijab maks. pergelangan tangan) dan panjang seragam (maks. setengah paha)',
      category: 'Grooming',
      subcategory: 'Pakaian',
      uniformType: 'Korporat',
    ),

    // GROOMING - Atribut & Aksesoris
    ChecklistItem(
      id: 'cs_grooming_a_1',
      question:
          'memakai KTPP dengan card holder bebahan transparan. KTPP tidak lusuh, terlihat jelas, dijaga agar tidak terbalik dan hanya diperkenankan untuk digunakan dengan cara dijepit disaku sebelah kiri',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
    ),
    ChecklistItem(
      id: 'cs_grooming_a_2',
      question:
          'aksesoris wanita hanya diperkenankan 4 titik (kecuali kacamata) maksimal 1 kalung, 1 gelang, 2 cincin di tangan yang sama/ berbeda dan tidak menumpuk di satu jari.',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
      forHijab: true,
    ),
    ChecklistItem(
      id: 'cs_grooming_a_3',
      question:
          'aksesoris pria hanya diperkenankan 2 titik (kecuali kacamata) yaitu 1 cincin & 1 jam tangan',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
      forHijab: false,
    ),

    // GROOMING - Sepatu
    ChecklistItem(
      id: 'cs_grooming_s_1',
      question: 'sepatu disemir atau dibersihkan agar terlihat rapi',
      category: 'Grooming',
      subcategory: 'Sepatu',
    ),
    ChecklistItem(
      id: 'cs_grooming_s_k_1',
      question: 'sepatu pantopel kulit/sintesis warna hitam polos',
      category: 'Grooming',
      subcategory: 'Sepatu',
      uniformType: 'Korporat',
    ),

    // GROOMING - Male Specific Items
    ChecklistItem(
      id: 'cs_grooming_wb_m_1',
      question:
          'wajah tidak diperkenankan berjenggot, berkumis, berjambang & alis dikerik',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
      forHijab: false, // For men
    ),
    ChecklistItem(
      id: 'cs_grooming_wb_m_2',
      question:
          'wajah dan badan terlihat segar & bersih - seperti menggunakan pembersih muka, moisturizer, deodorant, perfume wangi soft, dsb.',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
      forHijab: false, // For men
    ),

    // SIGAP
    ChecklistItem(
      id: 'cs_sigap_1',
      question: 'Berdiri menyambut Nasabah',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'cs_sigap_2',
      question:
          'langsung memanggil Nasabah berikutnya setelah selesai melayani Nasabah (tidak menunda memanggil Nasabah berikutnya)',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'cs_sigap_3',
      question:
          'Bertanya keperluan nasabah dan memproses transaksi nasabah dengan segera tanpa menunda',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'cs_sigap_4',
      question:
          'melakukan interupsi maksimal 2 kali, dengan memohon ijin dan menginformasikan kepada nasabah atas interupsi yang perlu dilakukan (interupsi dilakukan untuk kepentingan transaksi nasabah)',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'cs_sigap_5',
      question:
          'tidak melakukan kegiatan yang tidak berhubungan dengan kebutuhan transaksi (seperti mengobrol dan menggunakan handphone)',
      category: 'Sigap',
    ),

    // MUDAH
    ChecklistItem(
      id: 'cs_mudah_1',
      question:
          'CS memandu Nasabah melakukan pengisian form dengan benar apabila terdapat form yang harus diisi',
      category: 'Mudah',
    ),
    ChecklistItem(
      id: 'cs_mudah_2',
      question:
          'CS membantu Nasabah menyelesaikan kebutuhan/permasalahannya dengan benar dan penjelasan yang mudah dipahami, serta tidak mempersulit nasabah',
      category: 'Mudah',
    ),
    ChecklistItem(
      id: 'cs_mudah_3',
      question:
          'CS melakukan edukasi untuk menggunakan e- channel agar Nasabah kedepannya dapat bertransaksi dengan mudah',
      category: 'Mudah',
    ),

    // AKURAT
    ChecklistItem(
      id: 'cs_akurat_1',
      question:
          'CS memastikan identitas nasabah yang tertera pada sistem dengan dokumen yang dibawa Nasabah',
      category: 'Akurat',
    ),
    ChecklistItem(
      id: 'cs_akurat_2',
      question:
          'CS memastikan dan mengkonfirmasi status pendaftaran e-banking Nasabah',
      category: 'Akurat',
    ),
    ChecklistItem(
      id: 'cs_akurat_3',
      question:
          'CS memastikan, mengkonfirmasi, dan memberikan solusi yang tepat terhadap permasalahan Nasabah',
      category: 'Akurat',
    ),
    ChecklistItem(
      id: 'cs_akurat_4',
      question: 'CS menjelaskan produk yang dibutuhkan Nasabah dengan tepat',
      category: 'Akurat',
    ),

    // RAMAH
    ChecklistItem(
      id: 'cs_ramah_1',
      question:
          'CS melakukan greeting 3 S (senyum, sapa, salam) dengan ramah dan antusias',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_2',
      question: 'CS melakukan gesture namaste',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_3',
      question: 'CS memperkenalkan diri',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_4',
      question: 'CS menanyakan nama Nasabah',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_5',
      question: 'CS mempersilahkan Nasabah duduk',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_6',
      question:
          'CS menggunakan sapaan Pak/Bu/Mas/Mbak kepada nasabah dengan sopan dan menyebutkan nama nasabah ketika melayani (minimal 3 kali (greeting awal, saat pelayanan, dan greeting akhir))',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_7',
      question:
          'CS fokus melayani Nasabah yang sedang dilayani, tidak melayani transaksi Nasabah lain',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_8',
      question:
          'CS menujukkan kontak mata dan gesture yang antusias selama melayani',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_9',
      question:
          'CS menyampaikan kalimat empati atas permasalahan / komplain yang disampaikan Nasabah',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_10',
      question:
          'CS menyampaikan kalimat small talk / customer intimacy untuk menambah keakraban dengan Nasabah',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_11',
      question: 'CS menawarkan bantuan akhir',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_12',
      question: 'CS berdiri ketika mengakhiri layanan',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'cs_ramah_13',
      question: 'CS mengucapkan terima kasih saat mengakhiri layanan',
      category: 'Ramah',
    ),

    // TERAMPIL
    ChecklistItem(
      id: 'cs_terampil_1',
      question:
          'CS mengakses WISE untuk meningkatkan pemahaman dan mempermudah penawaran produk dan layanan ke nasabah',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_2',
      question:
          'CS melakukan tindakan KYC (Know Your Customer) setiap melayani nasabah yaitu melakukan verifikasi data nasabah',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_3',
      question:
          'CS melakukan penggalian informasi dan pengecekan pada sistem (Bricare) atas pengaduan nasabah',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_4',
      question:
          'CS melakukan pengkinian data apabila ada yang berubah (data pribadi nasabah, nama gadis ibu kandung, nomer telepon, alamat, email)',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_5',
      question:
          'CS dapat menjelaskan keunggulan produk dan prosedur penggunaan e-channel/e-banking',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_6',
      question:
          'CS menjelaskan / meminta nasabah untuk membaca poin-poin disclaimer saat melakukan pembukaan rekening',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_7',
      question:
          'CS aktif mendengarkan keluhan/kebutuhan nasabah (active listening)',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_8',
      question: 'CS melakukan konfirmasi atas keluhan / kebutuhan nasabah',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_9',
      question:
          'CS menyampaikan permohonan maaf apabila nasabah menyampaikan komplain / permasalahan yang dialami',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_10',
      question: 'CS mampu menjelaskan penyebab permasalahan / keluhan nasabah',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_11',
      question:
          'CS mampu menjadi problem solver atas permasalahan nasabah dengan tuntas dan menjadi financial advisor atas kebutuhan keuangan nasabah',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_12',
      question:
          'CS melakukan tindakan service recovery untuk memperbaiki kekecewaan nasabah yang komplain secara berulang',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_13',
      question: 'CS melakukan cross selling sesuai customer profile / needs',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'cs_terampil_14',
      question:
          'CS mengedukasi keamanan bertransaksi (kerahasiaan PIN, token, skimming, dll) dan migrasi menggunakan e-channel / e-banking BRI sehingga nasabah tidak perlu datang ke UKO',
      category: 'Terampil',
    ),
  ];
}
