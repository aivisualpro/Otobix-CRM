import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_staff_controller.dart';
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
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text('Add Staff'),
              ),
            ],
          ),
        ),

        // ================= STAFF GRID =================
        Expanded(
          child: Obx(() {
            final staffList = controller.allStaff;

            if (staffList.isEmpty) {
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
                childAspectRatio: 2.2,
              ),
              itemCount: staffList.length,
              itemBuilder: (_, index) {
                final staff = staffList[index];

                return GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.email,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                      ),
                      const Spacer(),
                      Text(
                        staff.role,
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(staff.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ================= ADD STAFF DIALOG =================
  void _showAddStaffDialog(
      BuildContext context, AdminStaffController controller) {
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
                  const Text(
                    'Add New Staff',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
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
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.selectedRole.value,
                        decoration: _dropdown('Role', Icons.badge),
                        items: ['Lead', 'Inspection', 'Admin', 'Sales Manager']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            controller.selectedRole.value = v ?? 'Lead',
                      )),
                  const SizedBox(height: 20),
                  const Text(
                    'Permissions',
                    style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final perms = [
                      'View Home',
                      'View Admin',
                      'View Leads',
                      'View Inspection',
                      'View Price Discovery',
                      'View Auction',
                    ];

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: perms.map((p) {
                        final selected =
                            controller.selectedPermissions.contains(p);
                        return GestureDetector(
                          onTap: () {
                            selected
                                ? controller.selectedPermissions.remove(p)
                                : controller.selectedPermissions.add(p);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.neonGreen
                                  : const Color(0xFF2A3040),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              p,
                              style: TextStyle(
                                color: selected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),
                  _input('Address Line 1', controller.addressLine1Controller,
                      Icons.home),
                  _input('Address Line 2', controller.addressLine2Controller,
                      Icons.home),
                  Row(
                    children: [
                      Expanded(
                        child: _input('City', controller.cityController,
                            Icons.location_city),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _input(
                            'State', controller.stateController, Icons.map),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _input(
                            'Pincode', controller.pincodeController, Icons.pin),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _input('Password', controller.passwordController, Icons.lock,
                      obscure: true),
                  const SizedBox(height: 24),
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isAddStaffLoading.value
                              ? null
                              : controller.addStaff,
                          child: controller.isAddStaffLoading.value
                              ? const CircularProgressIndicator()
                              : const Text('Add Staff'),
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

  // ================= HELPERS =================
  Widget _input(String label, TextEditingController controller, IconData icon,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  InputDecoration _dropdown(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
    );
  }
}
