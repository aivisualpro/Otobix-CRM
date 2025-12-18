// lib/admin/telecalling_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/controller/Admin_dasktop_Telecalling_controller.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class TelecallingScreen extends StatelessWidget {
  TelecallingScreen({super.key});

  final TelecallingController controller = Get.put(TelecallingController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Add Call button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Telecalling Calls',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditLeadDialog(context, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add New Call',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filters and Search Bar
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: searchController,
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText:
                          'Search by customer name, contact, or appointment ID...',
                      hintStyle: TextStyle(color: AppColors.textGrey),
                      prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    style: TextStyle(color: AppColors.textWhite),
                  ),
                  const SizedBox(height: 16),

                  // Filter Row
                  Row(
                    children: [
                      // Priority Filter
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller
                                          .selectedPriorityFilter.value.isEmpty
                                      ? null
                                      : controller.selectedPriorityFilter.value,
                                  hint: Text(
                                    'Filter by Priority',
                                    style: TextStyle(color: AppColors.textGrey),
                                  ),
                                  icon: Icon(Icons.filter_list,
                                      color: AppColors.neonGreen),
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('All Priorities',
                                          style: TextStyle(
                                              color: AppColors.textWhite)),
                                    ),
                                    ...controller.priorityOptions
                                        .map((priority) {
                                      Color priorityColor = Colors.grey;
                                      if (priority == 'High')
                                        priorityColor = Colors.redAccent;
                                      if (priority == 'Medium')
                                        priorityColor = Colors.orange;
                                      if (priority == 'Low')
                                        priorityColor = Colors.greenAccent;

                                      return DropdownMenuItem<String>(
                                        value: priority,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: priorityColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(priority,
                                                style: const TextStyle(
                                                    color:
                                                        AppColors.textWhite)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    controller.selectedPriorityFilter.value =
                                        value ?? '';
                                  },
                                  dropdownColor: const Color(0xFF1A1F2B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Source Filter
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller
                                          .selectedSourceFilter.value.isEmpty
                                      ? null
                                      : controller.selectedSourceFilter.value,
                                  hint: Text(
                                    'Filter by Source',
                                    style: TextStyle(color: AppColors.textGrey),
                                  ),
                                  icon: Icon(Icons.source,
                                      color: AppColors.neonGreen),
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('All Sources',
                                          style: TextStyle(
                                              color: AppColors.textWhite)),
                                    ),
                                    ...controller.sourceOptions
                                        .map((source) =>
                                            DropdownMenuItem<String>(
                                              value: source,
                                              child: Text(source,
                                                  style: const TextStyle(
                                                      color:
                                                          AppColors.textWhite)),
                                            ))
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    controller.selectedSourceFilter.value =
                                        value ?? '';
                                  },
                                  dropdownColor: const Color(0xFF1A1F2B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Status Filter
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller
                                          .selectedStatusFilter.value.isEmpty
                                      ? null
                                      : controller.selectedStatusFilter.value,
                                  hint: Text(
                                    'Filter by Status',
                                    style: TextStyle(color: AppColors.textGrey),
                                  ),
                                  icon: Icon(Icons.stairs,
                                      color: AppColors.neonGreen),
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('All Statuses',
                                          style: TextStyle(
                                              color: AppColors.textWhite)),
                                    ),
                                    ...controller.vehicleStatusOptions
                                        .map((status) =>
                                            DropdownMenuItem<String>(
                                              value: status,
                                              child: Row(
                                                children: [
                                                  controller
                                                      .getStatusIcon(status),
                                                  const SizedBox(width: 8),
                                                  Text(status,
                                                      style: const TextStyle(
                                                          color: AppColors
                                                              .textWhite)),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    controller.selectedStatusFilter.value =
                                        value ?? '';
                                  },
                                  dropdownColor: const Color(0xFF1A1F2B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )),
                        ),
                      ),

                      // Clear Filters Button
                      IconButton(
                        onPressed: () {
                          controller.selectedPriorityFilter.value = '';
                          controller.selectedSourceFilter.value = '';
                          controller.selectedStatusFilter.value = '';
                          searchController.clear();
                          controller.searchQuery.value = '';
                        },
                        icon: Icon(Icons.clear_all, color: AppColors.textGrey),
                        tooltip: 'Clear all filters',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Calls Table
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.neonGreen),
                  );
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return GlassContainer(
                  padding: const EdgeInsets.all(0),
                  child: _buildCallsTable(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallsTable() {
    return Obx(() {
      final filteredLeads = controller.filteredLeads;

      return Column(
        children: [
          // Table Header
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Appointment ID',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Customer Details',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Vehicle Details',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Priority',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          Expanded(
            child: filteredLeads.isEmpty
                ? Center(
                    child: Text(
                      'No calls found',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 18,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLeads.length,
                    itemBuilder: (context, index) {
                      final lead = filteredLeads[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          child: Row(
                            children: [
                              // Appointment ID
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lead['appointmentId'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 12,
                                            color: AppColors.textGrey),
                                        const SizedBox(width: 4),
                                        Text(
                                          lead['inspectionDateTime'] != null
                                              ? _formatDateTime(
                                                  lead['inspectionDateTime'])
                                              : 'No inspection date',
                                          style: TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Customer Details
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lead['ownerName'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: AppColors.textWhite,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            size: 12,
                                            color: AppColors.textGrey),
                                        const SizedBox(width: 4),
                                        Text(
                                          lead['contactNo'] ?? 'N/A',
                                          style: TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'City: ${lead['city'] ?? 'N/A'}',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Vehicle Details
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.directions_car,
                                            size: 12,
                                            color: AppColors.textGrey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${lead['make'] ?? 'N/A'} ${lead['yearOfManufacture'] ?? ''}',
                                          style: const TextStyle(
                                            color: AppColors.textWhite,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.source,
                                            size: 12,
                                            color: AppColors.textGrey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Source: ${lead['source'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${lead['vehicleStatus'] ?? 'N/A'}',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Priority
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: controller
                                        .getPriorityColor(
                                            lead['priority'] ?? '')
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: controller.getPriorityColor(
                                          lead['priority'] ?? ''),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      lead['priority'] ?? 'N/A',
                                      style: TextStyle(
                                        color: controller.getPriorityColor(
                                            lead['priority'] ?? ''),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Status
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: controller
                                        .getStatusColor(
                                            lead['vehicleStatus'] ?? '')
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: controller.getStatusColor(
                                          lead['vehicleStatus'] ?? ''),
                                    ),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        controller.getStatusIcon(
                                            lead['vehicleStatus'] ?? ''),
                                        const SizedBox(width: 4),
                                        Text(
                                          lead['vehicleStatus'] ?? 'N/A',
                                          style: TextStyle(
                                            color: controller.getStatusColor(
                                                lead['vehicleStatus'] ?? ''),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Actions
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _showAddEditLeadDialog(context, lead),
                                      icon: Icon(Icons.edit,
                                          color: AppColors.neonGreen, size: 20),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      onPressed: () => _showDeleteDialog(lead),
                                      icon: Icon(Icons.delete,
                                          color: Colors.redAccent, size: 20),
                                      tooltip: 'Delete',
                                    ),
                                    IconButton(
                                      onPressed: () => _showDetailsDialog(lead),
                                      icon: Icon(Icons.visibility,
                                          color: AppColors.textWhite, size: 20),
                                      tooltip: 'View Details',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Table Footer
          GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Calls: ${filteredLeads.length}',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
                // Add pagination if needed
              ],
            ),
          ),
        ],
      );
    });
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final date = DateTime.parse(dateTimeString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  void _showAddEditLeadDialog(
      BuildContext context, Map<String, dynamic>? lead) {
    if (lead != null) {
      controller.loadLeadForEditing(lead);
    } else {
      controller.clearForm();
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: GlassContainer(
          width: 800,
          padding: EdgeInsets.zero,
          child: _buildLeadForm(lead != null),
        ),
      ),
    );
  }

  Widget _buildLeadForm(bool isEditing) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Lead' : 'Add New Lead',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.clearForm();
                    Get.back();
                  },
                  icon: Icon(Icons.close, color: AppColors.textGrey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Source & Vehicle Details Section
            Text(
              'Source & Vehicle Details',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Priority
            Text(
              'Priority',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildPriorityOption(
                          'High', controller.selectedPriority.value == 'High',
                          () {
                        controller.selectedPriority.value = 'High';
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPriorityOption('Medium',
                          controller.selectedPriority.value == 'Medium', () {
                        controller.selectedPriority.value = 'Medium';
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPriorityOption(
                          'Low', controller.selectedPriority.value == 'Low',
                          () {
                        controller.selectedPriority.value = 'Low';
                      }),
                    ),
                  ],
                )),
            const SizedBox(height: 20),

            // Two column layout for form fields
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Source (Required)
                      _buildRequiredField(
                        label: 'Source*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.selectedSource.value.isEmpty
                                      ? null
                                      : controller.selectedSource.value,
                                  hint: Text(
                                    'Select Source',
                                    style: TextStyle(color: AppColors.textGrey),
                                  ),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: AppColors.neonGreen),
                                  isExpanded: true,
                                  items: controller.sourceOptions.map((source) {
                                    return DropdownMenuItem<String>(
                                      value: source,
                                      child: Text(source,
                                          style: const TextStyle(
                                              color: AppColors.textWhite)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    controller.selectedSource.value =
                                        value ?? '';
                                  },
                                  dropdownColor: const Color(0xFF1A1F2B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Year of Manufacture (Required)
                      _buildRequiredField(
                        label: 'Year of Manufacture*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: controller.yearOfManufactureController,
                            decoration: InputDecoration(
                              hintText: 'Enter year',
                              hintStyle: TextStyle(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: AppColors.textWhite),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Make (Required)
                      _buildRequiredField(
                        label: 'Make*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller.selectedMake.value.isEmpty
                                      ? null
                                      : controller.selectedMake.value,
                                  hint: Text(
                                    'Select Make',
                                    style: TextStyle(color: AppColors.textGrey),
                                  ),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: AppColors.neonGreen),
                                  isExpanded: true,
                                  items: controller.makeOptions.map((make) {
                                    return DropdownMenuItem<String>(
                                      value: make,
                                      child: Text(make,
                                          style: const TextStyle(
                                              color: AppColors.textWhite)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    controller.selectedMake.value = value ?? '';
                                  },
                                  dropdownColor: const Color(0xFF1A1F2B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Odometer Reading
                      Text(
                        'Odometer Reading (kms)',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller.odometerReadingController,
                          decoration: InputDecoration(
                            hintText: 'Enter odometer reading',
                            hintStyle: TextStyle(color: AppColors.textGrey),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: AppColors.textWhite),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ownership Serial Number (Required)
                      _buildRequiredField(
                        label: 'Ownership Serial Number*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller:
                                controller.ownershipSerialNumberController,
                            decoration: InputDecoration(
                              hintText: 'Enter ownership serial number',
                              hintStyle: TextStyle(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      // Car Registration Number
                      Text(
                        'Car Registration Number',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller:
                              controller.carRegistrationNumberController,
                          decoration: InputDecoration(
                            hintText: 'Enter car registration number',
                            hintStyle: TextStyle(color: AppColors.textGrey),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Year of Registration
                      Text(
                        'Year of Registration',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller.yearOfRegistrationController,
                          decoration: InputDecoration(
                            hintText: 'Enter year of registration',
                            hintStyle: TextStyle(color: AppColors.textGrey),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: AppColors.textWhite),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Car Make Model Variant
                      Text(
                        'Car Make Model Variant',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller.carMakeModelVariantController,
                          decoration: InputDecoration(
                            hintText: 'Enter car make model variant',
                            hintStyle: TextStyle(color: AppColors.textGrey),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 24),

            // Booking Details Section
            Text(
              'Booking Details',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Two column layout for booking details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Vehicle Status (Required)
                      _buildRequiredField(
                        label: 'Vehicle Status*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Obx(() => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: controller
                                          .selectedVehicleStatus.value.isEmpty
                                      ? null
                                      : controller.selectedVehicleStatus.value,
                                  hint: Text(
                                    'Select Vehicle Status',
                                    style: TextStyle(color: AppColors.textGrey),
                                  ),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: AppColors.neonGreen),
                                  isExpanded: true,
                                  items: controller.vehicleStatusOptions
                                      .map((status) {
                                    return DropdownMenuItem<String>(
                                      value: status,
                                      child: Text(status,
                                          style: const TextStyle(
                                              color: AppColors.textWhite)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    controller.selectedVehicleStatus.value =
                                        value ?? '';
                                  },
                                  dropdownColor: const Color(0xFF1A1F2B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Owner Name (Required)
                      _buildRequiredField(
                        label: 'Owner Name*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: controller.ownerNameController,
                            decoration: InputDecoration(
                              hintText: 'Enter owner name',
                              hintStyle: TextStyle(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact No. (Required)
                      _buildRequiredField(
                        label: 'Contact No.*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: controller.contactNoController,
                            decoration: InputDecoration(
                              hintText: 'Enter contact number',
                              hintStyle: TextStyle(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: AppColors.textWhite),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // City (Required)
                      _buildRequiredField(
                        label: 'City*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: controller.cityController,
                            decoration: InputDecoration(
                              hintText: 'Enter city',
                              hintStyle: TextStyle(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: AppColors.textWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      // Zip Code (Required)
                      _buildRequiredField(
                        label: 'Zip Code*',
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: controller.zipCodeController,
                            decoration: InputDecoration(
                              hintText: 'Enter zip code',
                              hintStyle: TextStyle(color: AppColors.textGrey),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: AppColors.textWhite),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Appointment ID
                      Text(
                        'Appointment ID',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller.appointmentIdController,
                          decoration: InputDecoration(
                            hintText: 'Enter appointment ID',
                            hintStyle: TextStyle(color: AppColors.textGrey),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Inspection Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inspection Date',
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(() => InkWell(
                                      onTap: () async {
                                        final selectedDate =
                                            await showDatePicker(
                                          context: Get.context!,
                                          initialDate: controller
                                                  .inspectionDateTime.value ??
                                              DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.dark(
                                                  primary: AppColors.neonGreen,
                                                  onPrimary: Colors.black,
                                                  surface: Color(0xFF1A1F2B),
                                                  onSurface: Colors.white,
                                                ),
                                                dialogBackgroundColor:
                                                    const Color(0xFF1A1F2B),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (selectedDate != null) {
                                          controller.inspectionDateTime.value =
                                              selectedDate;
                                        }
                                      },
                                      child: GlassContainer(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              controller.inspectionDateTime
                                                          .value !=
                                                      null
                                                  ? '${controller.inspectionDateTime.value!.year}-${controller.inspectionDateTime.value!.month.toString().padLeft(2, '0')}-${controller.inspectionDateTime.value!.day.toString().padLeft(2, '0')}'
                                                  : 'Select date',
                                              style: TextStyle(
                                                color: controller
                                                            .inspectionDateTime
                                                            .value !=
                                                        null
                                                    ? AppColors.textWhite
                                                    : AppColors.textGrey,
                                              ),
                                            ),
                                            Icon(Icons.calendar_today,
                                                color: AppColors.neonGreen,
                                                size: 18),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inspection Time',
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Obx(() => InkWell(
                                      onTap: () async {
                                        final selectedTime =
                                            await showTimePicker(
                                          context: Get.context!,
                                          initialTime:
                                              controller.inspectionTime.value ??
                                                  TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.dark(
                                                  primary: AppColors.neonGreen,
                                                  onPrimary: Colors.black,
                                                  surface: Color(0xFF1A1F2B),
                                                  onSurface: Colors.white,
                                                ),
                                                dialogBackgroundColor:
                                                    const Color(0xFF1A1F2B),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (selectedTime != null) {
                                          controller.inspectionTime.value =
                                              selectedTime;
                                        }
                                      },
                                      child: GlassContainer(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              controller.inspectionTime.value !=
                                                      null
                                                  ? '${controller.inspectionTime.value!.hour.toString().padLeft(2, '0')}:${controller.inspectionTime.value!.minute.toString().padLeft(2, '0')}'
                                                  : 'Select time',
                                              style: TextStyle(
                                                color: controller.inspectionTime
                                                            .value !=
                                                        null
                                                    ? AppColors.textWhite
                                                    : AppColors.textGrey,
                                              ),
                                            ),
                                            Icon(Icons.access_time,
                                                color: AppColors.neonGreen,
                                                size: 18),
                                          ],
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Inspection Address
                      Text(
                        'Inspection Address',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller.inspectionAddressController,
                          decoration: InputDecoration(
                            hintText: 'Enter inspection address',
                            hintStyle: TextStyle(color: AppColors.textGrey),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: AppColors.textWhite),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Additional Notes
            Text(
              'Additional Notes',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: controller.additionalNotesController,
                decoration: InputDecoration(
                  hintText: 'Enter additional notes',
                  hintStyle: TextStyle(color: AppColors.textGrey),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: AppColors.textWhite),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 32),

            // Form Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearForm();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (isEditing &&
                                    controller.editingLead.value != null) {
                                  controller.updateLead(
                                      controller.editingLead.value!['id']);
                                } else {
                                  controller.addLead();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.black),
                              )
                            : Text(
                                isEditing ? 'Update Lead' : 'Save Lead',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildPriorityOption(
      String priority, bool isSelected, VoidCallback onTap) {
    Color borderColor = Colors.grey;
    if (priority == 'High') borderColor = Colors.redAccent;
    if (priority == 'Medium') borderColor = Colors.orange;
    if (priority == 'Low') borderColor = Colors.greenAccent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? borderColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: borderColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              priority,
              style: TextStyle(
                color: isSelected ? borderColor : AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showDeleteDialog(Map<String, dynamic> lead) {
    Get.defaultDialog(
      title: 'Delete Lead',
      titleStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color(0xFF1A1F2B),
      content: Text(
        'Are you sure you want to delete lead ${lead['appointmentId']}?',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: () {
            controller.deleteLead(lead['id']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  void _showDetailsDialog(Map<String, dynamic> lead) {
    Get.bottomSheet(
      GlassContainer(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lead Details - ${lead['appointmentId']}',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: AppColors.textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Source & Vehicle Details Section
              Text(
                'Source & Vehicle Details',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailRow('Priority', lead['priority'] ?? 'N/A',
                  controller.getPriorityColor(lead['priority'] ?? '')),
              _buildDetailRow('Source', lead['source'] ?? 'N/A'),
              _buildDetailRow('Make', lead['make'] ?? 'N/A'),
              _buildDetailRow('Year of Manufacture',
                  lead['yearOfManufacture']?.toString() ?? 'N/A'),
              _buildDetailRow('Odometer Reading',
                  '${lead['odometerReadingInKms']?.toString() ?? 'N/A'} kms'),
              _buildDetailRow('Ownership Serial Number',
                  lead['ownershipSerialNumber'] ?? 'N/A'),
              _buildDetailRow('Car Registration Number',
                  lead['carRegistrationNumber'] ?? 'N/A'),
              _buildDetailRow('Year of Registration',
                  lead['yearOfRegistration']?.toString() ?? 'N/A'),
              _buildDetailRow('Car Make Model Variant',
                  lead['carMakeModelVariant'] ?? 'N/A'),

              const SizedBox(height: 24),

              // Booking Details Section
              Text(
                'Booking Details',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailRow('Vehicle Status', lead['vehicleStatus'] ?? 'N/A',
                  controller.getStatusColor(lead['vehicleStatus'] ?? '')),
              _buildDetailRow('Owner Name', lead['ownerName'] ?? 'N/A'),
              _buildDetailRow('Contact No.', lead['contactNo'] ?? 'N/A'),
              _buildDetailRow('City', lead['city'] ?? 'N/A'),
              _buildDetailRow('Zip Code', lead['zipCode']?.toString() ?? 'N/A'),
              _buildDetailRow('Appointment ID', lead['appointmentId'] ?? 'N/A'),
              _buildDetailRow(
                  'Inspection Date/Time',
                  lead['inspectionDateTime'] != null
                      ? _formatDateTime(lead['inspectionDateTime'])
                      : 'N/A'),
              _buildDetailRow(
                  'Inspection Address', lead['inspectionAddress'] ?? 'N/A'),
              _buildDetailRow(
                  'Additional Notes', lead['additionalNotes'] ?? 'N/A'),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
