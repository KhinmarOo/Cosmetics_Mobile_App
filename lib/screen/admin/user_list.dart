import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import 'widgets/admin_drawer.dart';
import 'widgets/add_user.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  static const Color _backgroundColor = Color(0xFFFFFCF2);
  static const Color _panelColor = Color(0xFFFFFFFF);
  static const Color _goldColor = Color(0xFFE6B31E);

  final UserService _userService = UserService();
  late Future<List<UserModel>> _customersFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _customersFuture = _userService.getUsers();
  }

  Future<void> _refreshCustomers() async {
    final customersFuture = _userService.getUsers();
    setState(() {
      _customersFuture = customersFuture;
    });
    await customersFuture;
  }

  Future<void> _openAddCustomer() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddUserScreen()),
    );

    if (saved == true) {
      _refreshCustomers();
    }
  }

  Future<void> _editCustomer(UserModel customer) async {
    final result = await showDialog<_CustomerEditResult>(
      context: context,
      builder: (context) => _CustomerEditDialog(customer: customer),
    );

    if (result == null) return;

    if (result.name.isEmpty ||
        result.email.isEmpty ||
        !result.email.contains('@')) {
      _showMessage("Please input valid customer data");
      return;
    }

    await _runAction(() async {
      await _userService.updateUser(
        id: customer.id,
        name: result.name,
        email: result.email,
        phone: result.phone,
        role: customer.role,
      );
      if (!mounted) return;
      _showMessage("Customer updated successfully");
      _refreshCustomers();
    });
  }

  Future<void> _confirmDelete(UserModel customer) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Customer"),
          content: Text("Are you sure you want to delete '${customer.name}'?"),
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
      await _userService.deleteUser(customer.id);
      if (!mounted) return;
      _showMessage("Customer deleted successfully");
      _refreshCustomers();
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
      drawer: const AdminDrawer(activeTitle: "Customer Lists"),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D1D15),
        title: const Text("Customer Lists"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _openAddCustomer,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [_goldColor, Color(0xFFF7F1E3), _goldColor],
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add Customer",
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
                child: FutureBuilder<List<UserModel>>(
                  future: _customersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _goldColor),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final customers = snapshot.data ?? [];
                    if (customers.isEmpty) {
                      return RefreshIndicator(
                        color: _goldColor,
                        onRefresh: _refreshCustomers,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 220),
                            Center(child: Text("No customers found")),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: _goldColor,
                      onRefresh: _refreshCustomers,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: customers.length,
                        separatorBuilder: (context, index) =>
                            Divider(height: 1, color: Colors.brown.shade100),
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return _CustomerTile(
                            customer: customer,
                            isBusy: _isBusy,
                            onEdit: () => _editCustomer(customer),
                            onDelete: () => _confirmDelete(customer),
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

class _CustomerTile extends StatefulWidget {
  final UserModel customer;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerTile({
    required this.customer,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CustomerTile> createState() => _CustomerTileState();
}

class _CustomerTileState extends State<_CustomerTile> {
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
                _AvatarBadge(role: widget.customer.role),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B3128),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.customer.role.isEmpty
                            ? "-"
                            : widget.customer.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.brown.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
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
            padding: const EdgeInsets.fromLTRB(76, 0, 16, 14),
            child: Column(
              children: [
                _detailRow("E-mail", widget.customer.email),
                _detailRow("Phone", widget.customer.phone),
                _detailRow("Password", "Hidden"),
                _detailRow("Role", widget.customer.role),
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
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
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
}

class _AvatarBadge extends StatelessWidget {
  final String role;

  const _AvatarBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';

    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFE6B31E).withValues(alpha: 0.22),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        child: Icon(
          isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline,
          color: const Color(0xFF4B3128),
          size: 19,
        ),
      ),
    );
  }
}

class _CustomerEditResult {
  final String name;
  final String email;
  final String phone;

  const _CustomerEditResult({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class _CustomerEditDialog extends StatefulWidget {
  final UserModel customer;

  const _CustomerEditDialog({required this.customer});

  @override
  State<_CustomerEditDialog> createState() => _CustomerEditDialogState();
}

class _CustomerEditDialogState extends State<_CustomerEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _emailController = TextEditingController(text: widget.customer.email);
    _phoneController = TextEditingController(text: widget.customer.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _CustomerEditResult(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Customer"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
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
