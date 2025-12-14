import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/controllers/desktop_homepage_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_images.dart';
import 'package:otobix_crm/views/desktop_bid_history_page.dart';
import 'package:otobix_crm/views/desktop_cars_page.dart';
import 'package:otobix_crm/views/desktop_dashboard_page.dart';
import 'package:otobix_crm/views/page_not_found_page.dart';
import 'package:otobix_crm/widgets/sidebar_widget.dart';

class DesktopHomepage extends StatelessWidget {
  DesktopHomepage({super.key});

  final controller = Get.put(DesktopHomepageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // App Bar
          _buildAppbar(),

          // Main content (Sidebar + Screen)
          Expanded(
            child: Row(
              children: [
                // Sidebar
                SidebarWidget(controller: controller.sidebarController),

                // Screens
                _buildScreens(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Appbar widget
  Widget _buildAppbar() {
    final getxController = Get.find<DesktopHomepageController>();

    // Search bar widget
    Widget buildSearchBar() {
      return Container(
        width: 300,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.grey),
          borderRadius: BorderRadius.circular(80),
        ),
        child: TextField(
          controller: getxController.searchController,
          onChanged: getxController.setSearch, // ← push text globally
          onSubmitted: getxController
              .onSearchSubmitted, // 🔥 triggers screen-specific search
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
        ),
      );
    }

    // Actual Appbar
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        // height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),

        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1), // subtle shadow
              offset: const Offset(2, 0), // horizontal shadow to the right
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image(image: AssetImage(AppImages.logo), width: 40, height: 40),
                const SizedBox(width: 10),
                Text(
                  "Otobix CRM",
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 100),
                buildSearchBar(),
              ],
            ),
            Row(
              children: [
                // Profile Logout Button
                PopupMenuButton<int>(
                  tooltip: 'Account',
                  // color: AppColors.grey.withValues(alpha: .2),
                  offset: const Offset(0, 48),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (v) {
                    if (v == 1) getxController.logout();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(
                      enabled: false,
                      child: FutureBuilder<Map<String, String>>(
                        future: getxController.loadUserFromPrefs(),
                        builder: (context, snap) {
                          final data = snap.data ??
                              const {'name': '', 'email': '', 'phone': ''};
                          return SizedBox(
                            width: 260,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          AssetImage(AppImages.logo),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        (data['name']?.isNotEmpty ?? false)
                                            ? data['name']!
                                            : 'User',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.black),
                                ),
                                const SizedBox(height: 2),
                                SelectableText(
                                  data['email']?.isNotEmpty == true
                                      ? data['email']!
                                      : '—',
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.black),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Phone',
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.black),
                                ),
                                const SizedBox(height: 2),
                                SelectableText(
                                  data['phone']?.isNotEmpty == true
                                      ? data['phone']!
                                      : '—',
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.black),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.logout,
                            size: 18,
                            color: AppColors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(color: AppColors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.green),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image(
                          image: AssetImage(AppImages.logo),
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Screens
  Widget _buildScreens(DesktopHomepageController controller) {
    return Expanded(
      child: AnimatedBuilder(
        animation: controller.sidebarController,
        builder: (context, _) {
          switch (controller.sidebarController.selectedIndex) {
            case 0:
              return DesktopDashboardPage();
            case 1:
              return DesktopBidHistoryPage();
            case 2:
              return DesktopCarsPage();
            default:
              return const Center(child: PageNotFoundPage());
          }
        },
      ),
    );
  }
}
