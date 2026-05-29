import 'package:flutter/material.dart';

import '../../models/offer_model.dart';
import '../../models/product_model.dart';
import '../../services/offer_service.dart';
import '../../services/product_service.dart';
import 'widgets/admin_drawer.dart';
import 'widgets/add_offer.dart';

class OfferListScreen extends StatefulWidget {
  const OfferListScreen({super.key});

  @override
  State<OfferListScreen> createState() => _OfferListScreenState();
}

class _OfferListScreenState extends State<OfferListScreen> {
  static const Color _backgroundColor = Color(0xFFFFFCF2);
  static const Color _panelColor = Color(0xFFFFFFFF);
  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _lightGoldColor = Color(0xFFF7F1E3);
  static const Color _textColor = Color(0xFF4B3128);

  final OfferService _offerService = OfferService();
  final ProductService _productService = ProductService();
  late Future<List<OfferModel>> _offersFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _offersFuture = _offerService.getOffers();
  }

  Future<void> _refreshOffers() async {
    final offersFuture = _offerService.getOffers();
    setState(() {
      _offersFuture = offersFuture;
    });
    await offersFuture;
  }

  Future<void> _openAddOffer() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddOfferScreen()),
    );

    if (saved == true) {
      _refreshOffers();
    }
  }

  Future<void> _editOffer(OfferModel offer) async {
    final result = await showDialog<_OfferEditResult>(
      context: context,
      builder: (context) => _OfferEditDialog(
        offer: offer,
        productsFuture: _productService.getProducts(),
      ),
    );

    if (result == null) return;

    if (result.productId.isEmpty ||
        result.offerPrice == null ||
        result.offerPrice! <= 0 ||
        result.description.isEmpty) {
      _showMessage("Please input valid offer data");
      return;
    }

    await _runAction(() async {
      await _offerService.updateOffer(
        offerId: offer.offerId,
        productId: result.productId,
        offerPrice: result.offerPrice!,
        description: result.description,
      );
      if (!mounted) return;
      _showMessage("Offer updated successfully");
      _refreshOffers();
    });
  }

  Future<void> _confirmDelete(OfferModel offer) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Offer"),
          content: Text(
            "Are you sure you want to delete '${offer.productName}' offer?",
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
      await _offerService.deleteOffer(offer.offerId);
      if (!mounted) return;
      _showMessage("Offer deleted successfully");
      _refreshOffers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: const AdminDrawer(activeTitle: "Offer Lists"),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textColor,
        title: const Text("Offer product lists"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _openAddOffer,
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
                child: FutureBuilder<List<OfferModel>>(
                  future: _offersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _goldColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final offers = snapshot.data ?? [];
                    if (offers.isEmpty) {
                      return RefreshIndicator(
                        color: _goldColor,
                        onRefresh: _refreshOffers,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 220),
                            Center(child: Text("No offers found")),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: _goldColor,
                      onRefresh: _refreshOffers,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: offers.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.brown.shade100),
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return _OfferTile(
                            offer: offer,
                            isBusy: _isBusy,
                            onEdit: () => _editOffer(offer),
                            onDelete: () => _confirmDelete(offer),
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
}

class _OfferTile extends StatefulWidget {
  final OfferModel offer;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OfferTile({
    required this.offer,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_OfferTile> createState() => _OfferTileState();
}

class _OfferTileState extends State<_OfferTile> {
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
                    widget.offer.productImage,
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
                    widget.offer.productName,
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
                  "${_formatPrice(widget.offer.productPrice)} MMK",
                ),
                _detailRow(
                  "Sale Price",
                  "${_formatPrice(widget.offer.offerPrice)} MMK",
                ),
                _detailRow("Date", _formatDate(widget.offer.createdAt)),
                _detailRow("Description", widget.offer.offerDescription),
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

class _OfferEditResult {
  final String productId;
  final int? offerPrice;
  final String description;

  const _OfferEditResult({
    required this.productId,
    required this.offerPrice,
    required this.description,
  });
}

class _OfferEditDialog extends StatefulWidget {
  final OfferModel offer;
  final Future<List<ProductModel>> productsFuture;

  const _OfferEditDialog({required this.offer, required this.productsFuture});

  @override
  State<_OfferEditDialog> createState() => _OfferEditDialogState();
}

class _OfferEditDialogState extends State<_OfferEditDialog> {
  late String _selectedProductId;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.offer.proId;
    _priceController = TextEditingController(
      text: _formatPrice(widget.offer.offerPrice),
    );
    _descriptionController = TextEditingController(
      text: widget.offer.offerDescription,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _OfferEditResult(
        productId: _selectedProductId,
        offerPrice: int.tryParse(
          _priceController.text.trim().replaceAll(',', ''),
        ),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Offer"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<List<ProductModel>>(
              future: widget.productsFuture,
              builder: (context, snapshot) {
                final products = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  initialValue:
                      products.any(
                        (product) => product.proId == _selectedProductId,
                      )
                      ? _selectedProductId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: "Product"),
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
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedProductId = value);
                  },
                );
              },
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Sale Price"),
            ),
            TextField(
              controller: _descriptionController,
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

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return price.round().toString();
    }

    return price.toStringAsFixed(2);
  }
}
