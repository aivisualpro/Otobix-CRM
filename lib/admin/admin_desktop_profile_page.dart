import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/admin_desktop_edit_profile_page.dart';
import 'package:otobix_crm/admin/admin_desktop_settings_page.dart';
import 'package:otobix_crm/admin/edit_account_page.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/admin/admin_settings_page.dart';
import 'package:otobix_crm/admin/controller/admin_profile_controller.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'dart:ui' as ui;

class AdminDesktopProfilePage extends StatefulWidget {
  const AdminDesktopProfilePage({super.key});

  @override
  State<AdminDesktopProfilePage> createState() =>
      _AdminDesktopProfilePageState();
}

class _AdminDesktopProfilePageState extends State<AdminDesktopProfilePage> {
  final AdminProfileController adminProfileController = Get.put(
    AdminProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16.0 : 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader(),
                   const SizedBox(height: 40),
                   _buildProfileSummary(),
                   const SizedBox(height: 32),
                   Expanded(child: _buildActionGrid()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Profile",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Manage your account and settings",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
               Obx(() {
                  final imageUrl = adminProfileController.imageUrl.value;
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(color: AppColors.neonGreen.withOpacity(0.3), blurRadius: 20)
                      ]
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                  );
                }),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Obx(() => Text(
                          adminProfileController.username.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                          adminProfileController.useremail.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        )),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Administrator",
                            style: TextStyle(color: AppColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        )
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      crossAxisCount: 2, 
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.3,
      children: [
         _buildActionCard(
           title: "Edit Profile",
           subtitle: "Update personal info",
           icon: Icons.edit_outlined,
           color: Colors.blueAccent,
           onTap: () {
              Get.to(ResponsiveLayout(
                  mobile: EditProfileScreen(),
                  desktop: EditDesktopProfileScreen(),
              ));
           },
         ),
         _buildActionCard(
           title: "Settings",
           subtitle: "App preferences",
           icon: Icons.settings_outlined,
           color: Colors.purpleAccent,
           onTap: () {
              Get.to(const ResponsiveLayout(
                  mobile: AdminSettingsPage(),
                  desktop: AdminDesktopSettingsPage(),
              ));
           },
         ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        hoverColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.redAccent.withOpacity(0.05) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDestructive ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
             boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
             ]
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: color.withOpacity(0.1),
                   boxShadow: [
                      BoxShadow(color: color.withOpacity(0.2), blurRadius: 15)
                   ]
                 ),
                 child: Icon(icon, color: color, size: 32),
               ),
               const SizedBox(height: 20),
               Text(
                 title,
                 style: const TextStyle(
                   color: Colors.white,
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 8),
               Text(
                 subtitle,
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: Colors.white.withOpacity(0.5),
                   fontSize: 13,
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
