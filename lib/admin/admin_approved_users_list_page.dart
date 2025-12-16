import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_kam_controller.dart';
import 'package:otobix_crm/models/user_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_constants.dart';
import 'package:otobix_crm/widgets/button_widget.dart';
import 'package:otobix_crm/widgets/empty_data_widget.dart';
import 'package:otobix_crm/widgets/shimmer_widget.dart';
import 'package:otobix_crm/admin/controller/admin_approved_users_list_controller.dart';

class AdminApprovedUsersListPage extends StatelessWidget {
  final RxString searchQuery;
  final RxList<String> selectedRoles;
  AdminApprovedUsersListPage({
    super.key,
    required this.searchQuery,
    required this.selectedRoles,
  });

  final getxController = Get.put(AdminApprovedUsersListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (getxController.isLoading.value) {
          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => _buildUserShimmerCard(),
          );
        }

        // search + role filter
        // new search is omved from desktoop to deshboard
        final filteredUsers = getxController.approvedUsersList.where((user) {
          final query = (searchQuery.value).toLowerCase().trim();

          // Safe strings
          final name = (user.userName).toLowerCase();
          final email = (user.email).toLowerCase();
          final role = user.userRole;

          // Role filter: if 'All' is selected, everything passes
          final roles = selectedRoles; // RxList<String>
          final matchesRole =
              roles.contains('All') ? true : roles.contains(role);

          // Text search (empty query passes)
          final matchesSearch =
              query.isEmpty || name.contains(query) || email.contains(query);

          return matchesRole && matchesSearch;
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: EmptyDataWidget(message: "No approved users found."),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(15),
          itemCount: filteredUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _buildUserCard(user);
          },
        );
      }),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return InkWell(
      onTap: () => _buildUserDetailsBottomSheet(user),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: user.image != null && user.image!.isNotEmpty
                    ? NetworkImage(user.image!)
                    : null,
                child: user.image == null || user.image!.isEmpty
                    ? Text(user.userName.substring(0, 1).toUpperCase())
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email.trim(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // if (user.dealershipName != null &&
                    //     user.dealershipName!.isNotEmpty)
                    //   Text("Dealership: ${user.dealershipName!}"),
                    Text(
                      "Phone: ${user.phoneNumber}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    // Text("Location: ${user.location}"),
                    if (user.createdAt != null)
                      Text(
                        "Approved on: ${DateFormat('dd MMM yyyy').format(user.createdAt!)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        user.userRole,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Approved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _buildUserDetailsBottomSheet(UserModel user) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          minChildSize: 0.7,
          initialChildSize: 0.8,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          user.image != null && user.image!.isNotEmpty
                              ? NetworkImage(user.image!)
                              : null,
                      child: user.image == null || user.image!.isEmpty
                          ? Text(
                              user.userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 28),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      user.userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                  const Divider(height: 30),

                  _infoTile("Role", user.userRole),
                  if (user.userName.isNotEmpty)
                    _infoTile("User Name", user.userName),
                  // if (user.password.isNotEmpty)
                  //   _infoTile("Password", user.password),
                  _infoTile("Phone", user.phoneNumber),
                  _infoTile("Location", user.location),
                  if (user.dealershipName != null &&
                      user.dealershipName!.isNotEmpty)
                    _infoTile("Dealership", user.dealershipName!),
                  if (user.entityType != null && user.entityType!.isNotEmpty)
                    _infoTile("Entity Type", user.entityType!),
                  if (user.primaryContactPerson != null &&
                      user.primaryContactPerson!.isNotEmpty)
                    _infoTile("Primary Contact", user.primaryContactPerson!),
                  if (user.primaryContactNumber != null &&
                      user.primaryContactNumber!.isNotEmpty)
                    _infoTile("Primary Number", user.primaryContactNumber!),
                  if (user.secondaryContactPerson != null &&
                      user.secondaryContactPerson!.isNotEmpty)
                    _infoTile(
                      "Secondary Contact",
                      user.secondaryContactPerson!,
                    ),
                  if (user.secondaryContactNumber != null &&
                      user.secondaryContactNumber!.isNotEmpty)
                    _infoTile("Secondary Number", user.secondaryContactNumber!),
                  if (user.createdAt != null)
                    _infoTile(
                      "Approved On",
                      DateFormat('dd MMM yyyy').format(user.createdAt!),
                    ),
                  if (user.addressList.isNotEmpty)
                    _infoTile("Addresses", user.addressList.join(", ")),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ButtonWidget(
                        text: "Edit Profile",
                        isLoading: false.obs,
                        height: 35,
                        fontSize: 12,
                        onTap: () {
                          Get.back(); // Close the bottom sheet
                          Future.delayed(Duration(milliseconds: 200), () {
                            _showEditDialog(user); // Then show the dialog
                          });
                        },
                      ),
                      ButtonWidget(
                        text: "Assign KAM",
                        isLoading: false.obs,
                        height: 35,
                        fontSize: 12,
                        backgroundColor: AppColors.blue,
                        onTap: () {
                          Get.back(); // Close the bottom sheet
                          Future.delayed(Duration(milliseconds: 200), () {
                            _showAssignKamDialog(user); // Then show the dialog
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer Card
  Widget _buildUserShimmerCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerWidget(width: 50, height: 50, borderRadius: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(width: 120, height: 14),
                  SizedBox(height: 8),
                  ShimmerWidget(width: 180, height: 12),
                  SizedBox(height: 8),
                  ShimmerWidget(width: 120, height: 14),
                  SizedBox(height: 8),
                  ShimmerWidget(width: 180, height: 12),
                  SizedBox(height: 8),
                  ShimmerWidget(width: 100, height: 12),
                  SizedBox(height: 8),
                  ShimmerWidget(width: 80, height: 12),
                  SizedBox(height: 10),
                  ShimmerWidget(width: 70, height: 20, borderRadius: 50),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ShimmerWidget(width: 70, height: 25, borderRadius: 50),
          ],
        ),
      ),
    );
  }

  // Show Edit Profile Dialog
  void _showEditDialog(UserModel user) {
    getxController.obscurePasswordText.value = true;
    // final passwordController = TextEditingController(text: user.password);
    final statusOptions = [
      AppConstants.roles.userStatusPending,
      AppConstants.roles.userStatusApproved,
      AppConstants.roles.userStatusRejected,
    ];
    final selectedStatus = RxString(user.approvalStatus);

    showDialog(
      context: Get.context!,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Edit User Profile",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User ID: ${user.userName}",
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // _labeledField("Password", passwordController),
                // const SizedBox(height: 10),
                const Text(
                  "Status",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 5),

                Obx(
                  () => DropdownButtonFormField<String>(
                    value: selectedStatus.value,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    items: statusOptions.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedStatus.value = value;
                    },
                    style: TextStyle(fontSize: 13, color: AppColors.black),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        text: "Cancel",
                        isLoading: false.obs,
                        height: 30,
                        elevation: 3,
                        fontSize: 12,
                        backgroundColor: AppColors.red,
                        onTap: () {
                          Get.back(); // Close the bottom sheet
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ButtonWidget(
                        text: "Update",
                        isLoading: false.obs,
                        height: 30,
                        elevation: 3,
                        fontSize: 12,
                        onTap: () async {
                          // if (getxController.formKey.currentState!.validate()) {
                          await getxController.updateUserThroughAdmin(
                            userId: user.id,
                            status: selectedStatus.value,
                            // password: passwordController.text,
                          );
                          Get.back(); // Close the dialog
                          // await getxController.fetchApprovedUsersList();

                          // //Temp for now
                          // await Get.find<AdminRejectedUserListController>()
                          //     .fetchRejectedUsersList();
                          // await Get.find<AdminPendingUsersListController>()
                          //     .fetchPendingUsersList();
                          //////////////
                          // }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _labeledField(String label, TextEditingController controller) {
    return Form(
      key: getxController.formKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 5),
          Obx(
            () => TextFormField(
              controller: controller,
              obscureText: getxController.obscurePasswordText.value,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                errorMaxLines: 3,
                suffixIcon: GestureDetector(
                  child: Icon(
                    getxController.obscurePasswordText.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.grey,
                    size: 15,
                  ),
                  onTap: () {
                    getxController.obscurePasswordText.value =
                        !getxController.obscurePasswordText.value;
                  },
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 20,
                ),
              ),
              style: const TextStyle(fontSize: 13),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }

                if (value.length < 8) {
                  return 'Password must be 8 characters long';
                }

                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                  return 'Password must include one uppercase letter';
                }

                if (!RegExp(r'[a-z]').hasMatch(value)) {
                  return 'Password must include one lowercase letter';
                }

                if (!RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Password must include one number';
                }

                if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'Password must include one special character';
                }

                return null; // ✅ Valid
              },
            ),
          ),
        ],
      ),
    );
  }

// Show assign KAM dialog
  void _showAssignKamDialog(UserModel user) {
    // Get KAM controller (use existing one if already registered)
    final kamController = Get.isRegistered<AdminKamController>()
        ? Get.find<AdminKamController>()
        : Get.put(AdminKamController(), permanent: true);

    // selected KAM id (empty string = unassign)
    final selectedKamId = ''.obs;

    showDialog(
      context: Get.context!,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Assign KAM",
            style: TextStyle(
              fontSize: 15,
              color: AppColors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Obx(() {
            // While KAMs are loading
            if (kamController.isLoading.value && kamController.kams.isEmpty) {
              return const SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.green),
                ),
              );
            }

            // No KAMs available
            if (kamController.kams.isEmpty) {
              return const Text(
                "No KAMs available. Please create a KAM first.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey,
                ),
              );
            }

            return SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dealer: ${user.userName}",
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Select KAM (or choose Unassign):",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dropdown
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: selectedKamId.value,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text("Unassign KAM"),
                        ),
                        ...kamController.kams.map(
                          (kam) => DropdownMenuItem<String>(
                            value: kam.id,
                            child: Text(kam.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        selectedKamId.value = value ?? '';
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          actionsPadding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 15, top: 5),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    text: "Cancel",
                    isLoading: false.obs,
                    height: 30,
                    elevation: 3,
                    fontSize: 12,
                    backgroundColor: AppColors.red,
                    onTap: () => Get.back(),
                  ),
                ),
                if (kamController.kams.isNotEmpty) const SizedBox(width: 10),
                if (kamController.kams.isNotEmpty)
                  Expanded(
                    child: Obx(
                      () => ButtonWidget(
                        text: selectedKamId.value.isEmpty
                            ? "Unassign KAM"
                            : "Assign KAM",
                        isLoading: getxController.isAssignKamLoading,
                        height: 30,
                        elevation: 3,
                        fontSize: 12,
                        onTap: () async {
                          await getxController.assignKamToDealer(
                            dealerId: user.id,
                            kamId: selectedKamId.value.isEmpty
                                ? null // -> unassign
                                : selectedKamId.value,
                          );
                          Get.back(); // close dialog
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
