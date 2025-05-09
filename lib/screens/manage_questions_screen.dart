import 'package:flutter/material.dart';
import 'package:bri_cek/data/checklist_item_data.dart';
import 'package:bri_cek/models/checklist_item.dart';
import 'package:bri_cek/utils/app_size.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  String _selectedCategory = 'Satpam'; // Default category
  List<ChecklistItem> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  bool _isAddingQuestion = false;

  final List<String> categories = [
    'Satpam',
    'Teller',
    'Customer Service',
    'Banking Hall',
    'Gallery e-Channel',
    'Fasad Gedung',
    'Ruang BRIMEN',
    'Toilet',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    setState(() {
      _questions = getChecklistForCategory(_selectedCategory);
    });
  }

  void _addQuestion() {
    if (_questionController.text.isNotEmpty) {
      setState(() {
        _questions.add(
          ChecklistItem(
            id: '${_selectedCategory.toLowerCase()}_${_questions.length + 1}',
            question: _questionController.text,
          ),
        );
        _questionController.clear();
        _isAddingQuestion = false;
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pertanyaan berhasil ditambahkan'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _editQuestion(int index, String newQuestion) {
    setState(() {
      _questions[index] = ChecklistItem(
        id: _questions[index].id,
        question: newQuestion,
      );
    });
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pertanyaan berhasil diubah'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteQuestion(int index) {
    final deletedQuestion = _questions[index].question;
    setState(() {
      _questions.removeAt(index);
    });
    // Show success message with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pertanyaan dihapus'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _questions.insert(
                index,
                ChecklistItem(
                  id: '${_selectedCategory.toLowerCase()}_${index}',
                  question: deletedQuestion,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pertanyaan'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category selection header
          Container(
            color: Colors.blue.shade700,
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.paddingHorizontal,
              vertical: AppSize.heightPercent(2),
            ),
            child: Container(
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
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: Icon(
                    Icons.arrow_drop_down_circle,
                    color: Colors.blue.shade700,
                  ),
                  items:
                      categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                        _loadQuestions();
                        _isAddingQuestion = false;
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          // Question counter
          Padding(
            padding: EdgeInsets.all(AppSize.paddingHorizontal),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _isAddingQuestion = true;
                      _questionController.clear();
                    });
                  },
                ),
              ],
            ),
          ),

          // Add question form (conditionally visible)
          if (_isAddingQuestion)
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppSize.paddingHorizontal,
                vertical: AppSize.heightPercent(1),
              ),
              padding: EdgeInsets.all(AppSize.paddingHorizontal),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Pertanyaan Baru',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: AppSize.heightPercent(1)),
                  TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pertanyaan...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade200),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: AppSize.heightPercent(1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isAddingQuestion = false;
                          });
                        },
                        child: Text('Batal'),
                      ),
                      SizedBox(width: AppSize.widthPercent(2)),
                      ElevatedButton(
                        onPressed: _addQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                        child: Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // List of questions
          Expanded(
            child:
                _questions.isEmpty
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
                                                    index,
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
                                                  _deleteQuestion(index);
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
}
