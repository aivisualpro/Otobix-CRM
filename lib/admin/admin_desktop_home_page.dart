import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/admin_approved_users_list_page.dart';
import 'package:otobix_crm/admin/admin_desktop_approved_users_list_page.dart';
import 'package:otobix_crm/admin/admin_desktop_rejected_users_list_page.dart';
import 'package:otobix_crm/admin/admin_rejected_users_list_page.dart';
import 'package:otobix_crm/admin/controller/admin_desktop_pending_users_list_page.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/widgets/button_widget.dart';
import 'package:otobix_crm/admin/controller/admin_home_controller.dart';
import 'package:otobix_crm/admin/controller/admin_pending_users_list_page.dart';
import 'package:otobix_crm/widgets/glass_container.dart';
import 'dart:ui' as ui;

class AdminDesktopHomePage extends StatelessWidget {
  AdminDesktopHomePage({super.key});

  final AdminHomeController getxController = Get.put(AdminHomeController());

  @override
  Widget build(BuildContext context) {
    return _buildDesktopLayout();
  }

  // Desktop Layout
  Widget _buildDesktopLayout() {
    return Container(
       decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/images/dashboard_bg.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7), // Same darken overlay as dashboard
            BlendMode.darken,
          ),
        ),
      ),
      child: ClipRect( // Added ClipRect to prevent blur bleed to sidebar
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 0, bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section - Just tabs selector (Title removed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Styled Tabs (Buy/Sell style from reference)
                      _buildStyledTabSelector(),
                      
                      // Search and Filter
                      Row(
                        children: [
                           SizedBox(
                             width: 400,
                             child: _buildDesktopSearchBar(),
                           ),
                           const SizedBox(width: 16),
                           _buildDesktopFilterButton(),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Tab Content (Tabs moved to header)
                  Expanded(
                    child: GlassContainer(
                      child: Obx(
                        () => IndexedStack(
                          index: getxController.currentTabIndex.value,
                          children: [
                            ResponsiveLayout(
                                mobile: AdminPendingUsersListPage(
                                  searchQuery: getxController.searchQuery,
                                  selectedRoles: getxController.selectedRoles,
                                ),
                                desktop: AdminDesktopPendingUsersListPage(
                                  searchQuery: getxController.searchQuery,
                                  selectedRoles: getxController.selectedRoles,
                                )),
                            ResponsiveLayout(
                                mobile: AdminApprovedUsersListPage(
                                  searchQuery: getxController.searchQuery,
                                  selectedRoles: getxController.selectedRoles,
                                ),
                                desktop: AdminDesktopApprovedUsersListPage(
                                  searchQuery: getxController.searchQuery,
                                  selectedRoles: getxController.selectedRoles,
                                )),
                            ResponsiveLayout(
                                mobile: AdminRejectedUsersListPage(
                                  searchQuery: getxController.searchQuery,
                                  selectedRoles: getxController.selectedRoles,
                                ),
                                desktop: AdminDesktopRejectedUsersListPage(
                                  searchQuery: getxController.searchQuery,
                                  selectedRoles: getxController.selectedRoles,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Desktop Search Bar
  Widget _buildDesktopSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(12),
         color: Colors.white.withOpacity(0.05), // Darker inline search
         border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: getxController.searchController,
        style: const TextStyle(fontSize: 14, color: AppColors.textWhite),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.7)),
          prefixIcon: Icon(Icons.search, color: AppColors.textGrey.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 14), // Vertical Alignment
        ),
        onChanged: (value) {
          getxController.searchQuery.value = value.toLowerCase();
        },
      ),
    );
  }

  // Desktop Filter Button
  Widget _buildDesktopFilterButton() {
    return Obx(() {
      final isActive = getxController.selectedRoles.length > 1 ||
                        (getxController.selectedRoles.length == 1 &&
                            !getxController.selectedRoles.contains('All'));
      return SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: isActive ? Colors.black : AppColors.textGrey,
            ),
            label: Text(
              'Filter',
              style: TextStyle(
                color: isActive ? Colors.black : AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: isActive ? AppColors.neonGreen : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isActive ? AppColors.neonGreen : Colors.white.withOpacity(0.1),
              ),
            ),
            onPressed: () {
              _buildDesktopRoleFilterDialog();
            },
          ),
        );
    });
  }

  // Styled Tab Selector (Buy/Sell Style from reference image)
  Widget _buildStyledTabSelector() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStyledTab('Pending', 0, getxController.pendingUsersLength.value, Colors.orange),
          _buildStyledTab('Approved', 1, getxController.approvedUsersLength.value, AppColors.neonGreen),
          _buildStyledTab('Rejected', 2, getxController.rejectedUsersLength.value, Colors.redAccent),
        ],
      ),
    ));
  }

  Widget _buildStyledTab(String title, int index, int count, Color activeColor) {
    final isSelected = getxController.currentTabIndex.value == index;
    return GestureDetector(
      onTap: () => getxController.currentTabIndex.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle icon like Buy/Sell style
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black.withOpacity(0.2) : activeColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : activeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (Old tab bar removed - now using styled tabs in header)

  // Desktop Filter Dialog (Updated to match dark theme fully)
  void _buildDesktopRoleFilterDialog() {
    final roles = getxController.roles;
    final RxList<String> tempSelected = RxList<String>.from(
      getxController.selectedRoles,
    );

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: GlassContainer(
          width: 500,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Obx(() => Padding(
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                          if (tempSelected.length > 1 ||
                              (tempSelected.length == 1 &&
                                  !tempSelected.contains('All')))
                            TextButton(
                              onPressed: () {
                                tempSelected.assignAll(['All']);
                              },
                              child: const Text(
                                'Clear All',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: AppColors.neonGreen.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(Icons.check, color: Colors.black, size: 16),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: AppColors.glassBorder),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style:
                                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  // Mobile - Unchanged visually but logic kept
  Widget _buildSearchBar() {
     // Kept identical for mobile compatibility
     // (Skipping mobile specific visual overhaul for now unless requested)
    return SizedBox(
      height: 35,
      child: TextFormField(
        controller: getxController.searchController,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search users...',
          hintStyle: TextStyle(
            color: AppColors.grey.withValues(alpha: .5),
            fontSize: 12,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: AppColors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: AppColors.green, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 10,
          ),
        ),
        onChanged: (value) {
          getxController.searchQuery.value = value.toLowerCase();
        },
      ),
    );
  }
}
