import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'widgets/admin_drawer.dart';
import 'widgets/add_product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  static const Color _backgroundColor = Color(0xFFFFFCF2);
  static const Color _panelColor = Color(0xFFFFFFFF);
  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _lightGoldColor = Color(0xFFF7F1E3);
  static const Color _textColor = Color(0xFF4B3128);

  final ProductService _service = ProductService();
  late Future<List<ProductModel>> _productsFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _productsFuture = _service.getProducts();
  }

  Future<void> _refreshProducts() async {
    final productsFuture = _service.getProducts();
    setState(() {
      _productsFuture = productsFuture;
    });
    await productsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: const AdminDrawer(activeTitle: "Products"),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textColor,
        title: const Text("Product Lists"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _openAddProduct,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [_goldColor, _lightGoldColor, _goldColor],
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "New Product",
                        style: TextStyle(
                          color: Color(0xFF2D1D15),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.add, size: 18, color: Color(0xFF2D1D15)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _panelColor.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: FutureBuilder<List<ProductModel>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _goldColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final products = snapshot.data ?? [];
                    if (products.isEmpty) {
                      return RefreshIndicator(
                        color: _goldColor,
                        onRefresh: _refreshProducts,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 220),
                            Center(child: Text("No products found")),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: _goldColor,
                      onRefresh: _refreshProducts,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: products.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.brown.shade100),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _ProductTile(
                            product: product,
                            isBusy: _isBusy,
                            onEdit: () => _showEditDialog(product),
                            onDelete: () => _confirmDelete(product),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddProduct() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    if (saved == true) {
      _refreshProducts();
    }
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.round().toString();
    }

    return price.toStringAsFixed(2);
  }

  Future<void> _showEditDialog(ProductModel product) async {
    final result = await showDialog<_ProductEditResult>(
      context: context,
      builder: (context) => _ProductEditDialog(
        product: product,
        priceText: _formatPrice(product.proPrice),
      ),
    );

    if (result == null) return;

    if (result.name.isEmpty ||
        result.price == null ||
        result.price! <= 0 ||
        result.quantity == null ||
        result.quantity! < 0) {
      _showMessage("Please input valid product data");
      return;
    }

    await _runAction(() async {
      await _service.updateProduct(product.proId, {
        'pro_name': result.name,
        'pro_price': result.price,
        'pro_qty': result.quantity,
        'pro_description': result.description,
      });
      if (!mounted) return;
      _showMessage("Product updated successfully");
      _refreshProducts();
    });
  }

  Future<void> _confirmDelete(ProductModel product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: Text(
            "Are you sure you want to delete '${product.proName}'?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _runAction(() async {
      await _service.deleteProduct(product.proId);
      if (!mounted) return;
      _showMessage("Product deleted successfully");
      _refreshProducts();
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _isBusy = true);
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      _showMessage("Action failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProductTile extends StatefulWidget {
  final ProductModel product;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.product.proImage,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 36,
                      height: 36,
                      color: const Color(0xFFF7F1E3),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.product.proName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF4B3128),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEE).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF4B3128),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 0, 16, 14),
            child: Column(
              children: [
                _detailRow(
                  "Price",
                  "${_formatPrice(widget.product.proPrice)} MMK",
                ),
                _detailRow("Quantity", "${widget.product.proQty}"),
                _detailRow("Date", _formatDate(widget.product.createdAt)),
                _detailRow("Description", widget.product.proDescription),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: "Edit",
                      onPressed: widget.isBusy ? null : widget.onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF8A6A1F),
                        size: 20,
                      ),
                    ),
                    IconButton(
                      tooltip: "Delete",
                      onPressed: widget.isBusy ? null : widget.onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: TextStyle(color: Colors.brown.shade400, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(color: Color(0xFF4B3128), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.round().toString();
    }

    return price.toStringAsFixed(2);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";

    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final year = (local.year % 100).toString().padLeft(2, '0');
    final hour = local.hour == 0 || local.hour == 12 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return "$month/$day/$year at $hour:$minute $period";
  }
}

class _ProductEditResult {
  final String name;
  final int? price;
  final int? quantity;
  final String description;

  const _ProductEditResult({
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
  });
}

class _ProductEditDialog extends StatefulWidget {
  final ProductModel product;
  final String priceText;

  const _ProductEditDialog({required this.product, required this.priceText});

  @override
  State<_ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<_ProductEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _qtyController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.proName);
    _priceController = TextEditingController(text: widget.priceText);
    _qtyController = TextEditingController(
      text: widget.product.proQty.toString(),
    );
    _descController = TextEditingController(
      text: widget.product.proDescription,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _ProductEditResult(
        name: _nameController.text.trim(),
        price: int.tryParse(_priceController.text.trim().replaceAll(',', '')),
        quantity: int.tryParse(_qtyController.text.trim()),
        description: _descController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Product"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _submit, child: const Text("Update")),
      ],
    );
  }
}
