import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  File? _image;
  final picker = ImagePicker();
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  bool _isCategoryLoading = true;
  bool _isSaving = false;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoryLoading = true;
      _categoryError = null;
    });

    try {
      final categories = await _categoryService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isCategoryLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoryError = e.toString();
        _isCategoryLoading = false;
      });
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    setState(() {
      if (pickedFile != null) _image = File(pickedFile.path);
    });
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim().replaceAll(',', '');
    final quantityText = _quantityController.text.trim();
    final description = _descriptionController.text.trim();
    final price = int.tryParse(priceText);
    final quantity = int.tryParse(quantityText);

    if (name.isEmpty) {
      _showMessage("Please input product name");
      return;
    }
    if (price == null || price <= 0) {
      _showMessage("Please input a valid price");
      return;
    }
    if (_selectedCategoryId == null) {
      _showMessage("Please select product category");
      return;
    }
    if (quantity == null || quantity < 0) {
      _showMessage("Please input a valid quantity");
      return;
    }
    if (_image == null) {
      _showMessage("Please select product image");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final imageUrl = await _uploadProductImage(_image!);

      await _productService.addProduct({
        'pro_name': name,
        'pro_price': price,
        'pro_qty': quantity,
        'pro_description': description,
        'cat_id': _selectedCategoryId,
        'pro_image': imageUrl,
      });

      if (!mounted) return;
      _showMessage("Product saved successfully");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed to save product: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<String> _uploadProductImage(File image) async {
    final fileExtension = image.path.split('.').last.toLowerCase();
    final safeExtension = fileExtension.isEmpty ? 'png' : fileExtension;
    final fileName =
        'products/${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
    final storage = Supabase.instance.client.storage.from(
      'cosmetic_product_images',
    );

    await storage.upload(fileName, image);
    return storage.getPublicUrl(fileName);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      appBar: AppBar(
        title: const Text("Add Product", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Product Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                "Product Name",
                "Input product name",
                controller: _nameController,
              ),
              _buildTextField(
                "Price",
                "Input Price",
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              _buildDropdown("Product Category", "Select product category"),
              _buildTextField(
                "Quantity",
                "Input stock",
                controller: _quantityController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                "Description",
                "Input product description",
                controller: _descriptionController,
                maxLines: 3,
              ),
              const Text(
                "Image",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: _isSaving ? null : getImage,
                child: Container(
                  height: _image == null ? 50 : 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? const Center(child: Text("Select Image"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProduct,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Product",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: !_isSaving,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildDropdown(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        if (_isCategoryLoading)
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_categoryError != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Failed to load categories",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: _loadCategories,
                child: const Text("Try again"),
              ),
            ],
          )
        else
          DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: _categories
                .map(
                  (category) => DropdownMenuItem<String>(
                    value: category.catId,
                    child: Text(category.catName),
                  ),
                )
                .toList(),
            onChanged: _categories.isEmpty
                ? null
                : (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
          ),
        const SizedBox(height: 15),
      ],
    );
  }
}
