import 'package:flutter/material.dart';

class AccountQuickActions extends StatelessWidget {
  const AccountQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _item(Icons.local_shipping, "سطحة"),
        _item(Icons.car_repair, "فحص"),
        _item(Icons.report, "حادث"),
        _item(Icons.support_agent, "دعم"),
      ],
    );
  }

  Widget _item(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blue.withOpacity(.15),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13))
      ],
    );
  }
}
