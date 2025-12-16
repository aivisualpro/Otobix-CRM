import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_approved_users_list_controller.dart';
import 'package:otobix_crm/models/user_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_constants.dart';
import 'package:otobix_crm/utils/hero_dialog_route.dart';
import 'package:otobix_crm/widgets/empty_data_widget.dart';
import 'package:otobix_crm/widgets/expanded_user_card_dialog.dart';
import 'package:otobix_crm/widgets/shimmer_widget.dart';
import 'dart:ui' as ui;

class AdminDesktopApprovedUsersListPage extends StatelessWidget {
  final RxString searchQuery;
  final RxList<String> selectedRoles;

  AdminDesktopApprovedUsersListPage({
    super.key,
    required this.searchQuery,
    required this.selectedRoles,
  });

  final AdminApprovedUsersListController getxController =
      Get.put(AdminApprovedUsersListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      // ✅ Overlay button (Always visible)
      body: Stack(
        children: [
          Positioned(
            top: 16,
            right: 16,
            child: _AddUserTopButton(
              onTap: () => _showAddUserDialog(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 72),
            child: Obx(() {
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

              final filteredUsers =
                  getxController.approvedUsersList.where((user) {
                final query = searchQuery.value.toLowerCase().trim();
                final name = user.userName.toLowerCase();
                final email = user.email.toLowerCase();
                final role = user.userRole;
                final roles = selectedRoles;

                final matchesRole =
                    roles.contains('All') || roles.contains(role);
                final matchesSearch = query.isEmpty ||
                    name.contains(query) ||
                    email.contains(query);

                return matchesRole && matchesSearch;
              }).toList();

              if (filteredUsers.isEmpty) {
                return Center(
                  child: EmptyDataWidget(message: "No approved users found."),
                );
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
                itemBuilder: (context, index) =>
                    _buildUserCard(filteredUsers[index], context),
              );
            }),
          ),

          // ✅ Always visible top-right "Add User" button
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    Navigator.push(
      context,
      HeroDialogRoute(
        builder: (context) => _AddUserDialog(controller: getxController),
      ),
    );
  }

  Widget _buildUserCard(UserModel user, BuildContext context) {
    final heroTag = 'user-card-${user.id}-approved';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          HeroDialogRoute(
            builder: (context) => ExpandedUserCardDialog(
              user: user,
              heroTag: heroTag,
              listType: 'approved',
            ),
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        createRectTween: (begin, end) =>
            MaterialRectCenterArcTween(begin: begin, end: end),
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
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.neonGreen.withOpacity(0.4),
                              width: 1.5,
                            ),
                            image:
                                (user.image != null && user.image!.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(user.image!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: (user.image == null || user.image!.isEmpty)
                              ? Center(
                                  child: Text(
                                    user.userName.isNotEmpty
                                        ? user.userName
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
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

                        // Status indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonGreen,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonGreen.withOpacity(0.5),
                                blurRadius: 6,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _miniChip(Icons.phone_outlined, user.phoneNumber,
                            Colors.white54),
                        const SizedBox(width: 8),
                        _miniChip(Icons.work_outline, user.userRole,
                            AppColors.neonGreen),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Since: ${user.createdAt != null ? DateFormat('dd MMM yyyy').format(user.createdAt!) : 'N/A'}",
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
      child: const ShimmerWidget(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 12,
      ),
    );
  }
}

/// ✅ Always visible top button widget
class _AddUserTopButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddUserTopButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.neonGreen,
              AppColors.neonGreen.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGreen.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.black, size: 20),
            SizedBox(width: 8),
            Text(
              'Add User',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// Add User Dialog Widget
// ---------------------------
class _AddUserDialog extends StatelessWidget {
  final AdminApprovedUsersListController controller;

  const _AddUserDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: 'add-user-dialog',
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: const Color(0xFF1A1D2E).withOpacity(0.95),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('User Information'),
                                const SizedBox(height: 16),
                                _buildUserInfoFields(),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Permissions'),
                                const SizedBox(height: 16),
                                _buildPermissionsField(),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Dealership Details'),
                                const SizedBox(height: 16),
                                _buildDealershipFields(),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Contact Information'),
                                const SizedBox(height: 16),
                                _buildContactFields(),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Address'),
                                const SizedBox(height: 16),
                                _buildAddressFields(),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Security'),
                                const SizedBox(height: 16),
                                _buildSecurityFields(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.neonGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.person_add,
              color: AppColors.neonGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Add New User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.close,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.neonGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.userNameController,
                label: 'User Name',
                hint: 'Enter full name',
                icon: Icons.person_outline,
                validator: (val) =>
                    val?.isEmpty ?? true ? 'Name is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.emailController,
                label: 'Email',
                hint: 'Enter email address',
                icon: Icons.email_outlined,
                validator: (val) {
                  if (val?.isEmpty ?? true) return 'Email is required';
                  if (!GetUtils.isEmail(val!)) return 'Invalid email';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.phoneNumberController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Icons.phone_outlined,
                validator: (val) =>
                    val?.isEmpty ?? true ? 'Phone is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildLocationDropdown()),
          ],
        ),
        const SizedBox(height: 16),
        _buildRoleDropdown(),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: controller.selectedLocation.value.isEmpty
                  ? null
                  : controller.selectedLocation.value,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.neonGreen.withOpacity(0.6),
                  size: 20,
                ),
                hintText: 'Select location',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
              dropdownColor: const Color(0xFF1A1D2E),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.5),
              ),
              isExpanded: true,
              menuMaxHeight: 300,
              items: AppConstants.indianStates.map((state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.selectedLocation.value = value;
              },
              validator: (val) =>
                  val?.isEmpty ?? true ? 'Location is required' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Permissions',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.availablePermissions.map((permission) {
                    final isSelected =
                        controller.isPermissionSelected(permission);
                    return InkWell(
                      onTap: () => controller.togglePermission(permission),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? AppColors.neonGreen.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neonGreen.withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? AppColors.neonGreen
                                  : Colors.white.withOpacity(0.5),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatPermissionName(permission),
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.neonGreen
                                    : Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => controller.selectedPermissions.isEmpty
                    ? Text(
                        'No permissions selected',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            controller.selectedPermissions.map((permission) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppColors.neonGreen.withOpacity(0.2),
                              border: Border.all(
                                color: AppColors.neonGreen.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatPermissionName(permission),
                                  style: TextStyle(
                                    color: AppColors.neonGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () =>
                                      controller.togglePermission(permission),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.neonGreen,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select permissions that this user will have access to',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatPermissionName(String permission) {
    return permission
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildDealershipFields() {
    return Obx(() {
      if (controller.selectedRole.value.toLowerCase() != 'dealer') {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.dealershipNameController,
                  label: 'Dealership Name',
                  hint: 'Enter dealership name',
                  icon: Icons.store_outlined,
                  validator: (val) => val?.isEmpty ?? true
                      ? 'Dealership name is required'
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildEntityTypeDropdown()),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildContactFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.primaryContactPersonController,
                label: 'Primary Contact Person',
                hint: 'Enter primary contact name',
                icon: Icons.contact_phone_outlined,
                validator: (val) =>
                    val?.isEmpty ?? true ? 'Primary contact is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.primaryContactNumberController,
                label: 'Primary Contact Number',
                hint: 'Enter primary contact number',
                icon: Icons.phone,
                validator: (val) => val?.isEmpty ?? true
                    ? 'Primary contact number is required'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.secondaryContactPersonController,
                label: 'Secondary Contact Person',
                hint: 'Enter secondary contact name',
                icon: Icons.contact_phone_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.secondaryContactNumberController,
                label: 'Secondary Contact Number',
                hint: 'Enter secondary contact number',
                icon: Icons.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      children: [
        _buildTextField(
          controller: controller.addressLine1Controller,
          label: 'Address Line 1',
          hint: 'Enter address line 1',
          icon: Icons.home_outlined,
          validator: (val) =>
              val?.isEmpty ?? true ? 'Address is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: controller.addressLine2Controller,
          label: 'Address Line 2',
          hint: 'Enter address line 2',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.cityController,
                label: 'City',
                hint: 'Enter city',
                icon: Icons.location_city_outlined,
                validator: (val) =>
                    val?.isEmpty ?? true ? 'City is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.stateController,
                label: 'State',
                hint: 'Enter state',
                icon: Icons.map_outlined,
                validator: (val) =>
                    val?.isEmpty ?? true ? 'State is required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: controller.pincodeController,
                label: 'Pincode',
                hint: 'Enter pincode',
                icon: Icons.pin_drop_outlined,
                validator: (val) =>
                    val?.isEmpty ?? true ? 'Pincode is required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityFields() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _buildTextField(
              controller: controller.passwordController,
              label: 'Password',
              hint: 'Enter password',
              icon: Icons.lock_outline,
              obscureText: controller.obscurePasswordText.value,
              suffixIcon: IconButton(
                onPressed: () => controller.obscurePasswordText.toggle(),
                icon: Icon(
                  controller.obscurePasswordText.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              validator: (val) {
                if (val?.isEmpty ?? true) return 'Password is required';
                if (val!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.neonGreen.withOpacity(0.6),
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Role',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: controller.selectedRole.value.isEmpty
                  ? null
                  : controller.selectedRole.value,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.work_outline,
                  color: AppColors.neonGreen.withOpacity(0.6),
                  size: 20,
                ),
                hintText: 'Select user role',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
              dropdownColor: const Color(0xFF1A1D2E),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.5),
              ),
              items: AppConstants.roles.all.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.selectedRole.value = value;
              },
              validator: (val) =>
                  val?.isEmpty ?? true ? 'Role is required' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntityTypeDropdown() {
    final List<String> entityTypes = [
      'Pvt Ltd',
      'Public Ltd',
      'Partnership',
      'Proprietorship',
      'LLP'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entity Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.05),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: controller.selectedEntityType.value.isEmpty
                  ? null
                  : controller.selectedEntityType.value,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.business_outlined,
                  color: AppColors.neonGreen.withOpacity(0.6),
                  size: 20,
                ),
                hintText: 'Select entity type',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
              dropdownColor: const Color(0xFF1A1D2E),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.5),
              ),
              items: entityTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.selectedEntityType.value = value;
              },
              validator: (val) =>
                  val?.isEmpty ?? true ? 'Entity type is required' : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Obx(
            () => InkWell(
              onTap: controller.isRegisterLoading.value
                  ? null
                  : () => controller.registerUser(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonGreen,
                      AppColors.neonGreen.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: controller.isRegisterLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : const Text(
                        'Add User',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
