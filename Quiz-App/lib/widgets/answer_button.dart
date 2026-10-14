import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.number,
  });

  final String text;
  final VoidCallback onTap;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF26263F),
          padding: const EdgeInsets.all(16),
          side: const BorderSide(color: Color(0xFFDCDCF0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFEEEEFF),
              child: Text('$number', style: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
