import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/controller/app_nav_controller.dart';
import 'package:otobix_crm/utils/app_routes.dart';


class RootShell extends StatelessWidget {
  final Widget child;
  const RootShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<AppNavController>();

    return Scaffold(
      body: Row(
        children: [
          // Left Drawer
          Container(
            width: 240,
            color: const Color(0xFFF5F2D7), // light beige like your wireframe
            child: Obx(() {
              final selected = nav.drawerIndex;

              return ListView(
                children: [
                  const SizedBox(height: 14),
                  _DrawerItem(
                    label: 'Home',
                    selected: selected == 0,
                    onTap: () => nav.go(Routes.home),
                  ),
                  _DrawerItem(
                    label: 'Admin',
                    selected: selected == 1,
                    onTap: () => nav.go(Routes.admin),
                  ),
                  _DrawerItem(
                    label: 'Leads',
                    selected: selected == 2,
                    onTap: () => nav.go(Routes.leads),
                  ),
                  _DrawerItem(
                    label: 'Inspection',
                    selected: selected == 3,
                    onTap: () => nav.go(Routes.inspection),
                  ),
                  _DrawerItem(
                    label: 'Watti',
                    selected: selected == 4,
                    onTap: () => nav.go(Routes.watti),
                  ),
                  _DrawerItem(
                    label: 'Price Discovery',
                    selected: selected == 5,
                    onTap: () => nav.go(Routes.priceDiscovery),
                  ),
                  _DrawerItem(
                    label: 'Auction',
                    selected: selected == 6,
                    onTap: () => nav.go(Routes.auction),
                  ),
                ],
              );
            }),
          ),

          // Right content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
                  ),
                  child: Obx(() {
                    final crumbs = nav.breadcrumbs;
                    final text = crumbs.join('  >  ');
                    return Text(
                      'Breadcrumbs  $text',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    );
                  }),
                ),

                // Page content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(18),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF176) : Colors.transparent, // yellow highlight
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
