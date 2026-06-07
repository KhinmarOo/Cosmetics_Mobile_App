import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/category_model.dart';
import '../../../services/category_service.dart';

class AddCategoryDialog extends StatefulWidget {
  final CategoryModel? category;

  const AddCategoryDialog({super.key, this.category});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _bgColor = Color(0xFFFFFCF2);
  static const Color _darkTextColor = Color(0xFF2D1D15);

  final TextEditingController _controller = TextEditingController();
  final CategoryService _service = CategoryService();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _isLoading = false;

  bool get _isEditing => widget.category != null;
  String get _currentImageUrl => widget.category?.catImage ?? '';

  @override
  void initState() {
    super.initState();
    _controller.text = widget.category?.catName ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted || pickedFile == null) return;
    setState(() => _image = File(pickedFile.path));
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      _showMessage("Please enter category name");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var imageUrl = _currentImageUrl;
      if (_image != null) {
        imageUrl = await _service.uploadCategoryImage(_image!);
      }

      if (_isEditing) {
        await _service.updateCategory(
          widget.category!.catId,
          name,
          imageUrl: imageUrl,
        );
      } else {
        await _service.addCategory(name, imageUrl: imageUrl);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed to save category: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        _isEditing ? "Edit Category" : "Add Category",
        style: const TextStyle(
          color: _darkTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: "Enter category name",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.category_outlined),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _goldColor.withValues(alpha: 0.35),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _goldColor, width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Category Image",
              style: TextStyle(
                color: _darkTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isLoading ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 132,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _goldColor.withValues(alpha: 0.32)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: _buildImagePreview(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: _darkTextColor)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _goldColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_isEditing ? "Update" : "Save"),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_image != null) {
      return Image.file(_image!, width: double.infinity, fit: BoxFit.cover);
    }

    if (_currentImageUrl.isNotEmpty) {
      return Image.network(
        _currentImageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined, color: _goldColor, size: 32),
          SizedBox(height: 6),
          Text(
            "Select Image",
            style: TextStyle(
              color: _darkTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
