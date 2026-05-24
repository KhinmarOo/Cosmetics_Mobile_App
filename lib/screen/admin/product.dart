import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/category_service.dart'; // Category ယူဖို့
import '../../models/category_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _descController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCatId;
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await CategoryService().getCategories();
    setState(() => _categories = data);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _saveProduct() async {
    if (_imageFile == null || _selectedCatId == null) return;

    // 1. Image ကို Supabase Storage တင်မယ်
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    await Supabase.instance.client.storage
        .from('product_images') // Bucket နာမည်
        .upload(fileName, _imageFile!);

    final imageUrl = Supabase.instance.client.storage
        .from('product_images')
        .getPublicUrl(fileName);

    // 2. Database ထဲ Product သိမ်းမယ်
    await Supabase.instance.client.from('products').insert({
      'pro_name': _nameController.text,
      'pro_price': double.tryParse(_priceController.text) ?? 0,
      'pro_qty': int.tryParse(_qtyController.text) ?? 0,
      'pro_description': _descController.text,
      'cat_id': _selectedCatId,
      'pro_image': imageUrl,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Price")),
            TextField(controller: _qtyController, decoration: const InputDecoration(labelText: "Quantity")),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              hint: const Text("Select Product Category"),
              value: _selectedCatId,
              items: _categories.map((cat) => DropdownMenuItem(value: cat.catId, child: Text(cat.catName))).toList(),
              onChanged: (val) => setState(() => _selectedCatId = val),
            ),
            
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150, width: double.infinity,
                color: Colors.grey[200],
                child: _imageFile != null ? Image.file(_imageFile!, fit: BoxFit.cover) : const Icon(Icons.add_a_photo),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveProduct, child: const Text("Save Product")),
          ],
        ),
      ),
    );
  }
}