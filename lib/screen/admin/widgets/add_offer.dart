import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../../../services/offer_service.dart';
import '../../../services/product_service.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  static const Color _backgroundColor = Color(0xFFFFFCF2);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _lightGoldColor = Color(0xFFF7F1E3);
  static const Color _textColor = Color(0xFF4B3128);

  final ProductService _productService = ProductService();
  final OfferService _offerService = OfferService();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Future<List<ProductModel>> _productsFuture;
  String? _selectedProductId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
  }

  Future<void> _saveOffer() async {
    final price = int.tryParse(
      _priceController.text.trim().replaceAll(',', ''),
    );
    final description = _descriptionController.text.trim();

    if (_selectedProductId == null) {
      _showMessage("Please select product");
      return;
    }
    if (price == null || price <= 0) {
      _showMessage("Please input a valid sale price");
      return;
    }
    if (description.isEmpty) {
      _showMessage("Please input description");
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _offerService.addOffer(
        productId: _selectedProductId!,
        offerPrice: price,
        description: description,
      );
      if (!mounted) return;
      _showMessage("Offer saved successfully");
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed to save offer: $e");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textColor,
        title: const Text("Offer"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: BoxDecoration(
            color: _cardColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Offer",
                style: TextStyle(
                  color: _textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Product Name",
                style: TextStyle(
                  color: _textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _buildProductDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Sale Price",
                hint: "price",
                controller: _priceController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                label: "Description",
                hint: "description",
                controller: _descriptionController,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _isSaving ? null : _saveOffer,
                  child: Container(
                    width: 72,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      gradient: const LinearGradient(
                        colors: [_goldColor, _lightGoldColor, _goldColor],
                      ),
                    ),
                    child: Center(
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: _textColor,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save",
                              style: TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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

  Widget _buildProductDropdown() {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _fieldShell(
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: _goldColor,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _fieldShell(
            child: Text(
              "Failed to load products",
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
          );
        }

        final products = snapshot.data ?? [];
        return DropdownButtonFormField<String>(
          initialValue: _selectedProductId,
          isExpanded: true,
          decoration: _inputDecoration("select product"),
          items: products
              .map(
                (product) => DropdownMenuItem<String>(
                  value: product.proId,
                  child: Text(
                    product.proName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _isSaving || products.isEmpty
              ? null
              : (value) {
                  setState(() => _selectedProductId = value);
                },
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !_isSaving,
            keyboardType: keyboardType,
            decoration: _inputDecoration(hint),
          ),
        ],
      ),
    );
  }

  Widget _fieldShell({required Widget child}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC7A17A)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _textColor.withValues(alpha: 0.35)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFFC7A17A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFFC7A17A), width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          color: const Color(0xFFC7A17A).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
