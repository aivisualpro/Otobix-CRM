import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/Admin_Home_View.dart';

import 'package:otobix_crm/admin/admin_desktop_customers_page.dart';
import 'package:otobix_crm/admin/admin_desktop_home_page.dart';
import 'package:otobix_crm/admin/admin_desktop_profile_page.dart';
import 'package:otobix_crm/admin/admin_desktop_kam_page.dart';
import 'package:otobix_crm/admin/admin_new_dashboard_page.dart';
import 'package:otobix_crm/admin/admin_desktop_cars_list_page.dart';

import 'package:otobix_crm/admin/controller/admin_profile_controller.dart';
import 'package:otobix_crm/admin/controller/admin_shell_controller.dart';

import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/utils/shared_prefs_helper.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class AdminDesktopDashboard extends StatelessWidget {
  const AdminDesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(AdminDesktopShellController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('lib/assets/images/dashboard_bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Row(
          children: [
            _Sidebar(shell: shell),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24, right: 24),
                    child: _BreadcrumbBar(shell: shell),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 24, bottom: 24),
                      child: Obx(() {
                        if (!shell.inAdminPanel.value) {
                          return _HubBody(shell: shell);
                        }
                        return _AdminPanelBody(shell: shell);
                      }),
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
}

/* ----------------------- HUB MODE BODY ----------------------- */

class _HubBody extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _HubBody({required this.shell});

  String _hubLabel(int i) {
    switch (i) {
      case 0:
        return "Dashboard";
      case 1:
        return "Leads";
      case 2:
        return "Inspection";
      case 3:
        return "Watti";
      case 4:
        return "Price Discovery";
      case 5:
        return "Auction";
      default:
        return "Dashboard";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = shell.hubIndex.value;

      // ✅ Hub Dashboard = show GRID
      if (idx == 0) return const AdminHomeView();

      // ✅ Other hub pages (placeholder)
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
          child: Text(
            _hubLabel(idx),
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    });
  }
}

/* ----------------------- ADMIN PANEL BODY ----------------------- */

class _AdminPanelBody extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _AdminPanelBody({required this.shell});

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ResponsiveLayout(
        mobile: AdminNewDashboardPage(),
        desktop: AdminNewDashboardPage(),
      ),
      ResponsiveLayout(
        mobile: AdminDesktopHomePage(),
        desktop: AdminDesktopHomePage(),
      ),
      ResponsiveLayout(
        mobile: AdminDesktopCustomersPage(),
        desktop: AdminDesktopCustomersPage(),
      ),
      ResponsiveLayout(
        mobile: AdminDesktopCarsListPage(),
        desktop: AdminDesktopCarsListPage(),
      ),
      ResponsiveLayout(
        mobile: AdminDesktopProfilePage(),
        desktop: AdminDesktopProfilePage(),
      ),
      ResponsiveLayout(
        mobile: AdminDesktopKamPage(),
        desktop: AdminDesktopKamPage(),
      ),
    ];

    return Obx(() => pages[shell.adminIndex.value]);
  }
}

/* ----------------------------- SIDEBAR ----------------------------- */

class _Sidebar extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _Sidebar({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.all(24),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final inAdmin = shell.inAdminPanel.value;

                final hubItems = <NavigationItem>[
                  NavigationItem(
                    icon: Icons.dashboard_customize_outlined,
                    activeIcon: Icons.dashboard_customize,
                    label: "Dashboard",
                    index: 0,
                  ),
                  NavigationItem(
                    icon: Icons.leaderboard_outlined,
                    activeIcon: Icons.leaderboard,
                    label: "Leads",
                    index: 1,
                  ),
                  NavigationItem(
                    icon: Icons.fact_check_outlined,
                    activeIcon: Icons.fact_check,
                    label: "Inspection",
                    index: 2,
                  ),
                  NavigationItem(
                    icon: Icons.bolt_outlined,
                    activeIcon: Icons.bolt,
                    label: "Watti",
                    index: 3,
                  ),
                  NavigationItem(
                    icon: Icons.price_change_outlined,
                    activeIcon: Icons.price_change,
                    label: "Price Discovery",
                    index: 4,
                  ),
                  NavigationItem(
                    icon: Icons.gavel_outlined,
                    activeIcon: Icons.gavel,
                    label: "Auction",
                    index: 5,
                  ),
                ];

                final adminItems = <NavigationItem>[
                  NavigationItem(
                    icon: Icons.arrow_back_ios_new_rounded,
                    activeIcon: Icons.arrow_back_ios_new_rounded,
                    label: "Back to Modules",
                    index: -1,
                  ),
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

                final items = inAdmin ? adminItems : hubItems;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _NavItem(shell: shell, item: item);
                  },
                );
              }),
            ),
            _UserSection(),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AdminDesktopShellController shell;
  final NavigationItem item;
  const _NavItem({required this.shell, required this.item});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inAdmin = shell.inAdminPanel.value;
      final selectedIndex =
          inAdmin ? shell.adminIndex.value : shell.hubIndex.value;

      final isActive = (item.index == -1) ? false : selectedIndex == item.index;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (shell.inAdminPanel.value) {
                if (item.index == -1) {
                  shell.closeAdminPanel();
                  return;
                }
                shell.selectAdmin(item.index);
              } else {
                // ✅ FIX: Hub drawer Dashboard should open Admin Panel
                if (item.index == 0) {
                  shell.selectHub(0);
                  shell.openAdminPanel();
                  return;
                }
                shell.selectHub(item.index);
              }
            },
            borderRadius: BorderRadius.circular(12),
            hoverColor: AppColors.glassWhite,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.neonGreen.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? AppColors.neonGreen.withOpacity(0.5)
                      : Colors.transparent,
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
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            isActive ? AppColors.neonGreen : AppColors.textGrey,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
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
}

