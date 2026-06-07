import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import 'widgets/add_category_dialog.dart';
import 'widgets/admin_drawer.dart';

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
      if (!mounted) return;
      setState(() => _categories = data);
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed to load categories: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete(CategoryModel category) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '${category.catName}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCategory(category);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    try {
      final hasProducts = await _service.categoryHasProducts(category.catId);
      if (!mounted) return;

      if (hasProducts) {
        _showMessage(
          "This category has products. Move or delete those products first.",
        );
        return;
      }

      await _service.deleteCategory(category.catId);
      if (!mounted) return;
      _showMessage("Category deleted successfully");
      _loadCategories();
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed to delete category: $e");
    }
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AddCategoryDialog(),
    );
    if (result == true) _loadCategories();
  }

  Future<void> _showEditDialog(CategoryModel category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddCategoryDialog(category: category),
    );
    if (result == true) _loadCategories();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                      horizontal: 16,
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
                        _CategoryThumbnail(category: category),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            category.catName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(category);
                            } else if (value == 'delete') {
                              _confirmDelete(category);
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
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class _CategoryThumbnail extends StatelessWidget {
  final CategoryModel category;

  const _CategoryThumbnail({required this.category});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    final imageUrl = category.catImage.trim();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF2),
        shape: BoxShape.circle,
        border: Border.all(color: goldColor.withValues(alpha: 0.42)),
      ),
      child: ClipOval(
        child: imageUrl.isEmpty
            ? const Icon(Icons.spa_outlined, color: goldColor, size: 24)
            : Image.network(
                imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.spa_outlined,
                    color: goldColor,
                    size: 24,
                  );
                },
              ),
      ),
    );
  }
}
