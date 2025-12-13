// lib/pages/profile/profile_page.dart

import 'package:flutter/material.dart';
import '../../core/widgets/custom_appbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "My Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ------------------------------
            // USER HEADER
            // ------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Guest User",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "guest@example.com",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------
            // PROFILE OPTIONS
            // ------------------------------
            profileItem(
              icon: Icons.shopping_bag_outlined,
              title: "My Orders",
              onTap: () {},
            ),
            profileItem(
              icon: Icons.favorite_border,
              title: "Wishlist",
              onTap: () {},
            ),
            profileItem(
              icon: Icons.location_on_outlined,
              title: "Addresses",
              onTap: () {},
            ),
            profileItem(
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {},
            ),
            profileItem(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              onTap: () {},
            ),

            const SizedBox(height: 15),

            // ------------------------------
            // LOGOUT BUTTON
            // ------------------------------
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------------------
  // REUSABLE PROFILE ITEM WIDGET
  // ------------------------------------
  Widget profileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 28, color: Colors.blue),
          title: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
