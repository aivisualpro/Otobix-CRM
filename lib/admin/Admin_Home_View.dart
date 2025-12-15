import 'package:flutter/material.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Ab Home page par center grid nahi hoga.
    // Hover dropdown top tabs se open hoga.
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_rounded,
                color: AppColors.neonGreen, size: 22),
            const SizedBox(width: 12),
            Text(
              "Hover on Home to open quick menu",
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
