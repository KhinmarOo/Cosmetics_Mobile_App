// import 'package:flutter/material.dart';
// import '../../../services/category_service.dart';

// class AddCategoryDialog extends StatelessWidget {
//   final TextEditingController _controller = TextEditingController();
//   final CategoryService _service = CategoryService();

//   AddCategoryDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Add Category"),
//       content: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Category Name")),
//       actions: [
//         TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//         ElevatedButton(
//           onPressed: () async {
//             await _service.addCategory(_controller.text);
//             Navigator.pop(context);
//           },
//           child: const Text("Save"),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../../services/category_service.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _controller = TextEditingController();
  final CategoryService _service = CategoryService();
  bool _isLoading = false; // loading ပြဖို့

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Category"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: "Enter category name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancel")
        ),
        _isLoading 
          ? const CircularProgressIndicator() // loading တက်နေရင် ပြမယ်
          : ElevatedButton(
              onPressed: () async {
                if (_controller.text.isEmpty) return; // စာမရိုက်ထားရင် မလုပ်ခိုင်းဘူး
                
                setState(() => _isLoading = true);
                try {
                  await _service.addCategory(_controller.text); // Database ထဲထည့်မယ်
                  if (mounted) Navigator.pop(context, true); // အောင်မြင်ရင် ပိတ်မယ်
                } catch (e) {
                  // error တက်ရင် ဒီမှာ ပြမယ်
                  debugPrint("Error: $e");
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              child: const Text("Save"),
            ),
      ],
    );
  }
}