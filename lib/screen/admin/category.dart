import 'package:flutter/material.dart';
import '../../../services/category_service.dart';
import '../../../models/category_model.dart';
import 'widgets/admin_drawer.dart';
import 'widgets/add_category_dialog.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const Color _backgroundColor = Color(0xFFFFFCF2);
  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _textColor = Color(0xFF4B3128);

  final CategoryService _service = CategoryService();
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getCategories();
      setState(() => _categories = data);
    } catch (e) {
      debugPrint("Error loading: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Delete လုပ်တဲ့အခါ အတည်ပြုချက်တောင်းဖို့
  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '$name'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.deleteCategory(id);
              _loadCategories();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: const AdminDrawer(activeTitle: "Category"),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textColor,
        title: const Text(
          "Category",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _goldColor))
          : RefreshIndicator(
              color: _goldColor,
              onRefresh: _loadCategories,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.catName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // အစက် ၃ စက် Menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') {
                              // Edit Dialog ခေါ်မယ် (Edit အတွက် Dialog logic ကို အောက်မှာ ပြထားပါတယ်)
                              _showEditDialog(category);
                            } else if (value == 'delete') {
                              _confirmDelete(category.catId, category.catName);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text("Edit"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _goldColor,
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (_) => const AddCategoryDialog(),
          );
          if (result == true) _loadCategories();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Edit အတွက် Dialog
  void _showEditDialog(CategoryModel category) {
    TextEditingController editController = TextEditingController(
      text: category.catName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Category"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editController.text.isNotEmpty) {
                await _service.updateCategory(
                  category.catId,
                  editController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadCategories();
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
