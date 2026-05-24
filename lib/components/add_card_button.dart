import 'package:flutter/material.dart';

class AddCardButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddCardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFD4AF37),
              Color(0xFFF7F1E3),
              Color(0xFFD4AF37),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            "Add to cart",
            style: TextStyle(
              color: Color(0xFF554518),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}