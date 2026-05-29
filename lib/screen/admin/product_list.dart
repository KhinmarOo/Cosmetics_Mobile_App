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
      backgroundColor: const Color(0xFFFFFCF2),
      drawer: const AdminDrawer(activeTitle: "Products"),
      appBar: AppBar(
        title: const Text("Product Lists"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final products = snapshot.data ?? [];
          return RefreshIndicator(
            color: const Color(0xFFD4AF37),
            onRefresh: _refreshProducts,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: products.isEmpty ? 1 : products.length,
              itemBuilder: (context, index) {
                if (products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 220),
                    child: Center(child: Text("No products found")),
                  );
                }

                final item = products[index];
                return Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ExpansionTile(
                    leading: Image.network(
                      item.proImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
                    title: Text(item.proName),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow(
                              "Price",
                              "${_formatPrice(item.proPrice)} MMK",
                            ),
                            _detailRow("Quantity", "${item.proQty}"),
                            _detailRow("Date", _formatDate(item.createdAt)),
                            _detailRow("Description", item.proDescription),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: _isBusy
                                      ? null
                                      : () => _showEditDialog(item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: _isBusy
                                      ? null
                                      : () => _confirmDelete(item),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFF7F1E3), Color(0xFFD4AF37)],
          ),
        ),
        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF2D1D15),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            ).then((saved) {
              if (saved == true) {
                _refreshProducts();
              }
            });
          },
          label: const Text(
            "New Product",
            style: TextStyle(color: Color(0xFF2D1D15)),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
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
