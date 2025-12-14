import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/Admin_Home_View.dart';

import 'package:otobix_crm/admin/admin_desktop_customers_page.dart';
import 'package:otobix_crm/admin/admin_desktop_home_page.dart';
import 'package:otobix_crm/admin/admin_desktop_profile_page.dart';
import 'package:otobix_crm/admin/admin_desktop_kam_page.dart';
import 'package:otobix_crm/admin/admin_new_dashboard_page.dart';
import 'package:otobix_crm/admin/admin_desktop_cars_list_page.dart';

import 'package:otobix_crm/admin/controller/admin_shell_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class AdminDesktopDashboard extends StatelessWidget {
  const AdminDesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Agar controller already permanent: true ke saath register hai, toh Get.put() usko hi wapas karega.
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
              child: _TopTabsBar(shell: shell),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: _BreadcrumbBar(shell: shell),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: Obx(() {
                  // Hub body default hai jab tak inAdminPanel true na ho.
                  // Agar aap chahte hain ki App start par AdminHomeView ho
                  // aur inAdminPanel false ho (jaisa aapka code dikha raha hai),
                  // toh yeh theek hai.
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
    );
  }
}

/* ----------------------- TOP TABS BAR (FIXED) ----------------------- */

class _TopTabsBar extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _TopTabsBar({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inAdmin = shell.inAdminPanel.value;
      final isAdminModulesHome = inAdmin && shell.adminIndex.value == -1;
      final isOnAdminPage = inAdmin && shell.adminIndex.value != -1;

      // ***************** NEW LEADS LOGIC *****************
      final inLeads = shell.inLeadsPanel.value;
      final isLeadsModulesHome = inLeads && shell.leadsIndex.value == -1;
      final isOnLeadsPage = inLeads && shell.leadsIndex.value != -1;
      // ****************************************************

      // HUB TABS
      final hubTabs = <_TopTab>[
        _TopTab(
          label: "Home",
          icon: Icons.dashboard_customize_outlined,
          isActive: !inAdmin && !inLeads && shell.hubIndex.value == 0,
          onTap: () => shell.selectHub(0),
        ),
        _TopTab(
          label: "Admin",
          icon: Icons.admin_panel_settings_outlined,
          isActive: isAdminModulesHome,
          onTap: () => shell.openAdminPanel(),
        ),
        // ***************** LEADS MODULE HOME BUTTON *****************
        _TopTab(
          label: "Leads",
          icon: Icons.leaderboard_outlined,
          isActive: isLeadsModulesHome,
          onTap: () => shell.openLeadsPanel(),
        ),
        // *************************************************************
        _TopTab(
          label: "Inspection",
          icon: Icons.fact_check_outlined,
          isActive: !inAdmin && !inLeads && shell.hubIndex.value == 2,
          onTap: () => shell.selectHub(2),
        ),
        _TopTab(
          label: "Price Discovery",
          icon: Icons.price_change_outlined,
          isActive: !inAdmin && !inLeads && shell.hubIndex.value == 3,
          onTap: () => shell.selectHub(3),
        ),
        _TopTab(
          label: "Auction",
          icon: Icons.gavel_outlined,
          isActive: !inAdmin && !inLeads && shell.hubIndex.value == 4,
          onTap: () => shell.selectHub(4),
        ),
      ];

      // ADMIN TABS (FIXED: Admin tab sirf tabhi aayega jab origin "admin" ho)
      final adminTabs = <_TopTab>[
        _TopTab(
          label: "Dashboard",
          icon: Icons.dashboard_customize_outlined,
          isActive: shell.adminIndex.value == 0,
          onTap: () => shell.selectAdmin(0),
        ),
        _TopTab(
          label: "Users",
          icon: Icons.grid_view_outlined,
          isActive: shell.adminIndex.value == 1,
          onTap: () => shell.selectAdmin(1),
        ),
        _TopTab(
          label: "Customers",
          icon: Icons.people_outline,
          isActive: shell.adminIndex.value == 2,
          onTap: () => shell.selectAdmin(2),
        ),
        _TopTab(
          label: "Cars",
          icon: Icons.directions_car_outlined,
          isActive: shell.adminIndex.value == 3,
          onTap: () => shell.selectAdmin(3),
        ),
        _TopTab(
          label: "Profile",
          icon: Icons.person_outline,
          isActive: shell.adminIndex.value == 4,
          onTap: () => shell.selectAdmin(4),
        ),
        _TopTab(
          label: "KAM",
          icon: Icons.manage_accounts_outlined,
          isActive: shell.adminIndex.value == 5,
          onTap: () => shell.selectAdmin(5),
        ),
      ];

      // ***************** NEW LEADS TABS *****************
      final leadsTabs = <_TopTab>[
        _TopTab(
          label: "Telecalling",
          icon: Icons.call_outlined,
          isActive: shell.leadsIndex.value == 0,
          onTap: () => shell.selectLeads(0),
        ),
        _TopTab(
          label: "Customer Request",
          icon: Icons.request_page_outlined,
          isActive: shell.leadsIndex.value == 1,
          onTap: () => shell.selectLeads(1),
        ),
        _TopTab(
          label: "Allocation",
          icon: Icons.assignment_turned_in_outlined,
          isActive: shell.leadsIndex.value == 2,
          onTap: () => shell.selectLeads(2),
        ),
      ];
      // ****************************************************

      // Agar kisi admin page par hain (i != -1) toh adminTabs dikhao,
      // agar kisi leads page par hain toh leadsTabs dikhao,
      // warna HubTabs dikhao (jismein Admin modules home ka button bhi hai).
      final List<_TopTab> tabs;
      if (isOnAdminPage) {
        tabs = adminTabs;
      } else if (isOnLeadsPage) {
        tabs = leadsTabs;
      } else {
        tabs = hubTabs;
      }

      return GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.apps_rounded, color: AppColors.textGrey, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tabs
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: _TopTabChip(tab: t),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/* ----------------------- BREADCRUMBS BAR ----------------------- */

class _BreadcrumbBar extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _BreadcrumbBar({required this.shell});

  String _hubLabel(int i) {
    switch (i) {
      case 0:
        return "Home";
      case 1:
        return "Leads";
      case 2:
        return "Inspection";
      case 3:
        return "Price Discovery";
      case 4:
        return "Auction";
      default:
        return "Home";
    }
  }

  // ***************** NEW LEADS LABEL METHOD *****************
  String _leadsLabel(int i) {
    switch (i) {
      case -1:
        return "Leads";
      case 0:
        return "Telecalling";
      case 1:
        return "Customer Request";
      case 2:
        return "Allocation";
      default:
        return "Leads";
    }
  }
  // ****************************************************

  String _adminLabel(int i) {
    switch (i) {
      case -1:
        return "Admin";
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
      case 6:
        return "Dropdowns";
      case 7:
        return "Banners";
      case 8:
        return "Settings";
      default:
        return "Admin";
    }
  }

  List<_Crumb> _buildCrumbs() {
    // ***************** LEADS CRUMBS *****************
    if (shell.inLeadsPanel.value) {
      final leads = shell.leadsIndex.value;

      // Leads modules grid: sirf "Leads"
      if (leads == -1) {
        return [
          _Crumb("Leads", null),
        ];
      }

      // Leads sub-page: Leads > Sub-Page
      return [
        _Crumb("Leads", shell.openLeadsPanel),
        _Crumb(_leadsLabel(leads), null),
      ];
    }
    // ****************************************************

    // HUB: sirf current label
    if (!shell.inAdminPanel.value) {
      return [
        _Crumb(_hubLabel(shell.hubIndex.value), null),
      ];
    }

    final admin = shell.adminIndex.value;

    // Admin modules grid: sirf "Admin"
    if (admin == -1) {
      return [
        _Crumb("Admin", null),
      ];
    }

    // Admin page:
    // origin=admin => Admin > Page
    // origin=home  => Home > Page
    if (shell.adminOrigin.value == "home") {
      return [
        _Crumb("Home", shell.backToHome),
        _Crumb(_adminLabel(admin), null),
      ];
    }

    return [
      _Crumb("Admin", shell.openAdminPanel),
      _Crumb(_adminLabel(admin), null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final crumbs = _buildCrumbs();

      return GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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

class _Crumb {
  final String label;
  final VoidCallback? onTap;
  const _Crumb(this.label, this.onTap);
}

/* ----------------------- TOP TAB MODEL + CHIP ----------------------- */

class _TopTab {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  _TopTab({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isActive,
  });
}

class _TopTabChip extends StatelessWidget {
  final _TopTab tab;
  const _TopTabChip({required this.tab});

  @override
  Widget build(BuildContext context) {
    final active = tab.isActive;

    return InkWell(
      onTap: tab.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.neonGreen.withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? AppColors.neonGreen.withOpacity(0.55)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 18,
              color: active ? AppColors.neonGreen : AppColors.textGrey,
            ),
            const SizedBox(width: 8),
            Text(
              tab.label,
              style: TextStyle(
                color: active ? AppColors.neonGreen : AppColors.textGrey,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12.5,
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = shell.hubIndex.value;

      // ***************** CHECK IF LEADS PANEL IS ACTIVE *****************
      if (shell.inLeadsPanel.value) return _LeadsPanelBody(shell: shell);
      // ******************************************************************

      if (idx == 0) return const AdminHomeView();

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

  String _hubLabel(int i) {
    switch (i) {
      case 0:
        return "Home";
      case 1:
        return "Leads";
      case 2:
        return "Inspection";
      case 3:
        return "Price Discovery";
      case 4:
        return "Auction";
      default:
        return "Home";
    }
  }
}

/* ***************** LEADS PANEL BODY (NEW) ***************** */

class _LeadsPanelBody extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _LeadsPanelBody({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = shell.leadsIndex.value;

      if (idx == -1) return LeadsPanelHomeView(shell: shell);

      // Leads sub-pages ki mapping
      final pages = <int, Widget>{
        0: const _LeadsPlaceholderPage(title: "Telecalling Page"),
        1: const _LeadsPlaceholderPage(title: "Customer Request Page"),
        2: const _LeadsPlaceholderPage(title: "Allocation Page"),
      };

      return pages[idx] ?? LeadsPanelHomeView(shell: shell);
    });
  }
}

/* ***************** LEADS MODULES GRID VIEW (NEW) ***************** */

class LeadsPanelHomeView extends StatelessWidget {
  final AdminDesktopShellController shell;
  const LeadsPanelHomeView({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final tiles = <_HubTile>[
      _HubTile(
        title: "Telecalling",
        icon: Icons.call_outlined,
        onTap: () => shell.selectLeads(0),
      ),
      _HubTile(
        title: "Customer Request",
        icon: Icons.request_page_outlined,
        onTap: () => shell.selectLeads(1),
      ),
      _HubTile(
        title: "Allocation",
        icon: Icons.assignment_turned_in_outlined,
        onTap: () => shell.selectLeads(2),
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cross = w >= 900 ? 3 : (w >= 600 ? 2 : 1);

            return GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: tiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 2.3,
              ),
              itemBuilder: (context, i) => _HubTileCard(tile: tiles[i]),
            );
          },
        ),
      ),
    );
  }
}

/* ***************** NEW LEADS PLACEHOLDER PAGE ***************** */
class _LeadsPlaceholderPage extends StatelessWidget {
  final String title;
  const _LeadsPlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
// **************************************************************

/* ----------------------- ADMIN PANEL BODY ----------------------- */

class _AdminPanelBody extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _AdminPanelBody({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = shell.adminIndex.value;

      if (idx == -1) return AdminPanelHomeView(shell: shell);

      final pages = <int, Widget>{
        0: ResponsiveLayout(
          mobile: AdminNewDashboardPage(),
          desktop: AdminNewDashboardPage(),
        ),
        1: ResponsiveLayout(
          mobile: AdminDesktopHomePage(),
          desktop: AdminDesktopHomePage(),
        ),
        2: ResponsiveLayout(
          mobile: AdminDesktopCustomersPage(),
          desktop: AdminDesktopCustomersPage(),
        ),
        3: ResponsiveLayout(
          mobile: AdminDesktopCarsListPage(),
          desktop: AdminDesktopCarsListPage(),
        ),
        4: ResponsiveLayout(
          mobile: AdminDesktopProfilePage(),
          desktop: AdminDesktopProfilePage(),
        ),
        5: ResponsiveLayout(
          mobile: AdminDesktopKamPage(),
          desktop: AdminDesktopKamPage(),
        ),
        6: const _AdminPlaceholderPage(title: "Dropdowns"),
        7: const _AdminPlaceholderPage(title: "Banners"),
        8: const _AdminPlaceholderPage(title: "Settings"),
      };

      return pages[idx] ?? AdminPanelHomeView(shell: shell);
    });
  }
}

/* ----------------------- ADMIN MODULES GRID VIEW ----------------------- */

class AdminPanelHomeView extends StatelessWidget {
  final AdminDesktopShellController shell;
  const AdminPanelHomeView({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final tiles = <_HubTile>[
      _HubTile(
        title: "Users",
        icon: Icons.group_outlined,
        onTap: () => shell.selectAdmin(1, origin: "admin"),
      ),
      _HubTile(
        title: "Dropdowns",
        icon: Icons.arrow_drop_down_circle_outlined,
        onTap: () => shell.selectAdmin(6, origin: "admin"),
      ),
      _HubTile(
        title: "Banners",
        icon: Icons.photo_library_outlined,
        onTap: () => shell.selectAdmin(7, origin: "admin"),
      ),
      _HubTile(
        title: "Settings",
        icon: Icons.settings_outlined,
        onTap: () => shell.selectAdmin(8, origin: "admin"),
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cross = w >= 900 ? 3 : (w >= 600 ? 2 : 1);

            return GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(12),
              itemCount: tiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 2.3,
              ),
              itemBuilder: (context, i) => _HubTileCard(tile: tiles[i]),
            );
          },
        ),
      ),
    );
  }
}

class _HubTile {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _HubTile({required this.title, required this.icon, required this.onTap});
}

class _HubTileCard extends StatelessWidget {
  final _HubTile tile;
  const _HubTileCard({required this.tile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tile.onTap,
      borderRadius: BorderRadius.circular(18),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.neonGreen.withOpacity(0.25),
                ),
              ),
              child: Icon(tile.icon, color: AppColors.neonGreen, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                tile.title,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.neonGreen,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPlaceholderPage extends StatelessWidget {
  final String title;
  const _AdminPlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
