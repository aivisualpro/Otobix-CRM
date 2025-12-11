import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/admin_desktop_edit_profile_page.dart';
import 'package:otobix_crm/admin/admin_desktop_settings_page.dart';
import 'package:otobix_crm/admin/edit_account_page.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/admin/admin_settings_page.dart';
import 'package:otobix_crm/admin/controller/admin_profile_controller.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final AdminProfileController adminProfileController = Get.put(
    AdminProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Obx(() {
                          final imageUrl = adminProfileController
                              .imageUrl.value; // make sure `user` is reactive

                          return CircleAvatar(
                            radius: 55,
                            backgroundImage:
                                // ignore: unnecessary_null_comparison
                                imageUrl != null && imageUrl.isNotEmpty
                                    ? NetworkImage(
                                        imageUrl.startsWith('http')
                                            ? imageUrl
                                            : imageUrl,
                                      )
                                    : null,
                            child:
                                // ignore: unnecessary_null_comparison
                                imageUrl == null || imageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 55)
                                    : null,
                          );
                        }),
                        SizedBox(height: 12),
                        Text(
                          adminProfileController.username.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          adminProfileController.useremail.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  ProfileOption(
                    icon: Icons.edit,
                    color: AppColors.grey,
                    title: "Edit Profile",
                    description: "Change your name, email, and more.",
                    onTap: () {
                      Get.to(ResponsiveLayout(
                        mobile: EditProfileScreen(),
                        desktop: EditDesktopProfileScreen(),
                      ));
                    },
                  ),

                  // ProfileOption(
                  //   icon: Icons.car_rental,
                  //   color: AppColors.blue,
                  //   title: "Add a Car",
                  //   description: "Add a car in upcoming.",
                  //   onTap: () {
                  //     Get.to(DummyCarAddInUpcoming());
                  //   },
                  // ),

                  // ProfileOption(
                  //   icon: Icons.manage_accounts_outlined,
                  //   color: AppColors.black,
                  //   title: "KAMs Management",
                  //   description: "Manage all KAMs.",
                  //   onTap: () {
                  //     Get.to(ResponsiveLayout(
                  //       mobile: AdminKamPage(),
                  //       desktop: AdminDesktopKamPage(),
                  //     ));
                  //   },
                  // ),

                  ProfileOption(
                    icon: Icons.settings,
                    color: AppColors.blue,
                    title: "Settings",
                    description: "Update terms and privacy policy.",
                    onTap: () {
                      Get.to(ResponsiveLayout(
                        mobile: AdminSettingsPage(),
                        desktop: AdminDesktopSettingsPage(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? description;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: .5),
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: description != null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
