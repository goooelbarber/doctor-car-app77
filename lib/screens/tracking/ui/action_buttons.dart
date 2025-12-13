import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onWhatsapp;

  const ActionButtons({
    super.key,
    required this.onCall,
    required this.onWhatsapp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // CALL BUTTON
        Expanded(
          child: ElevatedButton(
            onPressed: onCall,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  "اتصال",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // WHATSAPP BUTTON
        Expanded(
          child: ElevatedButton(
            onPressed: onWhatsapp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "واتساب",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
// TODO Implement this library.
