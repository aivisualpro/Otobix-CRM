import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/Admin_Home_View.dart';

import 'package:otobix_crm/admin/admin_desktop_customers_page.dart';
import 'package:otobix_crm/admin/admin_desktop_home_page.dart';
import 'package:otobix_crm/admin/admin_desktop_profile_page.dart';
import 'package:otobix_crm/admin/admin_desktop_kam_page.dart';
import 'package:otobix_crm/admin/admin_new_dashboard_page.dart';
import 'package:otobix_crm/admin/admin_desktop_cars_list_page.dart';

import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/widgets/glass_container.dart';
import 'package:otobix_crm/utils/url_helper.dart';

class AdminDesktopDashboard extends StatelessWidget {
  const AdminDesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminDesktopShellController shell =
        Get.put(AdminDesktopShellController(), permanent: true);

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
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18),
              child: _TopTabsBar(shell: shell),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 18),
              child: _BreadcrumbBar(shell: shell),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
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
    );
  }
}

/* ----------------------- TOP TABS BAR (FIXED ALWAYS) ----------------------- */

class _TopTabsBar extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _TopTabsBar({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final inAdmin = shell.inAdminPanel.value;
      final inLeads = shell.inLeadsPanel.value;

      // ✅ KEY FIX: If admin opened from Home dropdown, Home should remain active
      final openedFromHome = inAdmin && shell.adminOrigin.value == "home";

      final fixedTabs = <_TopTab>[
        _TopTab(
          label: "Home",
          icon: Icons.dashboard_customize_outlined,
          isActive: !inLeads &&
              (((!inAdmin) && shell.hubIndex.value == 0) || openedFromHome),
          onTap: () => shell.selectHub(0),
          hoverItems: [
            _HoverMenuItem(
              label: "Dashboard",
              icon: Icons.dashboard_customize_rounded,
              onTap: () => shell.openAdminFromHome(0),
            ),
            _HoverMenuItem(
              label: "Users",
              icon: Icons.group_outlined,
              onTap: () => shell.openAdminFromHome(1),
            ),
            _HoverMenuItem(
              label: "Cars",
              icon: Icons.directions_car_outlined,
              onTap: () => shell.openAdminFromHome(3),
            ),
            _HoverMenuItem(
              label: "Profile",
              icon: Icons.person_outline,
              onTap: () => shell.openAdminFromHome(4),
            ),
            _HoverMenuItem(
              label: "KAM Management",
              icon: Icons.manage_accounts_outlined,
              onTap: () => shell.openAdminFromHome(5),
            ),
          ],
        ),
        _TopTab(
          label: "Admin",
          icon: Icons.admin_panel_settings_outlined,
          isActive: inAdmin && !openedFromHome,
          onTap: () => shell.openAdminPanel(),
          hoverItems: [
            _HoverMenuItem(
              label: "Staff",
              icon: Icons.grid_view_outlined,
              onTap: () => shell.selectAdmin(1, origin: "admin"),
            ),
            _HoverMenuItem(
              label: "Dropdowns",
              icon: Icons.arrow_drop_down_circle_outlined,
              onTap: () => shell.selectAdmin(6, origin: "admin"),
            ),
            _HoverMenuItem(
              label: "Banners",
              icon: Icons.photo_library_outlined,
              onTap: () => shell.selectAdmin(7, origin: "admin"),
            ),
            _HoverMenuItem(
              label: "Settings",
              icon: Icons.settings_outlined,
              onTap: () => shell.selectAdmin(8, origin: "admin"),
            ),
          ],
        ),
        _TopTab(
          label: "Leads",
          icon: Icons.leaderboard_outlined,
          isActive: inLeads,
          onTap: () => shell.openLeadsPanel(),
          hoverItems: [
            _HoverMenuItem(
              label: "Telecalling",
              icon: Icons.call_outlined,
              onTap: () => shell.selectLeads(0),
            ),
            _HoverMenuItem(
              label: "Customer Request",
              icon: Icons.request_page_outlined,
              onTap: () => shell.selectLeads(1),
            ),
            _HoverMenuItem(
              label: "Allocation",
              icon: Icons.assignment_turned_in_outlined,
              onTap: () => shell.selectLeads(2),
            ),
          ],
        ),
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

      return GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: fixedTabs
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

/* ----------------------- BREADCRUMBS BAR (LEFT + CENTER + RIGHT TABS) ----------------------- */

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
    // LEADS
    if (shell.inLeadsPanel.value) {
      final leads = shell.leadsIndex.value;
      if (leads == -1) return [_Crumb("Leads", null)];
      return [
        _Crumb("Leads", shell.openLeadsPanel),
        _Crumb(_leadsLabel(leads), null),
      ];
    }

    // HUB
    if (!shell.inAdminPanel.value) {
      return [_Crumb(_hubLabel(shell.hubIndex.value), null)];
    }

    // ADMIN
    final admin = shell.adminIndex.value;
    if (admin == -1) return [_Crumb("Admin", null)];

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

      // ✅ Only show on Admin Dashboard page
      final showTopDashboardTabs =
          shell.inAdminPanel.value && shell.adminIndex.value == 0;

      return GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            // LEFT : Breadcrumbs
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                                    fontWeight: isLast
                                        ? FontWeight.w800
                                        : FontWeight.w600,
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
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // CENTER : Search
            Expanded(
              flex: 1,
              child: _BreadcrumbSearchField(
                hintText: "Search...",
                onChanged: (v) {},
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: showTopDashboardTabs
                    ? _DashboardPillTabsControlled(
                        activeIndex: shell.dashboardTab,
                        tabs: const ["Inspection", "Customers", "Auction"],
                      )
                    : const SizedBox.shrink(),
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

/* ----------------------- Search Field ----------------------- */

class _BreadcrumbSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const _BreadcrumbSearchField({
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.textWhite,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textGrey.withOpacity(0.9),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textGrey, size: 18),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.neonGreen.withOpacity(0.55),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------- Dashboard pill tabs (RIGHT in Breadcrumb bar) ----------------------- */

class _DashboardPillTabsControlled extends StatelessWidget {
  final RxInt activeIndex;
  final List<String> tabs;

  const _DashboardPillTabsControlled({
    required this.activeIndex,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = activeIndex.value;

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(tabs.length, (i) {
            final isActive = i == active;

            return InkWell(
              onTap: () => activeIndex.value = i,
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.neonGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: isActive ? Colors.black : AppColors.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

/* ----------------------- TOP TAB MODEL + CHIP (HOVER DROPDOWN) ----------------------- */

class _TopTab {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final List<_HoverMenuItem>? hoverItems;

  _TopTab({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isActive,
    this.hoverItems,
  });
}

class _HoverMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _HoverMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _TopTabChip extends StatefulWidget {
  final _TopTab tab;
  const _TopTabChip({required this.tab});

  @override
  State<_TopTabChip> createState() => _TopTabChipState();
}

class _TopTabChipState extends State<_TopTabChip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  bool _hoveringChip = false;
  bool _hoveringMenu = false;
  Timer? _closeTimer;

  bool get _hasMenu =>
      widget.tab.hoverItems != null && widget.tab.hoverItems!.isNotEmpty;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _removeMenu();
    super.dispose();
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 120), () {
      if (!_hoveringChip && !_hoveringMenu) _removeMenu();
    });
  }

  void _removeMenu() {
    _entry?.remove();
    _entry = null;
  }

  void _openMenu() {
    if (!_hasMenu) return;
    if (_entry != null) return;

    _entry = OverlayEntry(
      builder: (ctx) {
        return Positioned.fill(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeMenu,
                child: const SizedBox.expand(),
              ),
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                offset: const Offset(0, 48),
                child: Material(
                  color: Colors.transparent,
                  child: MouseRegion(
                    onEnter: (_) {
                      _hoveringMenu = true;
                      _closeTimer?.cancel();
                    },
                    onExit: (_) {
                      _hoveringMenu = false;
                      _scheduleClose();
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.tab.hoverItems!.map((item) {
                            return InkWell(
                              onTap: () {
                                _removeMenu();
                                item.onTap();
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(item.icon,
                                        size: 18, color: AppColors.neonGreen),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: const TextStyle(
                                          color: AppColors.textWhite,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.textGrey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.tab.isActive;

    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) {
          _hoveringChip = true;
          if (_hasMenu) _openMenu();
        },
        onExit: (_) {
          _hoveringChip = false;
          _scheduleClose();
        },
        child: InkWell(
          onTap: widget.tab.onTap,
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
                  widget.tab.icon,
                  size: 18,
                  color: active ? AppColors.neonGreen : AppColors.textGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.tab.label,
                  style: TextStyle(
                    color: active ? AppColors.neonGreen : AppColors.textGrey,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                if (_hasMenu) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: active ? AppColors.neonGreen : AppColors.textGrey,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------- HUB BODY ----------------------- */

class _HubBody extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _HubBody({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = shell.hubIndex.value;

      if (shell.inLeadsPanel.value) return _LeadsPanelBody(shell: shell);

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

/* ----------------------- LEADS PANEL BODY ----------------------- */

class _LeadsPanelBody extends StatelessWidget {
  final AdminDesktopShellController shell;
  const _LeadsPanelBody({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = shell.leadsIndex.value;

      if (idx == -1) return LeadsPanelHomeView(shell: shell);

      final pages = <int, Widget>{
        0: const _LeadsPlaceholderPage(title: "Telecalling Page"),
        1: const _LeadsPlaceholderPage(title: "Customer Request Page"),
        2: const _LeadsPlaceholderPage(title: "Allocation Page"),
      };

      return pages[idx] ?? LeadsPanelHomeView(shell: shell);
    });
  }
}

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
          // ✅ IMPORTANT: AdminNewDashboardPage uses shell.dashboardTab
          mobile: AdminNewDashboardPage(dashboardTab: shell.dashboardTab),
          desktop: AdminNewDashboardPage(dashboardTab: shell.dashboardTab),
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

/* ----------------------- SHARED TILE ----------------------- */

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

/* =======================================================================
   ✅ SINGLE CONTROLLER + Dashboard tab state (used in Breadcrumb right tabs)
   ======================================================================= */

class AdminDesktopShellController extends GetxController {
  final RxBool inAdminPanel = false.obs;
  final RxInt hubIndex = 0.obs;
  final RxInt adminIndex = (-1).obs;
  final RxString adminOrigin = "".obs;

  final RxBool inLeadsPanel = false.obs;
  final RxInt leadsIndex = (-1).obs;

  // ✅ Dashboard inner tabs state: 0=Inspection, 1=Customer, 2=Auction
  final RxInt dashboardTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _applyPath(UrlHelper.getPath());
    UrlHelper.onPop(_applyPath);
  }

  /* ---------------- HUB ---------------- */

  void selectHub(int i) {
    inAdminPanel.value = false;
    inLeadsPanel.value = false;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "";
    hubIndex.value = i;
    UrlHelper.setPath(_hubToPath(i));
  }

  void backToHome() => selectHub(0);

  /* ---------------- ADMIN ---------------- */

  void openAdminPanel() {
    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "admin";
    UrlHelper.setPath('/admin');
  }

  void openAdminFromHome(int pageIndex) {
    hubIndex.value = 0;
    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = pageIndex;
    leadsIndex.value = -1;
    adminOrigin.value = "home";
    UrlHelper.setPath('${_adminToPath(pageIndex)}?origin=home');
  }

  void selectAdmin(int i, {String? origin}) {
    inAdminPanel.value = true;
    inLeadsPanel.value = false;
    adminIndex.value = i;
    leadsIndex.value = -1;

    adminOrigin.value = origin ?? adminOrigin.value;
    if (adminOrigin.value.isEmpty) adminOrigin.value = "admin";

    if (i == -1) {
      UrlHelper.setPath('/admin');
      return;
    }
    UrlHelper.setPath('${_adminToPath(i)}?origin=${adminOrigin.value}');
  }

  /* ---------------- LEADS ---------------- */

  void openLeadsPanel() {
    inLeadsPanel.value = true;
    inAdminPanel.value = false;
    leadsIndex.value = -1;
    adminIndex.value = -1;
    adminOrigin.value = "";
    UrlHelper.setPath('/leads');
  }

  void selectLeads(int i) {
    inLeadsPanel.value = true;
    inAdminPanel.value = false;
    leadsIndex.value = i;
    adminIndex.value = -1;
    adminOrigin.value = "";

    if (i == -1) {
      UrlHelper.setPath('/leads');
      return;
    }
    UrlHelper.setPath(_leadsToPath(i));
  }

  /* ---------------- PATHS ---------------- */

  String _hubToPath(int i) {
    switch (i) {
      case 0:
        return '/home';
      case 1:
        return '/leads';
      case 2:
        return '/inspection';
      case 3:
        return '/price-discovery';
      case 4:
        return '/auction';
      default:
        return '/home';
    }
  }

  String _adminToPath(int i) {
    switch (i) {
      case 0:
        return '/admin/dashboard';
      case 1:
        return '/admin/users';
      case 2:
        return '/admin/customers';
      case 3:
        return '/admin/cars';
      case 4:
        return '/admin/profile';
      case 5:
        return '/admin/kam-management';
      case 6:
        return '/admin/dropdowns';
      case 7:
        return '/admin/banners';
      case 8:
        return '/admin/settings';
      default:
        return '/admin';
    }
  }

  String _leadsToPath(int i) {
    switch (i) {
      case 0:
        return '/leads/telecalling';
      case 1:
        return '/leads/customer-request';
      case 2:
        return '/leads/allocation';
      default:
        return '/leads';
    }
  }

  /* ---------------- URL RESTORE ---------------- */

  void _applyPath(String rawPath) {
    final parts = rawPath.split('?');
    final path = parts.first;
    final query =
        parts.length > 1 ? Uri.splitQueryString(parts[1]) : <String, String>{};

    inAdminPanel.value = false;
    inLeadsPanel.value = false;
    hubIndex.value = 0;
    adminIndex.value = -1;
    leadsIndex.value = -1;
    adminOrigin.value = "";

    // ADMIN
    if (path.startsWith('/admin')) {
      inAdminPanel.value = true;

      final adminRoutes = {
        '/admin/dashboard': 0,
        '/admin/users': 1,
        '/admin/customers': 2,
        '/admin/cars': 3,
        '/admin/profile': 4,
        '/admin/kam-management': 5,
        '/admin/dropdowns': 6,
        '/admin/banners': 7,
        '/admin/settings': 8,
      };

      if (adminRoutes.containsKey(path)) {
        adminIndex.value = adminRoutes[path]!;
        adminOrigin.value = query['origin'] ?? "admin";
        if (adminOrigin.value == "home") hubIndex.value = 0;
      } else {
        adminIndex.value = -1;
        adminOrigin.value = "admin";
      }
      return;
    }

    // LEADS
    if (path.startsWith('/leads')) {
      inLeadsPanel.value = true;

      final leadsRoutes = {
        '/leads/telecalling': 0,
        '/leads/customer-request': 1,
        '/leads/allocation': 2,
      };

      leadsIndex.value = leadsRoutes[path] ?? -1;
      return;
    }

    // HUB
    final hubRoutes = {
      '/home': 0,
      '/leads': 1,
      '/inspection': 2,
      '/price-discovery': 3,
      '/auction': 4,
    };

    if (hubRoutes.containsKey(path)) {
      hubIndex.value = hubRoutes[path]!;
    }
  }
}
