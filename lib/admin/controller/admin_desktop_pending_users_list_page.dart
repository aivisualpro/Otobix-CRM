import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_pending_users_list_controller.dart';
import 'package:otobix_crm/models/user_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/hero_dialog_route.dart';
import 'package:otobix_crm/widgets/empty_data_widget.dart';
import 'package:otobix_crm/widgets/expanded_user_card_dialog.dart';
import 'package:otobix_crm/widgets/shimmer_widget.dart';
import 'dart:ui' as ui;

class AdminDesktopPendingUsersListPage extends StatefulWidget {
  final RxString searchQuery;
  final RxList<String> selectedRoles;
  const AdminDesktopPendingUsersListPage({
    super.key,
    required this.searchQuery,
    required this.selectedRoles,
  });

  @override
  State<AdminDesktopPendingUsersListPage> createState() => _AdminDesktopPendingUsersListPageState();
}

class _AdminDesktopPendingUsersListPageState extends State<AdminDesktopPendingUsersListPage> {
  final getxController = Get.put(AdminPendingUsersListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (getxController.isLoading.value) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 180,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => _buildShimmerCard(),
          );
        }

        final filteredUsers = getxController.usersList.where((user) {
          final query = widget.searchQuery.value.toLowerCase().trim();
          final name = user.userName.toLowerCase();
          final email = user.email.toLowerCase();
          final role = user.userRole;
          final roles = widget.selectedRoles;
          final matchesRole = roles.contains('All') || roles.contains(role);
          final matchesSearch = query.isEmpty || name.contains(query) || email.contains(query);
          return matchesRole && matchesSearch;
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(child: EmptyDataWidget(message: "No pending users found."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 180,
          ),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) => _buildUserCard(filteredUsers[index], context),
        );
      }),
    );
  }

  Widget _buildUserCard(UserModel user, BuildContext context) {
    final heroTag = 'user-card-${user.id}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          HeroDialogRoute(
            builder: (context) => ExpandedUserCardDialog(
              user: user,
              heroTag: heroTag,
              listType: 'pending',
            ),
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Avatar + Name + Email
                    Row(
                      children: [
                        // Simple clean avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: Center(
                            child: Text(
                              user.userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name + Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Bottom row: Role & Location chips (minimal style)
                    Row(
                      children: [
                        _miniChip(Icons.work_outline, user.userRole, AppColors.neonGreen),
                        const SizedBox(width: 8),
                        _miniChip(Icons.location_on_outlined, user.location, Colors.white54),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Timestamp
                    Text(
                      "Applied: ${user.createdAt != null ? DateFormat('dd MMM yyyy').format(user.createdAt!) : 'N/A'}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
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

  // Minimal clean chip style
  Widget _miniChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const ShimmerWidget(width: double.infinity, height: double.infinity, borderRadius: 12),
    );
  }
}
