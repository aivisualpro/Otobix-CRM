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
import 'package:otobix_crm/admin/controller/admin_profile_controller.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/utils/shared_prefs_helper.dart';
import 'package:otobix_crm/widgets/glass_container.dart';
import 'package:otobix_crm/admin/admin_desktop_cars_list_page.dart';
import 'package:otobix_crm/admin/admin_cars_list_page.dart';

class AdminDesktopDashboard extends StatefulWidget {
  const AdminDesktopDashboard({super.key});
  @override
  State<AdminDesktopDashboard> createState() => _AdminDesktopDashboardState();
}

class _AdminDesktopDashboardState extends State<AdminDesktopDashboard> {
  RxInt currentIndex = 0.obs;

  final List<Widget> pages = [
    ResponsiveLayout(mobile: AdminNewDashboardPage(), desktop: AdminNewDashboardPage()), // V1
    ResponsiveLayout(mobile: AdminDesktopHomePage(), desktop: AdminDesktopHomePage()),
    ResponsiveLayout(
        mobile: AdminDesktopCustomersPage(), desktop: AdminDesktopCustomersPage()),
    ResponsiveLayout(
        mobile: AdminDesktopCarsListPage(), desktop: AdminDesktopCarsListPage()), // Cars
    ResponsiveLayout(
        mobile: AdminDesktopProfilePage(), desktop: AdminDesktopProfilePage()),
    ResponsiveLayout(mobile: AdminDesktopKamPage(), desktop: AdminDesktopKamPage()),
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
      icon: Icons.directions_car_outlined,
      activeIcon: Icons.directions_car,
      label: "Cars",
      index: 3,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: "Profile",
      index: 4,
    ),
    NavigationItem(
      icon: Icons.manage_accounts_outlined,
      activeIcon: Icons.manage_accounts,
      label: "KAM Management",
      index: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _buildDesktopLayout();
  }

  // Desktop Layout with Sidebar
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: Colors.black, // Prevent any white showing through
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('lib/assets/images/dashboard_bg.png'),
            fit: BoxFit.cover, // Cover full screen, may crop edges
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), // Slightly less darkening
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
  // User Section at Bottom of Sidebar with Logout
  Widget _buildUserSection() {
    final AdminProfileController profileController = Get.put(AdminProfileController());
    final RxBool isHovering = false.obs;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: FutureBuilder(
          future: _getUserImageUrl(),
          builder: (context, snapshot) {
            final String userImageUrl = snapshot.data ?? "";
            return Obx(() => MouseRegion(
              onEnter: (_) => isHovering.value = true,
              onExit: (_) => isHovering.value = false,
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showLogoutConfirmation(context, profileController),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isHovering.value 
                      ? LinearGradient(
                          colors: [
                            Colors.redAccent.withOpacity(0.15),
                            Colors.redAccent.withOpacity(0.05),
                          ],
                        )
                      : null,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isHovering.value 
                        ? Colors.redAccent.withOpacity(0.4)
                        : Colors.transparent,
                    ),
                    boxShadow: isHovering.value ? [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ] : [],
                  ),
                  child: Row(
                    children: [
                      // User Avatar with glow effect on hover
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isHovering.value 
                            ? Colors.redAccent.withOpacity(0.15)
                            : AppColors.neonGreen.withOpacity(0.1),
                          border: Border.all(
                            color: isHovering.value 
                              ? Colors.redAccent
                              : AppColors.neonGreen, 
                            width: 1.5,
                          ),
                          boxShadow: isHovering.value ? [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 12,
                            ),
                          ] : [],
                        ),
                        child: userImageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  userImageUrl,
                                  fit: BoxFit.cover,
                                  width: 42,
                                  height: 42,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      isHovering.value ? Icons.logout_rounded : Icons.person,
                                      color: isHovering.value ? Colors.redAccent : AppColors.neonGreen, 
                                      size: 20,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                isHovering.value ? Icons.logout_rounded : Icons.person, 
                                color: isHovering.value ? Colors.redAccent : AppColors.neonGreen, 
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isHovering.value 
                                  ? Colors.redAccent 
                                  : AppColors.textWhite,
                              ),
                              child: Text(isHovering.value ? "Sign Out" : "Admin User"),
                            ),
                            const SizedBox(height: 2),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 11,
                                color: isHovering.value 
                                  ? Colors.redAccent.withOpacity(0.7) 
                                  : AppColors.textGrey,
                              ),
                              child: Text(isHovering.value ? "Click to logout" : "Administrator"),
                            ),
                          ],
                        ),
                      ),
                      // Animated logout icon
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isHovering.value ? 1.0 : 0.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
          }),
    );
  }

  // Logout Confirmation Dialog
  void _showLogoutConfirmation(BuildContext context, AdminProfileController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2430),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logout Icon with glow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withOpacity(0.2),
                      Colors.redAccent.withOpacity(0.05),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logout Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        controller.logout();
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.redAccent, Colors.redAccent.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
