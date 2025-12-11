import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/models/user_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/utils/app_constants.dart';
import 'package:otobix_crm/widgets/button_widget.dart';
import 'package:otobix_crm/widgets/toast_widget.dart';
import 'package:otobix_crm/admin/controller/admin_pending_users_list_controller.dart';
import 'package:otobix_crm/admin/controller/admin_rejected_users_list_controller.dart';
import 'package:otobix_crm/admin/controller/admin_kam_controller.dart';

class ExpandedUserCardDialog extends StatelessWidget {
  final UserModel user;
  final String heroTag;
  final String listType; // 'pending', 'approved', 'rejected'

  ExpandedUserCardDialog({
    super.key,
    required this.user,
    required this.heroTag,
    required this.listType,
  });

  // Controllers (lazy load if needed)
  final pendingController = Get.isRegistered<AdminPendingUsersListController>()
      ? Get.find<AdminPendingUsersListController>()
      : Get.put(AdminPendingUsersListController());
    
  final rejectedController = Get.isRegistered<AdminRejectedUserListController>()
      ? Get.find<AdminRejectedUserListController>()
      : Get.put(AdminRejectedUserListController());

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: heroTag,
          createRectTween: (begin, end) {
            return MaterialRectCenterArcTween(begin: begin, end: end);
          },
          child: Material(
            color: Colors.transparent,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Container(
                width: 600, // Fixed width for desktop dialog
                decoration: BoxDecoration(
                   color: const Color(0xFF1E2430).withOpacity(0.95), // Solid dark
                   borderRadius: BorderRadius.circular(32),
                   border: Border.all(color: Colors.white.withOpacity(0.1)),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.5),
                       blurRadius: 30,
                       offset: const Offset(0, 10),
                     )
                   ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                     child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                _buildProfileSection(),
                                const SizedBox(height: 32),
                                Divider(color: Colors.white.withOpacity(0.1)),
                                const SizedBox(height: 32),
                                _buildDetailsGrid(),
                                const SizedBox(height: 40),
                                _buildActions(context),
                              ],
                            ),
                          )
                        ],
                     ),
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
    Color statusColor;
    String statusText;

    switch (listType) {
      case 'approved':
        statusColor = AppColors.neonGreen;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.redAccent;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending Review';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: statusColor.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                listType == 'approved' ? Icons.check_circle : 
                listType == 'rejected' ? Icons.cancel : Icons.pending,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white70),
          )
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
            boxShadow: [
               BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)
            ]
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.1),
            backgroundImage: user.image != null && user.image!.isNotEmpty
                ? NetworkImage(user.image!)
                : null,
            child: user.image == null || user.image!.isEmpty
                ? Text(
                    user.userName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.userName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 16, color: Colors.white54),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      user.email,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (user.location.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.blueAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      user.location,
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    return Wrap(
      spacing: 40,
      runSpacing: 24,
      children: [
        _infoItem("Role", user.userRole, Icons.badge_outlined),
        _infoItem("Phone", user.phoneNumber, Icons.phone_outlined),
        if (user.dealershipName != null && user.dealershipName!.isNotEmpty)
          _infoItem("Dealership", user.dealershipName!, Icons.store_outlined),
        if (user.assignedKam.isNotEmpty)
          _infoItem("Key Account Manager", user.assignedKam, Icons.supervisor_account_outlined),
        _infoItem("Created On", user.createdAt != null ? DateFormat('dd MMM yyyy').format(user.createdAt!) : 'N/A', Icons.calendar_today_outlined),
      ],
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               Icon(icon, size: 14, color: Colors.white38),
               const SizedBox(width: 8),
               Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
             ],
           ),
           const SizedBox(height: 6),
           Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (listType == 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 140,
            child: ButtonWidget(
              text: 'Reject',
              isLoading: false.obs,
              height: 45,
              backgroundColor: Colors.white.withOpacity(0.05),
              textColor: Colors.redAccent,
              onTap: () => _showRejectDialog(context),
            ),
          ),
          const SizedBox(width: 16),
           SizedBox(
             width: 140,
            child: ButtonWidget(
              text: 'Approve',
              isLoading: false.obs,
              height: 45,
              backgroundColor: AppColors.neonGreen,
              textColor: Colors.black,
              onTap: () async {
                 await pendingController.approveUser(user.id);
                 Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    } else if (listType == 'approved') {
       return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
           SizedBox(
            width: 160,
            child: ButtonWidget(
              text: 'Assign KAM',
              isLoading: false.obs,
              height: 45,
              backgroundColor: Colors.blueAccent.withOpacity(0.8),
              onTap: () {
                 // Close hero first? No stay in hero and show dialog on top or replace
                 // Standard behavior: show dialog on top
                 _showAssignKamDialog(context);
              },
            ),
          ),
        ]
       );
    } else {
       // Rejected
       return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
           SizedBox(
            width: 160,
            child: ButtonWidget(
              text: 'Re-evaluate',
              isLoading: false.obs,
              height: 45,
              backgroundColor: Colors.orangeAccent.withOpacity(0.8),
              textColor: Colors.black,
              onTap: () {
                 _showEditDialog(context);
              },
            ),
          ),
        ]
       );
    }
  }

   // Show Reuse Logic: Assign KAM
  void _showAssignKamDialog(BuildContext context) {
    final kamController = Get.isRegistered<AdminKamController>()
        ? Get.find<AdminKamController>()
        : Get.put(AdminKamController(), permanent: true);
    final selectedKamId = ''.obs;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white10)),
          title: const Text("Assign KAM", style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
          content: Obx(() {
            if (kamController.isLoading.value && kamController.kams.isEmpty) {
              return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: AppColors.green)));
            }
             if (kamController.kams.isEmpty) return const Text("No KAMs available.", style: TextStyle(color: Colors.white70));
            
            return SizedBox(width: 400, child: DropdownButtonFormField<String>(
               dropdownColor: const Color(0xFF2C2C2C),
               decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.05)),
               items: [
                   const DropdownMenuItem<String>(value: '', child: Text("Unassign KAM", style: TextStyle(color: Colors.white))),
                   ...kamController.kams.map((kam) => DropdownMenuItem<String>(value: kam.id, child: Text(kam.name, style: const TextStyle(color: Colors.white)))),
               ],
               onChanged: (val) => selectedKamId.value = val ?? '',
            ));
          }),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
            ElevatedButton(onPressed: () async {
                 await pendingController.assignKamToDealer(dealerId: user.id, kamId: selectedKamId.value.isEmpty ? null : selectedKamId.value);
                 Get.back();
            }, child: const Text("Assign"))
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context) {
      final TextEditingController commentController = TextEditingController();
      showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white10)),
          title: const Text("Reject User", style: TextStyle(color: Colors.redAccent)),
          content: TextField(
            controller: commentController, maxLines: 3, 
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.05), hintText: "Reason..."),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                 if(commentController.text.isEmpty) return;
                 Navigator.pop(context); // Close dialog
                 Navigator.pop(context); // Close Hero
                 pendingController.updateUserStatus(userId: user.id, approvalStatus: "Rejected", comment: commentController.text);
              },
              child: const Text("Reject", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      });
  }

  void _showEditDialog(BuildContext context) {
       final statusOptions = [AppConstants.roles.userStatusPending, AppConstants.roles.userStatusApproved, AppConstants.roles.userStatusRejected];
       final selectedStatus = RxString(user.approvalStatus);
       showDialog(
         context: context,
         builder: (_) {
           return AlertDialog(
             backgroundColor: const Color(0xFF1E1E1E),
             title: const Text("Edit Status", style: TextStyle(color: Colors.white)),
             content: Obx(() => DropdownButtonFormField<String>(
                value: selectedStatus.value,
                dropdownColor: const Color(0xFF2C2C2C),
                items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => selectedStatus.value = v!,
             )),
             actions: [
               TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
               ElevatedButton(onPressed: () async {
                  await rejectedController.updateUserThroughAdmin(userId: user.id, status: selectedStatus.value);
                  Get.back(); // close dialog
                  Navigator.pop(context); // close hero
               }, child: const Text("Update"))
             ]
           );
         }
       );
  }
}