/* -------------------------- USER SECTION -------------------------- */

class _UserSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AdminProfileController profileController =
        Get.put(AdminProfileController());
    final RxBool isHovering = false.obs;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
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
                  onTap: () =>
                      _showLogoutConfirmation(context, profileController),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
                      boxShadow: isHovering.value
                          ? [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
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
                            boxShadow: isHovering.value
                                ? [
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.3),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : [],
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
                                        isHovering.value
                                            ? Icons.logout_rounded
                                            : Icons.person,
                                        color: isHovering.value
                                            ? Colors.redAccent
                                            : AppColors.neonGreen,
                                        size: 20,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  isHovering.value
                                      ? Icons.logout_rounded
                                      : Icons.person,
                                  color: isHovering.value
                                      ? Colors.redAccent
                                      : AppColors.neonGreen,
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
                                child: Text(isHovering.value
                                    ? "Sign Out"
                                    : "Admin User"),
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
                                child: Text(isHovering.value
                                    ? "Click to logout"
                                    : "Administrator"),
                              ),
                            ],
                          ),
                        ),
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
                            child: const Icon(
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
        },
      ),
    );
  }

  Future<String> _getUserImageUrl() async {
    return await SharedPrefsHelper.getString(
            SharedPrefsHelper.userImageUrlKey) ??
        "";
  }

  void _showLogoutConfirmation(
      BuildContext context, AdminProfileController controller) {
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
                child: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 36),
              ),
              const SizedBox(height: 24),
              const Text(
                "Sign Out",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.white.withOpacity(0.6)),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
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
                            colors: [
                              Colors.redAccent,
                              Colors.redAccent.withOpacity(0.8)
                            ],
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
                              Icon(Icons.logout_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text("Logout",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
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
}

/* ----------------------- BREADCRUMBS ----------------------- */

class _Crumb {
  final String label;
  final VoidCallback? onTap;
  const _Crumb(this.label, this.onTap);
}

class _BreadcrumbBar extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _BreadcrumbBar({required this.shell});

  String _hubLabel(int i) {
    switch (i) {
      case 0:
        return "Dashboard";
      case 1:
        return "Leads";
      case 2:
        return "Inspection";
      case 3:
        return "Watti";
      case 4:
        return "Price Discovery";
      case 5:
        return "Auction";
      default:
        return "Dashboard";
    }
  }

  String _adminLabel(int i) {
    switch (i) {
      case 0:
        return "Dashboard";
      case 1:
        return "Users";
      case 2:
        return "Customers";
      case 3:
        return "Cars";
      case 4:
        return "Profile";
      case 5:
        return "KAM Management";
      default:
        return "Dashboard";
    }
  }

  // ✅ FIXED: Hub Dashboard should show ONLY "Admin"
  List<_Crumb> _buildCrumbs() {
    if (!shell.inAdminPanel.value) {
      final hub = shell.hubIndex.value;

      if (hub == 0) {
        return [
          _Crumb("Admin", () => shell.selectHub(0)),
        ];
      }

      return [
        _Crumb("Admin", () => shell.selectHub(0)),
        _Crumb(_hubLabel(hub), () => shell.selectHub(hub)),
      ];
    }

    final admin = shell.adminIndex.value;
    return [
      _Crumb("Admin", shell.closeAdminPanel),
      _Crumb(_adminLabel(admin), () => shell.selectAdmin(admin)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final crumbs = _buildCrumbs();

      return GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.account_tree_rounded,
                color: AppColors.textGrey, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: List.generate(crumbs.length, (i) {
                  final c = crumbs[i];
                  final isLast = i == crumbs.length - 1;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: c.onTap,
                        child: Text(
                          c.label,
                          style: TextStyle(
                            color: isLast
                                ? AppColors.neonGreen
                                : AppColors.textWhite.withOpacity(0.9),
                            fontWeight:
                                isLast ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        Text(
                          ">",
                          style: TextStyle(
                            color: AppColors.textGrey.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/* ----------------------- NAV ITEM MODEL ----------------------- */

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
