import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/admin_customers_page.dart';
import 'package:otobix_crm/admin/admin_desktop_customers_page.dart';
import 'package:otobix_crm/admin/admin_desktop_home_page.dart';
import 'package:otobix_crm/admin/admin_desktop_profile_page.dart';
import 'package:otobix_crm/admin/admin_desktop_kam_page.dart';
import 'package:otobix_crm/admin/admin_kam_page.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/admin/admin_home.dart';
import 'package:otobix_crm/admin/admin_new_dashboard_page.dart'; // New Dashboard Import
import 'package:otobix_crm/admin/admin_profile_page.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/utils/shared_prefs_helper.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class AdminDesktopDashboard extends StatefulWidget {
  const AdminDesktopDashboard({super.key});
  @override
  State<AdminDesktopDashboard> createState() => _AdminDesktopDashboardState();
}

class _AdminDesktopDashboardState extends State<AdminDesktopDashboard> {
  RxInt currentIndex = 0.obs;

  final List<Widget> pages = [
    ResponsiveLayout(mobile: AdminNewDashboardPage(), desktop: AdminNewDashboardPage()), // V1
    ResponsiveLayout(mobile: AdminHome(), desktop: AdminDesktopHomePage()),
    ResponsiveLayout(
        mobile: AdminCustomersPage(), desktop: AdminDesktopCustomersPage()),
    ResponsiveLayout(
        mobile: AdminProfilePage(), desktop: AdminDesktopProfilePage()),
    ResponsiveLayout(mobile: AdminKamPage(), desktop: AdminDesktopKamPage()),
  ];

  // Navigation items for desktop sidebar
  final List<NavigationItem> navItems = [
    // V1 Default
    NavigationItem(
      icon: Icons.dashboard_customize_outlined,
      activeIcon: Icons.dashboard_customize,
      label: "Dashboard",
      index: 0,
    ),
    NavigationItem(
      icon: Icons.grid_view_outlined, 
      activeIcon: Icons.grid_view_rounded,
      label: "Users",
      index: 1,
    ),
    NavigationItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: "Customers",
      index: 2,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: "Profile",
      index: 3,
    ),
    NavigationItem(
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts,
      label: "KAM Management",
      index: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildDesktopLayout();
  }

  // Desktop Layout with Sidebar
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('lib/assets/images/dashboard_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), // Darken the image slightly for text readability
              BlendMode.darken,
            ),
          ),
        ),
        child: Row(
          children: [
            // Sidebar Navigation
            _buildSidebar(),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Main Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
                      decoration: const BoxDecoration(
                        // Removed white background
                      ),
                      child: Obx(() => pages[currentIndex.value]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar Widget for Desktop
  Widget _buildSidebar() {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(24),
      // Removed white background & border
      child: GlassContainer( // Use GlassContainer for the sidebar panel
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Logo and App Name
            _buildSidebarHeader(),

            // Navigation Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  return _buildNavItem(item);
                },
              ),
            ),

            // User Profile Section
            _buildUserSection(),
          ],
        ),
      ),
    );
  }

  // Sidebar Header with Logo
  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.neonGreen, Color(0xFFAACC00)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "OtoBix CRM",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const Text(
                "Admin Panel",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation Item for Desktop
  Widget _buildNavItem(NavigationItem item) {
    return Obx(() {
      final isActive = currentIndex.value == item.index;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              currentIndex.value = item.index;
            },
            borderRadius: BorderRadius.circular(12),
             hoverColor: AppColors.glassWhite,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.neonGreen.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppColors.neonGreen.withOpacity(0.5) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    color: isActive ? AppColors.neonGreen : AppColors.textGrey,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? AppColors.neonGreen : AppColors.textGrey,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
  // User Section at Bottom of Sidebar
  Widget _buildUserSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: FutureBuilder(
          future: _getUserImageUrl(),
          builder: (context, snapshot) {
            final String userImageUrl = snapshot.data ?? "";
            return Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonGreen.withOpacity(0.1),
                    border: Border.all(color: AppColors.neonGreen, width: 1),
                  ),
                  child: userImageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            userImageUrl,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person,
                                  color: AppColors.neonGreen, size: 20);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: AppColors.neonGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Admin User",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const Text(
                        "Administrator",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                // IconButton(
                //   icon: Icon(Icons.logout, color: Colors.grey[500], size: 20),
                //   onPressed: () {
                //     // Add logout functionality
                //   },
                // ),
              ],
            );
          }),
    );
  }

  // Top App Bar for Desktop
  Widget _buildAppBar() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Page Title
          Obx(() {
            final currentItem = navItems.firstWhere(
              (item) => item.index == currentIndex.value,
              orElse: () => navItems[0],
            );
            return Text(
              currentItem.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            );
          }),

          Spacer(),

          // Search Bar
          // Container(
          //   width: 300,
          //   height: 40,
          //   child: TextField(
          //     decoration: InputDecoration(
          //       hintText: "Search...",
          //       prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          //       filled: true,
          //       fillColor: Colors.grey[50],
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(8),
          //         borderSide: BorderSide.none,
          //       ),
          //       contentPadding: EdgeInsets.symmetric(vertical: 0),
          //     ),
          //   ),
          // ),

          // SizedBox(width: 16),

          // // Notifications
          // IconButton(
          //   icon: Stack(
          //     children: [
          //       Icon(Icons.notifications_outlined, color: Colors.grey[600]),
          //       Positioned(
          //         right: 0,
          //         top: 0,
          //         child: Container(
          //           width: 8,
          //           height: 8,
          //           decoration: BoxDecoration(
          //             color: Colors.red,
          //             shape: BoxShape.circle,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //   onPressed: () {},
          // ),

          // SizedBox(width: 16),

          // // Settings
          // IconButton(
          //   icon: Icon(Icons.settings_outlined, color: Colors.grey[600]),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }

  Future<String> _getUserImageUrl() async {
    return await SharedPrefsHelper.getString(
            SharedPrefsHelper.userImageUrlKey) ??
        "";
  }
}

// Navigation Item Model for Desktop
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}
