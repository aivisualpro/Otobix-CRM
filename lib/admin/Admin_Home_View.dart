import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/controller/admin_shell_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Agar controller already registered hai, toh usko use karein.
    // Agar nahi hai, toh Get.put se register karein (jo AdminDesktopDashboard mein ho chuka hai).
    final shell = Get.isRegistered<AdminDesktopShellController>()
        ? Get.find<AdminDesktopShellController>()
        : Get.put(AdminDesktopShellController(), permanent: true);

    final tiles = <_HubTile>[
      _HubTile(
        title: "Dashboard",
        icon: Icons.dashboard_customize_rounded,
        // openAdminFromHome(0) call karega, jisse adminOrigin = "home" set hoga.
        onTap: () => shell.openAdminFromHome(0),
      ),
      _HubTile(
        title: "Users",
        icon: Icons.group_outlined,
        // onTap: () => shell.openAdminFromHome(1),
      ),
      _HubTile(
        title: "Cars",
        icon: Icons.directions_car_outlined,
        // onTap: () => shell.openAdminFromHome(3),
      ),
      _HubTile(
        title: "Profile",
        icon: Icons.person_outline,
        // onTap: () => shell.openAdminFromHome(4),
      ),
      _HubTile(
        title: "KAM Management",
        icon: Icons.manage_accounts_outlined,
        // onTap: () => shell.openAdminFromHome(5),
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
  final VoidCallback? onTap;

  _HubTile({
    required this.title,
    required this.icon,
    this.onTap,
  });
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
                border:
                    Border.all(color: AppColors.neonGreen.withOpacity(0.25)),
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
