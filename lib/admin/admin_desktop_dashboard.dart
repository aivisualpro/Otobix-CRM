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
import 'package:otobix_crm/admin/controller/admin_home_controller.dart';
import 'package:otobix_crm/admin/controller/admin_shell_controller.dart';

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

      // ✅ If admin opened from Home dropdown, Home should remain active
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
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _TopTabChip(tab: t),
                        ),
                      )
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
    final crumbs = <_Crumb>[];

    if (shell.inLeadsPanel.value) {
      crumbs.add(_Crumb("Leads", () => shell.openLeadsPanel()));
      if (shell.leadsIndex.value != -1) {
        crumbs.add(_Crumb(_leadsLabel(shell.leadsIndex.value), null));
      }
    } else if (shell.inAdminPanel.value) {
      // If opened from Home dropdown, show Home first
      if (shell.adminOrigin.value == "home") {
        crumbs.add(_Crumb("Home", () => shell.selectHub(0)));
      } else {
        crumbs.add(_Crumb("Admin", () => shell.openAdminPanel()));
      }

      if (shell.adminIndex.value != -1) {
        crumbs.add(_Crumb(_adminLabel(shell.adminIndex.value), null));
      }
    } else {
      crumbs.add(_Crumb(_hubLabel(shell.hubIndex.value), null));
    }

    return crumbs;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final crumbs = _buildCrumbs();

      final showTopDashboardTabs =
          shell.inAdminPanel.value && shell.adminIndex.value == 0;

      final showUsersControls =
          shell.inAdminPanel.value && shell.adminIndex.value == 1;

      AdminHomeController? usersCtrl;
      if (showUsersControls) {
        usersCtrl = Get.isRegistered<AdminHomeController>()
            ? Get.find<AdminHomeController>()
            : Get.put(AdminHomeController(), permanent: true);
      }

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

            // CENTER : Search (Users page -> bind to AdminHomeController)
            Expanded(
              flex: 1,
              child: _BreadcrumbSearchField(
                controller: usersCtrl?.searchController,
                hintText: showUsersControls ? "Search users..." : "Search...",
                onChanged: (v) {
                  if (showUsersControls && usersCtrl != null) {
                    usersCtrl.searchQuery.value = v.toLowerCase();
                  }
                },
              ),
            ),

            const SizedBox(width: 14),

            // RIGHT : Dashboard pill tabs OR Users controls
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: showTopDashboardTabs
                    ? _DashboardPillTabsControlled(
                        activeIndex: shell.dashboardTab,
                        tabs: const ["Inspection", "Customers", "Auction"],
                      )
                    : (showUsersControls
                        ? _UsersHeaderControls(controller: usersCtrl!)
                        : const SizedBox.shrink()),
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
  final TextEditingController? controller;

  const _BreadcrumbSearchField({
    required this.hintText,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
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
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textGrey,
            size: 18,
          ),
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

/// ✅ Liquid drop reveal animation for dropdown (top -> bottom)
class _LiquidDropReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _LiquidDropReveal({
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  @override
  State<_LiquidDropReveal> createState() => _LiquidDropRevealState();
}

class _LiquidDropRevealState extends State<_LiquidDropReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = CurvedAnimation(parent: _c, curve: widget.curve).value;

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * -12),
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: t,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopTabChip extends StatefulWidget {
  final _TopTab tab;

  const _TopTabChip({
    required this.tab,
  });

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
                      child: _LiquidDropReveal(
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

      // Leads panel already handles its own view
      if (shell.inLeadsPanel.value) return _LeadsPanelBody(shell: shell);

      // ✅ Home par ab "Home" text center me nahi
      // ✅ Admin jaise center me tiles/grid show hoga
      if (idx == 0) return HomeHubView(shell: shell);

      // baqi hubs same
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

/* ----------------------- HOME HUB VIEW (CENTER TILES) ----------------------- */

class HomeHubView extends StatelessWidget {
  final AdminDesktopShellController shell;
  const HomeHubView({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final tiles = <_HubTile>[
      _HubTile(
        title: "Dashboard",
        icon: Icons.dashboard_customize_rounded,
        onTap: () => shell.openAdminFromHome(0),
      ),
      _HubTile(
        title: "Users",
        icon: Icons.group_outlined,
        onTap: () => shell.openAdminFromHome(1),
      ),
      _HubTile(
        title: "Cars",
        icon: Icons.directions_car_outlined,
        onTap: () => shell.openAdminFromHome(3),
      ),
      _HubTile(
        title: "Profile",
        icon: Icons.person_outline,
        onTap: () => shell.openAdminFromHome(4),
      ),
      _HubTile(
        title: "KAM Management",
        icon: Icons.manage_accounts_outlined,
        onTap: () => shell.openAdminFromHome(5),
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

/* ----------------------- USERS HEADER CONTROLS ----------------------- */

class _UsersHeaderControls extends StatelessWidget {
  final AdminHomeController controller;
  const _UsersHeaderControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.selectedRoles.length > 1 ||
          (controller.selectedRoles.length == 1 &&
              !controller.selectedRoles.contains('All'));

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UsersTabSelector(controller: controller),
            const SizedBox(width: 12),
            SizedBox(
              height: 42,
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.filter_alt_outlined,
                  size: 18,
                  color: isActive ? Colors.black : AppColors.textGrey,
                ),
                label: Text(
                  'Filter',
                  style: TextStyle(
                    color: isActive ? Colors.black : AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      isActive ? AppColors.neonGreen : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: isActive
                        ? AppColors.neonGreen
                        : Colors.white.withOpacity(0.10),
                  ),
                ),
                onPressed: () => _showRoleFilterDialog(context, controller),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showRoleFilterDialog(
    BuildContext context,
    AdminHomeController getxController,
  ) {
    final roles = getxController.roles;

    final RxList<String> tempSelected =
        RxList<String>.from(getxController.selectedRoles);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: GlassContainer(
          width: 500,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Obx(
              () => Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter Users by Role",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        if (tempSelected.length > 1 ||
                            (tempSelected.length == 1 &&
                                !tempSelected.contains('All')))
                          TextButton(
                            onPressed: () => tempSelected.assignAll(['All']),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: roles.map((role) {
                        final isSelected = tempSelected.contains(role);

                        return GestureDetector(
                          onTap: () {
                            if (role == 'All') {
                              tempSelected.assignAll(['All']);
                              return;
                            }

                            if (tempSelected.contains(role)) {
                              tempSelected.remove(role);
                            } else {
                              tempSelected.remove('All');
                              tempSelected.add(role);
                            }

                            if (tempSelected.isEmpty) {
                              tempSelected.assignAll(['All']);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.neonGreen
                                  : const Color(0xFF2A3040),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.neonGreen
                                    : Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.neonGreen
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(Icons.check,
                                      color: Colors.black, size: 16),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  role,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                  color: AppColors.glassBorder),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textGrey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              getxController.applyRoleSelection(
                                List<String>.from(tempSelected),
                              );
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonGreen,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UsersTabSelector extends StatelessWidget {
  final AdminHomeController controller;
  const _UsersTabSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2430).withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tab("Pending", 0, controller.pendingUsersLength.value,
                Colors.orange),
            _tab("Approved", 1, controller.approvedUsersLength.value,
                AppColors.neonGreen),
            _tab("Rejected", 2, controller.rejectedUsersLength.value,
                Colors.redAccent),
          ],
        ),
      );
    });
  }

  Widget _tab(String title, int index, int count, Color activeColor) {
    final isSelected = controller.currentTabIndex.value == index;

    return GestureDetector(
      onTap: () => controller.currentTabIndex.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withOpacity(0.2)
                    : activeColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : activeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textWhite,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
