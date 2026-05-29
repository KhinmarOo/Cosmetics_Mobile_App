import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'widgets/admin_drawer.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  static const Color _backgroundColor = Color(0xFFFFFCF2);
  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _darkTextColor = Color(0xFF2D1D15);

  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getOrders();
  }

  Future<void> _refreshOrders() async {
    final ordersFuture = _orderService.getOrders();
    setState(() {
      _ordersFuture = ordersFuture;
    });
    await ordersFuture;
  }

  Future<void> _editOrder(OrderModel order) async {
    final result = await showDialog<_OrderEditResult>(
      context: context,
      builder: (context) => _OrderEditDialog(order: order),
    );

    if (result == null) return;

    if (result.name.isEmpty || result.phone.isEmpty || result.address.isEmpty) {
      _showMessage("Please input valid order data");
      return;
    }

    await _runAction(() async {
      await _orderService.updateOrder(
        orderId: order.id,
        name: result.name,
        phone: result.phone,
        address: result.address,
      );
      if (!mounted) return;
      _showMessage("Order updated successfully");
      _refreshOrders();
    });
  }

  Future<void> _confirmDelete(OrderModel order) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Order"),
          content: Text("Delete order from '${order.name}'?"),
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
      await _orderService.deleteOrder(order.id);
      if (!mounted) return;
      _showMessage("Order deleted successfully");
      _refreshOrders();
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
      drawer: const AdminDrawer(activeTitle: "Order"),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _darkTextColor,
        title: const Text("Order Lists"),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _goldColor),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return RefreshIndicator(
              color: _goldColor,
              onRefresh: _refreshOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text("No orders found")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: _goldColor,
            onRefresh: _refreshOrders,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderTile(
                  order: order,
                  isBusy: _isBusy,
                  onEdit: () => _editOrder(order),
                  onDelete: () => _confirmDelete(order),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatefulWidget {
  final OrderModel order;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrderTile({
    required this.order,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<_OrderTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkTextColor = Color(0xFF2D1D15);

    final firstItem = widget.order.items.isEmpty
        ? null
        : widget.order.items.first;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldColor.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _ProductThumb(imageUrl: firstItem?.productImage ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.productName ?? "Order ${widget.order.id}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: darkTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Customer   ${widget.order.name}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: darkTextColor.withValues(alpha: 0.64),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: goldColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: darkTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(68, 0, 16, 14),
              child: Column(
                children: [
                  _detailRow(
                    "Total Amount",
                    _formatPrice(widget.order.totalAmount),
                  ),
                  _detailRow("Date", _formatDate(widget.order.createdAt)),
                  _detailRow("Phone", widget.order.phone),
                  _detailRow("Address", widget.order.address),
                  if (widget.order.items.length > 1) ...[
                    const SizedBox(height: 10),
                    ...widget.order.items.skip(1).map(_itemRow),
                  ],
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
      ),
    );
  }

  Widget _itemRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _ProductThumb(imageUrl: item.productImage, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "${item.productName} x${item.quantity}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2D1D15),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF2D1D15).withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                color: Color(0xFF2D1D15),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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

  String _formatPrice(int amount) {
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = amount.toString().replaceAllMapped(
      reg,
      (match) => '${match[1]},',
    );
    return "$formatted MMK";
  }
}

class _ProductThumb extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _ProductThumb({required this.imageUrl, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Icon(Icons.spa_outlined, color: Color(0xFFD4AF37))
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFFD4AF37),
                );
              },
            ),
    );
  }
}

class _OrderEditResult {
  final String name;
  final String phone;
  final String address;

  const _OrderEditResult({
    required this.name,
    required this.phone,
    required this.address,
  });
}

class _OrderEditDialog extends StatefulWidget {
  final OrderModel order;

  const _OrderEditDialog({required this.order});

  @override
  State<_OrderEditDialog> createState() => _OrderEditDialogState();
}

class _OrderEditDialogState extends State<_OrderEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.order.name);
    _phoneController = TextEditingController(text: widget.order.phone);
    _addressController = TextEditingController(text: widget.order.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _OrderEditResult(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Order"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Address"),
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
