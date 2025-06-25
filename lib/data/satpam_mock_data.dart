import 'package:bri_cek/models/checklist_item.dart';

// Mock data for Satpam with similar structure
// This is a template - replace with Firestore data when ready

List<ChecklistItem> getSatpamMockData() {
  return [
    // GROOMING - Similar structure to CS and Teller
    ChecklistItem(
      id: 'satpam_grooming_wb_1',
      question: 'Wajah bersih dan terlihat segar',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
    ),
    ChecklistItem(
      id: 'satpam_grooming_wb_2',
      question:
          'Tidak berbau badan dan menggunakan parfum yang tidak menyengat',
      category: 'Grooming',
      subcategory: 'Wajah & Badan',
    ),
    ChecklistItem(
      id: 'satpam_grooming_r_1',
      question: 'Rambut rapi dan dipotong sesuai standar',
      category: 'Grooming',
      subcategory: 'Rambut',
    ),
    ChecklistItem(
      id: 'satpam_grooming_p_1',
      question: 'Menggunakan seragam satpam lengkap dan rapi',
      category: 'Grooming',
      subcategory: 'Pakaian',
    ),
    ChecklistItem(
      id: 'satpam_grooming_a_1',
      question: 'Menggunakan topi dan atribut satpam dengan benar',
      category: 'Grooming',
      subcategory: 'Atribut & Aksesoris',
    ),

    // SIGAP
    ChecklistItem(
      id: 'satpam_sigap_1',
      question: 'Satpam berdiri dengan postur tegak dan sigap',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'satpam_sigap_2',
      question: 'Satpam responsif terhadap situasi sekitar',
      category: 'Sigap',
    ),
    ChecklistItem(
      id: 'satpam_sigap_3',
      question: 'Satpam cepat membantu nasabah yang membutuhkan',
      category: 'Sigap',
    ),

    // MUDAH
    ChecklistItem(
      id: 'satpam_mudah_1',
      question: 'Satpam memberikan petunjuk yang mudah dipahami',
      category: 'Mudah',
    ),
    ChecklistItem(
      id: 'satpam_mudah_2',
      question: 'Satpam membantu nasabah dengan cara yang sederhana',
      category: 'Mudah',
    ),

    // AKURAT
    ChecklistItem(
      id: 'satpam_akurat_1',
      question: 'Satpam memberikan informasi yang akurat kepada nasabah',
      category: 'Akurat',
    ),
    ChecklistItem(
      id: 'satpam_akurat_2',
      question: 'Satpam mengarahkan nasabah ke tempat yang tepat',
      category: 'Akurat',
    ),

    // RAMAH
    ChecklistItem(
      id: 'satpam_ramah_1',
      question: 'Satpam memberi salam dan menyapa nasabah',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'satpam_ramah_2',
      question: 'Satpam membantu membukakan pintu untuk nasabah',
      category: 'Ramah',
    ),
    ChecklistItem(
      id: 'satpam_ramah_3',
      question: 'Satpam menggunakan bahasa yang sopan dan ramah',
      category: 'Ramah',
    ),

    // TERAMPIL
    ChecklistItem(
      id: 'satpam_terampil_1',
      question: 'Satpam dapat menjawab pertanyaan dasar nasabah',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'satpam_terampil_2',
      question: 'Satpam terlihat waspada dan mengawasi area sekitar',
      category: 'Terampil',
    ),
    ChecklistItem(
      id: 'satpam_terampil_3',
      question: 'Satpam menguasai prosedur keamanan dengan baik',
      category: 'Terampil',
    ),
  ];
}
