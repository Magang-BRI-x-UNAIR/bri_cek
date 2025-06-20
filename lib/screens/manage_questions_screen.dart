import 'package:flutter/material.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/models/category.dart';
import 'package:bri_cek/services/question_service.dart';
import 'package:bri_cek/utils/app_size.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  // Service
  final QuestionService _questionService = QuestionService();

  String _getNameById(List<Category> items, String id) {
    final category = items.firstWhere(
      (item) => item.id == id,
      orElse: () => Category(id: '', name: 'Tidak ditemukan'),
    );
    return category.name;
  }

  // Question data
  List<ChecklistItem> _questions = [];
  final TextEditingController _questionController = TextEditingController();

  // UI state
  bool _isAddingQuestion = false;
  bool _isLoading = false;

  // Selected categories at each level
  String? _selectedMainCategory;
  String? _selectedSubcategory;
  String? _selectedGender;
  String? _selectedSection;
  String? _selectedUniformType;

  // Available options at each level
  List<Category> _mainCategories = [];
  List<Category> _subcategories = [];
  List<Category> _genderOptions = [];
  List<Category> _sections = [];
  List<Category> _uniformTypes = [];

  @override
  void initState() {
    super.initState();
    _loadMainCategories();
  }

  // Method untuk inisialisasi data
  // Method untuk inisialisasi data
  Future<void> _initializeDatabase() async {
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.apartment),
                title: Text('Fasad Gedung'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    await _questionService
                        .initializeSatpamPakaianWanitaQuestions();
                    _showSuccessSnackbar(
                      'Data Fasad Gedung berhasil diinisialisasi',
                    );
                    _loadMainCategories();
                  } catch (e) {
                    _showErrorSnackbar(
                      'Gagal menginisialisasi Fasad Gedung: $e',
                    );
                  }
                  setState(() => _isLoading = false);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _isLoading = false);
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Load kategori utama
  Future<void> _loadMainCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print("Loading main categories...");
      final categories = await _questionService.getMainCategories();
      print("Loaded ${categories.length} categories");

      setState(() {
        _mainCategories = categories;
        if (categories.isNotEmpty) {
          _selectedMainCategory = categories.first.id;
          _loadSubcategories();
        }
      });
    } catch (e) {
      print("Error loading categories: $e");
      _showErrorSnackbar('Gagal memuat kategori: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load subkategori
  Future<void> _loadSubcategories() async {
    if (_selectedMainCategory == null) return;

    setState(() {
      _isLoading = true;
      _selectedSubcategory = null;
      _selectedGender = null;
      _selectedSection = null;
      _selectedUniformType = null;
      _subcategories = [];
      _genderOptions = [];
      _sections = [];
      _uniformTypes = [];
    });

    try {
      print("Loading subcategories for $_selectedMainCategory");
      final subcategories = await _questionService.getSubcategories(
        _selectedMainCategory!,
      );
      print("Loaded ${subcategories.length} subcategories");

      setState(() {
        _subcategories = subcategories;
        if (subcategories.isNotEmpty) {
          _selectedSubcategory = subcategories.first.id;
          _loadGenderOptions();
        }
      });
    } catch (e) {
      print("Error loading subcategories: $e");
      _showErrorSnackbar('Gagal memuat subkategori: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load opsi gender
  Future<void> _loadGenderOptions() async {
    if (_selectedMainCategory == null || _selectedSubcategory == null) return;

    setState(() {
      _isLoading = true;
      _selectedGender = null;
      _selectedSection = null;
      _selectedUniformType = null;
      _genderOptions = [];
      _sections = [];
      _uniformTypes = [];
    });

    try {
      print(
        "Loading gender options for $_selectedMainCategory/$_selectedSubcategory",
      );
      final genders = await _questionService.getGenderCategories(
        _selectedMainCategory!,
        _selectedSubcategory!,
      );
      print("Loaded ${genders.length} gender options");

      setState(() {
        _genderOptions = genders;
        if (genders.isNotEmpty) {
          _selectedGender = genders.first.id;
          _loadSections();
        } else {
          // If no gender options, load questions directly for the subcategory
          _loadQuestions();
        }
      });
    } catch (e) {
      print("Error loading gender options: $e");
      _showErrorSnackbar('Gagal memuat opsi gender: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load bagian
  Future<void> _loadSections() async {
    if (_selectedMainCategory == null ||
        _selectedSubcategory == null ||
        _selectedGender == null)
      return;

    setState(() {
      _isLoading = true;
      _selectedSection = null;
      _selectedUniformType = null;
      _sections = [];
      _uniformTypes = [];
    });

    try {
      print(
        "Loading sections for $_selectedMainCategory/$_selectedSubcategory/$_selectedGender",
      );
      final sections = await _questionService.getSections(
        _selectedMainCategory!,
        _selectedSubcategory!,
        _selectedGender!,
      );
      print("Loaded ${sections.length} sections");

      setState(() {
        _sections = sections;
        if (sections.isNotEmpty) {
          _selectedSection = sections.first.id;
          _loadUniformTypes();
        } else {
          // If no sections, load questions for the gender
          _loadQuestions();
        }
      });
    } catch (e) {
      print("Error loading sections: $e");
      _showErrorSnackbar('Gagal memuat bagian: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load tipe seragam
  Future<void> _loadUniformTypes() async {
    if (_selectedMainCategory == null ||
        _selectedSubcategory == null ||
        _selectedGender == null ||
        _selectedSection == null)
      return;

    setState(() {
      _isLoading = true;
      _selectedUniformType = null;
      _uniformTypes = [];
    });

    try {
      print(
        "Loading uniform types for $_selectedMainCategory/$_selectedSubcategory/$_selectedGender/$_selectedSection",
      );
      final uniformTypes = await _questionService.getUniformTypes(
        _selectedMainCategory!,
        _selectedSubcategory!,
        _selectedGender!,
        _selectedSection!,
      );
      print("Loaded ${uniformTypes.length} uniform types");

      setState(() {
        _uniformTypes = uniformTypes;
        if (uniformTypes.isNotEmpty) {
          _selectedUniformType = uniformTypes.first.id;
        }
        // Always load questions after setting uniform type (or if none)
        _loadQuestions();
      });
    } catch (e) {
      print("Error loading uniform types: $e");
      _showErrorSnackbar('Gagal memuat tipe seragam: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Menampilkan dialog tambah pertanyaan
  void _showAddQuestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tambah Pertanyaan Baru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori yang sudah dipilih
                        _buildSelectedCategoryInfo(),
                        SizedBox(height: 16),

                        // Formulir pilihan hierarki kategori
                        _buildCategoryHierarchyForm(),
                        SizedBox(height: 16),

                        // Input teks pertanyaan
                        Text(
                          'Pertanyaan:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan pertanyaan...',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      child: Text('Batal'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                      ),
                      child: Text('Simpan'),
                      onPressed: () {
                        Navigator.pop(context);
                        _addQuestion();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget untuk informasi kategori yang dipilih
  Widget _buildSelectedCategoryInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: Colors.blue.shade700),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kategori: ${_getNameById(_mainCategories, _selectedMainCategory ?? "")}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk formulir hierarki kategori
  Widget _buildCategoryHierarchyForm() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subkategori
            Text(
              'Pilih Subkategori:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            _buildDropdown(
              value: _selectedSubcategory,
              items: _subcategories,
              hint: "Pilih Subkategori",
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSubcategory = value;
                    _selectedGender = null;
                    _selectedSection = null;
                    _selectedUniformType = null;
                  });
                  _loadGenderOptions();
                  setDialogState(() {});
                }
              },
            ),

            // Gender (jika tersedia)
            if (_genderOptions.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Pilih Gender:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              _buildDropdown(
                value: _selectedGender,
                items: _genderOptions,
                hint: "Pilih Gender",
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                      _selectedSection = null;
                      _selectedUniformType = null;
                    });
                    _loadSections();
                    setDialogState(() {});
                  }
                },
              ),
            ],

            // Section (jika tersedia)
            if (_sections.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Pilih Section:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              _buildDropdown(
                value: _selectedSection,
                items: _sections,
                hint: "Pilih Section",
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSection = value;
                      _selectedUniformType = null;
                    });
                    _loadUniformTypes();
                    setDialogState(() {});
                  }
                },
              ),
            ],

            // Uniform Type (jika tersedia)
            if (_uniformTypes.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Pilih Tipe Uniform:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              _buildDropdown(
                value: _selectedUniformType,
                items: _uniformTypes,
                hint: "Pilih Tipe Uniform",
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUniformType = value;
                    });
                    setDialogState(() {});
                  }
                },
              ),
            ],
          ],
        );
      },
    );
  }

  // Load pertanyaan
  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _questions = [];
    });

    try {
      print(
        "Loading questions with path: $_selectedMainCategory/$_selectedSubcategory/$_selectedGender/$_selectedSection/$_selectedUniformType",
      );
      final questions = await _questionService.getQuestionsForPath(
        mainCategory: _selectedMainCategory!,
        subcategory: _selectedSubcategory,
        gender: _selectedGender,
        section: _selectedSection,
        uniformType: _selectedUniformType,
      );
      print("Loaded ${questions.length} questions");

      setState(() {
        _questions = questions;
      });
    } catch (e) {
      print("Error loading questions: $e");
      _showErrorSnackbar('Gagal memuat pertanyaan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tambah pertanyaan
  Future<void> _addQuestion() async {
    if (_questionController.text.isEmpty) {
      _showErrorSnackbar('Pertanyaan tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _questionService.addQuestion(
        mainCategory: _selectedMainCategory!,
        subcategory: _selectedSubcategory ?? "general",
        gender: _selectedGender,
        section: _selectedSection,
        uniformType: _selectedUniformType,
        questionText: _questionController.text,
      );

      _questionController.clear();
      // Tidak perlu mengubah _isAddingQuestion karena dialog otomatis tertutup

      _loadQuestions();
      _showSuccessSnackbar('Pertanyaan berhasil ditambahkan');
    } catch (e) {
      print("Error adding question: $e");
      _showErrorSnackbar('Gagal menambahkan pertanyaan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Edit pertanyaan
  Future<void> _editQuestion(String id, String newQuestionText) async {
    if (newQuestionText.isEmpty || _selectedMainCategory == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String path = _buildQuestionPath();
      print("Editing question $id in path $path");

      await _questionService.editQuestion(
        path: path,
        questionId: id,
        newText: newQuestionText,
      );

      _loadQuestions();
      _showSuccessSnackbar('Pertanyaan berhasil diubah', color: Colors.blue);
    } catch (e) {
      print("Error editing question: $e");
      _showErrorSnackbar('Gagal mengubah pertanyaan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hapus pertanyaan
  Future<void> _deleteQuestion(String id) async {
    if (_selectedMainCategory == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String path = _buildQuestionPath();
      print("Deleting question $id from path $path");

      await _questionService.deleteQuestion(path: path, questionId: id);

      _loadQuestions();
      _showSuccessSnackbar('Pertanyaan berhasil dihapus', color: Colors.red);
    } catch (e) {
      print("Error deleting question: $e");
      _showErrorSnackbar('Gagal menghapus pertanyaan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Build path ke koleksi questions
  String _buildQuestionPath() {
    String path = 'assessment_categories/${_selectedMainCategory!}';

    if (_selectedSubcategory != null) {
      path += '/subcategories/${_selectedSubcategory!}';

      if (_selectedGender != null) {
        path += '/gender_categories/${_selectedGender!}';

        if (_selectedSection != null) {
          path += '/sections/${_selectedSection!}';

          if (_selectedUniformType != null) {
            path += '/uniform_types/${_selectedUniformType!}';
          }
        }
      }
    }

    path += '/questions';
    return path;
  }

  // Tampilkan error message
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Tampilkan success message
  void _showSuccessSnackbar(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dapatkan display path untuk selection saat ini
  String _getDisplayPath() {
    List<String> pathParts = [];

    if (_selectedMainCategory != null) {
      final mainCategory = _mainCategories.firstWhere(
        (c) => c.id == _selectedMainCategory,
        orElse:
            () => Category(
              id: _selectedMainCategory!,
              name: _selectedMainCategory!,
            ),
      );
      pathParts.add(mainCategory.name);
    }

    if (_selectedSubcategory != null) {
      final subcategory = _subcategories.firstWhere(
        (c) => c.id == _selectedSubcategory,
        orElse:
            () => Category(
              id: _selectedSubcategory!,
              name: _selectedSubcategory!,
            ),
      );
      pathParts.add(subcategory.name);
    }

    if (_selectedGender != null) {
      final gender = _genderOptions.firstWhere(
        (c) => c.id == _selectedGender,
        orElse: () => Category(id: _selectedGender!, name: _selectedGender!),
      );
      pathParts.add(gender.name);
    }

    if (_selectedSection != null) {
      final section = _sections.firstWhere(
        (c) => c.id == _selectedSection,
        orElse: () => Category(id: _selectedSection!, name: _selectedSection!),
      );
      pathParts.add(section.name);
    }

    if (_selectedUniformType != null) {
      final uniformType = _uniformTypes.firstWhere(
        (c) => c.id == _selectedUniformType,
        orElse:
            () => Category(
              id: _selectedUniformType!,
              name: _selectedUniformType!,
            ),
      );
      pathParts.add(uniformType.name);
    }

    return pathParts.join(' → ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pertanyaan'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          // Tombol reset & fix database
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Reset Database',
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                });
                await _questionService.resetAndFixDatabase();
                _showSuccessSnackbar(
                  'Database berhasil direset dan diperbarui',
                );
                await _loadMainCategories();
              } catch (e) {
                _showErrorSnackbar('Gagal mereset database: $e');
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_applications),
            tooltip: 'Inisialisasi Database',
            onPressed: _initializeDatabase,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header pemilihan kategori
          Container(
            color: Colors.blue.shade700,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.paddingHorizontal,
              vertical: AppSize.heightPercent(2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main categories dropdown
                _buildDropdown(
                  value: _selectedMainCategory,
                  items: _mainCategories,
                  hint: "Pilih Kategori",
                  onChanged: (value) {
                    if (value != null) {
                      print("Selected main category: $value");
                      setState(() {
                        _selectedMainCategory = value;
                      });
                      _loadSubcategories();
                    }
                  },
                ),

                if (_subcategories.isNotEmpty)
                  SizedBox(height: AppSize.heightPercent(1)),

                // Subcategories dropdown (if available)
                if (_subcategories.isNotEmpty)
                  _buildDropdown(
                    value: _selectedSubcategory,
                    items: _subcategories,
                    hint: "Pilih Subkategori",
                    onChanged: (value) {
                      if (value != null) {
                        print("Selected subcategory: $value");
                        setState(() {
                          _selectedSubcategory = value;
                        });
                        _loadGenderOptions();
                      }
                    },
                  ),

                if (_genderOptions.isNotEmpty)
                  SizedBox(height: AppSize.heightPercent(1)),

                // Gender dropdown (if available)
                if (_genderOptions.isNotEmpty)
                  _buildDropdown(
                    value: _selectedGender,
                    items: _genderOptions,
                    hint: "Pilih Gender",
                    onChanged: (value) {
                      if (value != null) {
                        print("Selected gender: $value");
                        setState(() {
                          _selectedGender = value;
                        });
                        _loadSections();
                      }
                    },
                  ),

                if (_sections.isNotEmpty)
                  SizedBox(height: AppSize.heightPercent(1)),

                // Sections dropdown (if available)
                if (_sections.isNotEmpty)
                  _buildDropdown(
                    value: _selectedSection,
                    items: _sections,
                    hint: "Pilih Bagian",
                    onChanged: (value) {
                      if (value != null) {
                        print("Selected section: $value");
                        setState(() {
                          _selectedSection = value;
                        });
                        _loadUniformTypes();
                      }
                    },
                  ),

                if (_uniformTypes.isNotEmpty)
                  SizedBox(height: AppSize.heightPercent(1)),

                // Uniform types dropdown (if available)
                if (_uniformTypes.isNotEmpty)
                  _buildDropdown(
                    value: _selectedUniformType,
                    items: _uniformTypes,
                    hint: "Pilih Tipe Seragam",
                    onChanged: (value) {
                      if (value != null) {
                        print("Selected uniform type: $value");
                        setState(() {
                          _selectedUniformType = value;
                        });
                        _loadQuestions();
                      }
                    },
                  ),
              ],
            ),
          ),

          // Path lokasi saat ini
          Container(
            padding: EdgeInsets.all(AppSize.paddingHorizontal),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Text(
              _getDisplayPath(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),

          // Counter pertanyaan dan tombol tambah
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.paddingHorizontal,
              vertical: AppSize.heightPercent(1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_questions.length} Pertanyaan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('Tambah Pertanyaan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                  ),
                  onPressed:
                      _selectedMainCategory == null
                          ? null
                          : () =>
                              _showAddQuestionDialog(), // Panggil method dialog bukan setState
                ),
              ],
            ),
          ),

          // Form tambah pertanyaan (muncul kondisional)
          // if (_isAddingQuestion)
          //   Container(
          //     margin: EdgeInsets.symmetric(
          //       horizontal: AppSize.paddingHorizontal,
          //       vertical: AppSize.heightPercent(1),
          //     ),
          //     constraints: BoxConstraints(
          //       maxHeight:
          //           MediaQuery.of(context).size.height * 0.6, // Batasi tinggi
          //     ),
          //     decoration: BoxDecoration(
          //       color: Colors.blue.shade50,
          //       borderRadius: BorderRadius.circular(10),
          //       border: Border.all(color: Colors.blue.shade200),
          //     ),
          //     child: SingleChildScrollView(
          //       padding: EdgeInsets.all(AppSize.paddingHorizontal),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Tambah Pertanyaan Baru',
          //             style: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               fontSize: 18,
          //               color: Colors.blue.shade700,
          //             ),
          //           ),
          //           SizedBox(height: AppSize.heightPercent(1.5)),

          //           // Info kategori yang dipilih (read-only)
          //           Container(
          //             padding: EdgeInsets.all(8),
          //             decoration: BoxDecoration(
          //               color: Colors.blue.shade100,
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             child: Row(
          //               children: [
          //                 Icon(Icons.category, color: Colors.blue.shade700),
          //                 SizedBox(width: 8),
          //                 Expanded(
          //                   child: Text(
          //                     'Kategori: ${_getNameById(_mainCategories, _selectedMainCategory ?? "")}',
          //                     style: TextStyle(fontWeight: FontWeight.w500),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //           SizedBox(height: 15),

          //           // Pilih Subkategori
          //           Text(
          //             'Pilih Subkategori:',
          //             style: TextStyle(fontWeight: FontWeight.w500),
          //           ),
          //           SizedBox(height: 8),
          //           _buildDropdown(
          //             value: _selectedSubcategory,
          //             items: _subcategories,
          //             hint: "Pilih Subkategori",
          //             onChanged: (value) {
          //               if (value != null) {
          //                 setState(() {
          //                   _selectedSubcategory = value;
          //                   _selectedGender = null;
          //                   _selectedSection = null;
          //                   _selectedUniformType = null;
          //                 });
          //                 _loadGenderOptions();
          //               }
          //             },
          //           ),

          //           // Gender dropdown (jika tersedia)
          //           if (_genderOptions.isNotEmpty) ...[
          //             SizedBox(height: 15),
          //             Text(
          //               'Pilih Gender:',
          //               style: TextStyle(fontWeight: FontWeight.w500),
          //             ),
          //             SizedBox(height: 8),
          //             _buildDropdown(
          //               value: _selectedGender,
          //               items: _genderOptions,
          //               hint: "Pilih Gender",
          //               onChanged: (value) {
          //                 if (value != null) {
          //                   setState(() {
          //                     _selectedGender = value;
          //                     _selectedSection = null;
          //                     _selectedUniformType = null;
          //                   });
          //                   _loadSections();
          //                 }
          //               },
          //             ),
          //           ],

          //           // Section dropdown (jika tersedia)
          //           if (_sections.isNotEmpty) ...[
          //             SizedBox(height: 15),
          //             Text(
          //               'Pilih Section:',
          //               style: TextStyle(fontWeight: FontWeight.w500),
          //             ),
          //             SizedBox(height: 8),
          //             _buildDropdown(
          //               value: _selectedSection,
          //               items: _sections,
          //               hint: "Pilih Section",
          //               onChanged: (value) {
          //                 if (value != null) {
          //                   setState(() {
          //                     _selectedSection = value;
          //                     _selectedUniformType = null;
          //                   });
          //                   _loadUniformTypes();
          //                 }
          //               },
          //             ),
          //           ],

          //           // Uniform Type dropdown (jika tersedia)
          //           if (_uniformTypes.isNotEmpty) ...[
          //             SizedBox(height: 15),
          //             Text(
          //               'Pilih Tipe Uniform:',
          //               style: TextStyle(fontWeight: FontWeight.w500),
          //             ),
          //             SizedBox(height: 8),
          //             _buildDropdown(
          //               value: _selectedUniformType,
          //               items: _uniformTypes,
          //               hint: "Pilih Tipe Uniform",
          //               onChanged: (value) {
          //                 if (value != null) {
          //                   setState(() {
          //                     _selectedUniformType = value;
          //                   });
          //                 }
          //               },
          //             ),
          //           ],

          //           SizedBox(height: AppSize.heightPercent(1.5)),

          //           // Input pertanyaan
          //           Text(
          //             'Pertanyaan:',
          //             style: TextStyle(fontWeight: FontWeight.w500),
          //           ),
          //           SizedBox(height: 8),
          //           TextField(
          //             controller: _questionController,
          //             decoration: InputDecoration(
          //               hintText: 'Masukkan pertanyaan...',
          //               border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.circular(8),
          //               ),
          //               filled: true,
          //               fillColor: Colors.white,
          //             ),
          //             maxLines: 3,
          //           ),
          //           SizedBox(height: AppSize.heightPercent(1.5)),

          //           // Tombol aksi
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.end,
          //             children: [
          //               OutlinedButton(
          //                 onPressed: () {
          //                   setState(() {
          //                     _isAddingQuestion = false;
          //                   });
          //                 },
          //                 style: OutlinedButton.styleFrom(
          //                   padding: EdgeInsets.symmetric(
          //                     horizontal: 20,
          //                     vertical: 12,
          //                   ),
          //                   side: BorderSide(color: Colors.grey.shade400),
          //                 ),
          //                 child: Text('Batal'),
          //               ),
          //               SizedBox(width: 10),
          //               ElevatedButton(
          //                 onPressed: _addQuestion,
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: Colors.blue.shade700,
          //                   padding: EdgeInsets.symmetric(
          //                     horizontal: 20,
          //                     vertical: 12,
          //                   ),
          //                 ),
          //                 child: Text('Simpan'),
          //               ),
          //             ],
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),

          // List pertanyaan
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _questions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.question_answer_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: AppSize.heightPercent(2)),
                          Text(
                            'Belum ada pertanyaan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.all(AppSize.paddingHorizontal),
                      itemCount: _questions.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final question = _questions[index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSize.paddingHorizontal,
                              vertical: AppSize.heightPercent(0.5),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade700,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              question.question,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  tooltip: 'Edit Pertanyaan',
                                  onPressed: () {
                                    final TextEditingController editController =
                                        TextEditingController(
                                          text: question.question,
                                        );
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text(
                                              'Edit Pertanyaan',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            content: TextField(
                                              controller: editController,
                                              decoration: InputDecoration(
                                                labelText: 'Pertanyaan',
                                                border: OutlineInputBorder(),
                                              ),
                                              maxLines: 3,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _editQuestion(
                                                    question.id,
                                                    editController.text,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.blue.shade700,
                                                ),
                                                child: Text('Simpan'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Hapus Pertanyaan',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text('Konfirmasi'),
                                            content: Text(
                                              'Apakah Anda yakin ingin menghapus pertanyaan ini?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteQuestion(question.id);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk build dropdown
  Widget _buildDropdown({
    required String? value,
    required List<Category> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    // Make sure value exists in items
    bool valueExists =
        value == null ? true : items.any((item) => item.id == value);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.paddingHorizontal / 2,
        vertical: AppSize.heightPercent(0.5),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valueExists ? value : null,
          isExpanded: true,
          hint: Text(hint),
          icon: Icon(Icons.arrow_drop_down_circle, color: Colors.blue.shade700),
          items:
              items.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
