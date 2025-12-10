import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/controller/admin_car_dropdown_management_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart' show AppColors;
import 'package:otobix_crm/widgets/button_widget.dart';
import 'dart:ui' as ui;

class AdminDesktopCarDropdownManagementPage extends StatelessWidget {
  AdminDesktopCarDropdownManagementPage({super.key});

  final AdminCarDropdownManagementController controller =
      Get.put(AdminCarDropdownManagementController());

  // Search query for filtering
  final RxString searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1117),
                  Color(0xFF161B22),
                  Color(0xFF0D1117),
                ],
              ),
            ),
          ),
          // Content
          Obx(() {
            if (controller.isLoading.value && controller.dropdownsList.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.neonGreen),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSearchAndActions(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildDataTable()),
                  const SizedBox(height: 16),
                  _buildPagination(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Header with back button and title
  Widget _buildHeader() {
    return Row(
      children: [
        // Back button with glassmorphism
        GestureDetector(
          onTap: () => Get.back(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Car Dropdown Management",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Manage car dropdowns for make, model, variant",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Search bar and action buttons
  Widget _buildSearchAndActions() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: TextField(
                    onChanged: (value) => searchQuery.value = value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search dropdowns...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Filter button
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: Colors.white.withOpacity(0.6), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Filter Results",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add button
              GestureDetector(
                onTap: () {
                  controller.clearForm();
                  showDialog(
                    context: Get.context!,
                    builder: (context) => _buildAddDropdownDialog(),
                  );
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.neonGreen, AppColors.neonGreen.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Add New Entry",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Data table with glassmorphism
  Widget _buildDataTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Obx(() {
            final query = searchQuery.value.toLowerCase();
            final dropdowns = controller.dropdownsList.where((d) {
              if (query.isEmpty) return true;
              return d.fullName.toLowerCase().contains(query) ||
                  d.make.toLowerCase().contains(query) ||
                  d.model.toLowerCase().contains(query) ||
                  d.variant.toLowerCase().contains(query);
            }).toList();

            if (dropdowns.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      "No dropdowns found",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                  child: Row(
                    children: [
                      _headerCell("S.No", flex: 1),
                      _headerCell("Full Name", flex: 3),
                      _headerCell("Make", flex: 2),
                      _headerCell("Model", flex: 2),
                      _headerCell("Variant", flex: 2),
                      _headerCell("Status", flex: 1),
                      _headerCell("Actions", flex: 2),
                    ],
                  ),
                ),
                // Table Body
                Expanded(
                  child: ListView.builder(
                    itemCount: dropdowns.length,
                    itemBuilder: (context, index) {
                      final dropdown = dropdowns[index];
                      return _buildTableRow(
                        index: index,
                        dropdown: dropdown,
                        isEditing: false,
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.unfold_more, size: 14, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required int index,
    required dynamic dropdown,
    required bool isEditing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isEditing 
            ? AppColors.neonGreen.withOpacity(0.15)
            : (index.isEven ? Colors.white.withOpacity(0.02) : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
        border: isEditing 
            ? Border.all(color: AppColors.neonGreen.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            // S.No
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isEditing 
                      ? AppColors.neonGreen.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${index + 1}".padLeft(2, '0'),
                  style: TextStyle(
                    color: isEditing ? AppColors.neonGreen : Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Full Name
            Expanded(
              flex: 3,
              child: Text(
                dropdown.fullName,
                style: TextStyle(
                  color: dropdown.isActive ? Colors.white : Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Make
            Expanded(
              flex: 2,
              child: Text(
                dropdown.make,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
            ),
            // Model
            Expanded(
              flex: 2,
              child: Text(
                dropdown.model,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
            ),
            // Variant
            Expanded(
              flex: 2,
              child: Text(
                dropdown.variant,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
            ),
            // Status
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: dropdown.isActive 
                      ? AppColors.neonGreen.withOpacity(0.15)
                      : Colors.redAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dropdown.isActive ? 'Active' : 'Inactive',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dropdown.isActive ? AppColors.neonGreen : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    icon: Icons.edit_outlined,
                    color: Colors.white.withOpacity(0.6),
                    onTap: () {
                      controller.loadDropdownForEdit(dropdown);
                      showDialog(
                        context: Get.context!,
                        builder: (context) => _buildEditDropdownDialog(dropdown),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    icon: Icons.delete_outline,
                    color: Colors.redAccent.withOpacity(0.7),
                    onTap: () {
                      showDialog(
                        context: Get.context!,
                        builder: (context) => _buildDeleteDropdownDialog(dropdown),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // Pagination with glassmorphism
  Widget _buildPagination() {
    return Obx(() {
      final current = controller.currentPage.value;
      final total = controller.totalPages.value;
      final totalRecords = controller.dropdownsList.length;

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // First page
                _paginationButton(
                  icon: Icons.keyboard_double_arrow_left,
                  enabled: current > 1,
                  onTap: () => controller.fetchDropdownsList(page: 1),
                ),
                const SizedBox(width: 6),
                // Previous
                _paginationButton(
                  icon: Icons.chevron_left,
                  enabled: current > 1,
                  onTap: () => controller.fetchDropdownsList(page: current - 1),
                ),
                const SizedBox(width: 12),
                // Current page indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.neonGreen, AppColors.neonGreen.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$current",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "/ $total",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
                const SizedBox(width: 12),
                // Next
                _paginationButton(
                  icon: Icons.chevron_right,
                  enabled: current < total,
                  onTap: () => controller.fetchDropdownsList(page: current + 1),
                ),
                const SizedBox(width: 6),
                // Last page
                _paginationButton(
                  icon: Icons.keyboard_double_arrow_right,
                  enabled: current < total,
                  onTap: () => controller.fetchDropdownsList(page: total),
                ),
                const SizedBox(width: 20),
                // Total records
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    "Total Records: $totalRecords",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _paginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(enabled ? 0.08 : 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  // Add Dropdown Dialog with glassmorphism
  Widget _buildAddDropdownDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 480,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.neonGreen.withOpacity(0.2), Colors.transparent],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add, color: AppColors.neonGreen, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "Add New Car Dropdown",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close, color: Colors.white.withOpacity(0.6), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                // Form
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDarkInputField(
                        controller: controller.makeController,
                        label: "Make",
                        hintText: "Enter car make",
                        icon: Icons.directions_car_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDarkInputField(
                        controller: controller.modelController,
                        label: "Model",
                        hintText: "Enter car model",
                        icon: Icons.model_training_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDarkInputField(
                        controller: controller.variantController,
                        label: "Variant",
                        hintText: "Enter car variant",
                        icon: Icons.tune_outlined,
                      ),
                      const SizedBox(height: 16),
                      // Active Switch
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Active Status", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                            Switch(
                              value: controller.isActive.value,
                              onChanged: (value) => controller.isActive.value = value,
                              activeColor: AppColors.neonGreen,
                              activeTrackColor: AppColors.neonGreen.withOpacity(0.3),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final success = await controller.addDropdown();
                                if (success) {
                                  Get.back();
                                  controller.clearForm();
                                }
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.neonGreen, AppColors.neonGreen.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Add Dropdown",
                                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(icon, color: AppColors.neonGreen.withOpacity(0.7), size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // Edit Dropdown Dialog
  Widget _buildEditDropdownDialog(dynamic dropdown) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 480,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent.withOpacity(0.2), Colors.transparent],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "Edit Car Dropdown",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close, color: Colors.white.withOpacity(0.6), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                // Form
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDarkInputField(
                        controller: controller.makeController,
                        label: "Make",
                        hintText: "Enter car make",
                        icon: Icons.directions_car_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDarkInputField(
                        controller: controller.modelController,
                        label: "Model",
                        hintText: "Enter car model",
                        icon: Icons.model_training_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildDarkInputField(
                        controller: controller.variantController,
                        label: "Variant",
                        hintText: "Enter car variant",
                        icon: Icons.tune_outlined,
                      ),
                      const SizedBox(height: 16),
                      // Active Switch
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Active Status", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                            Switch(
                              value: controller.isActive.value,
                              onChanged: (value) => controller.isActive.value = value,
                              activeColor: AppColors.neonGreen,
                              activeTrackColor: AppColors.neonGreen.withOpacity(0.3),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final success = await controller.editDropdown(dropdown.id);
                                if (success) {
                                  Get.back();
                                  controller.clearForm();
                                }
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.blueAccent, Color(0xFF5B8DEE)],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Update Dropdown",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Delete Confirmation Dialog
  Widget _buildDeleteDropdownDialog(dynamic dropdown) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Delete Dropdown",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to delete '${dropdown.fullName}'?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final success = await controller.deleteDropdown(dropdown.id);
                            if (success) Get.back();
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
        ),
      ),
    );
  }
}
