import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_staff_controller.dart';
import 'package:otobix_crm/models/staff_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_constants.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class AdminDesktopStaffPage extends StatelessWidget {
  const AdminDesktopStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminStaffController(), permanent: true);

    return Column(
      children: [
        // REMOVED THE OLD HEADER WITH ADD BUTTON
        // ================= STAFF GRID ONLY =================
        Expanded(
          child: Obx(() {
            if (controller.allStaff.isEmpty) {
              return const Center(
                child: Text(
                  'No staff available',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 2.3,
              ),
              itemCount: controller.allStaff.length,
              itemBuilder: (_, index) => _staffCard(controller.allStaff[index]),
            );
          }),
        ),
      ],
    );
  }

  // =========================================================
  // STAFF CARD
  // =========================================================

  Widget _staffCard(StaffModel staff) {
    return InkWell(
      onTap: () => _showStaffDetailsDialog(staff),
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  child: Text(
                    staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _pill(Icons.work_outline, staff.role, AppColors.neonGreen),
                const SizedBox(width: 10),
                _pill(Icons.location_on_outlined, 'Mumbai',
                    Colors.white.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Applied: ${DateFormat('dd MMM yyyy').format(staff.createdAt)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STAFF DETAILS DIALOG (IMAGE STYLE)
  // =========================================================

  void _showStaffDetailsDialog(StaffModel staff) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          width: 520,
          borderRadius: 20,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.black.withOpacity(0.25),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),

              // PROFILE
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      child: Text(
                        staff.name.isNotEmpty
                            ? staff.name[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.mail_outline,
                                  size: 14, color: AppColors.textGrey),
                              const SizedBox(width: 6),
                              Text(staff.email,
                                  style: const TextStyle(
                                      color: AppColors.textGrey)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: Colors.blue),
                              SizedBox(width: 6),
                              Text('Mumbai',
                                  style: TextStyle(color: Colors.blue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.white.withOpacity(0.08), height: 1),

              // DETAILS
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _detailRow('Role', staff.role, 'Phone', '9876543212'),
                    const SizedBox(height: 20),
                    _detailRow('Dealership', 'Otobix Motors',
                        'Key Account Manager', 'No KAM Assigned'),
                    const SizedBox(height: 20),
                    _detailRow('Created On',
                        DateFormat('dd MMM yyyy').format(staff.createdAt)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String lTitle, String lValue,
      [String? rTitle, String? rValue]) {
    return Row(
      children: [
        Expanded(child: _detailItem(lTitle, lValue)),
        if (rTitle != null) ...[
          const SizedBox(width: 24),
          Expanded(child: _detailItem(rTitle, rValue ?? '')),
        ]
      ],
    );
  }

  Widget _detailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite)),
      ],
    );
  }

  // =========================================================
  // ADD STAFF DIALOG - PUBLIC METHOD
  // =========================================================

  static void showAddStaffDialog() {
    final controller = Get.find<AdminStaffController>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          width: 720,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add New Staff',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite)),
                  const SizedBox(height: 20),
                  _input('Name', controller.staffNameController, Icons.person),
                  _input('Email', controller.emailController, Icons.email),
                  _input('Phone', controller.phoneController, Icons.phone),
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedLocation.value.isEmpty
                            ? null
                            : controller.selectedLocation.value,
                        decoration: _dropdown('Location', Icons.location_on),
                        items: AppConstants.indianStates
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedLocation.value = v ?? '',
                      )),
                  const SizedBox(height: 20),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.addStaff,
                          child: const Text('Add Staff'),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _input(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  static InputDecoration _dropdown(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon));
  }
}
