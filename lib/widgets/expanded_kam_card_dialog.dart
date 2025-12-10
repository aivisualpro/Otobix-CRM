import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/models/kam_model.dart';
import 'package:otobix_crm/utils/app_colors.dart';
import 'package:otobix_crm/widgets/button_widget.dart';
import 'package:otobix_crm/admin/controller/admin_kam_controller.dart';
import 'package:otobix_crm/widgets/glass_container.dart';

class ExpandedKamCardDialog extends StatelessWidget {
  final KamModel kam;
  final String heroTag;

  ExpandedKamCardDialog({
    super.key,
    required this.kam,
    required this.heroTag,
  });

  final kamController = Get.find<AdminKamController>();

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
                width: 500,
                decoration: BoxDecoration(
                   color: const Color(0xFF1E2430).withOpacity(0.95),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.blueAccent.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.manage_accounts, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "KAM Details",
                style: TextStyle(
                  color: Colors.blueAccent,
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
             radius: 36,
             backgroundColor: Colors.white.withOpacity(0.1),
             child: Text(
               kam.name.isNotEmpty ? kam.name.substring(0, 1).toUpperCase() : "?",
               style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
             ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kam.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 14, color: Colors.white54),
                  const SizedBox(width: 6),
                  Text(
                    kam.email,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.blueAccent),
                  const SizedBox(width: 6),
                  Text(
                    kam.region,
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w500),
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
      alignment: WrapAlignment.start,
      children: [
        _infoItem("Phone", kam.phoneNumber, Icons.phone_outlined),
        _infoItem("Region", kam.region, Icons.map_outlined),
        _infoItem("Created On", DateFormat('dd MMM yyyy').format(kam.createdAt.toLocal()), Icons.calendar_today_outlined),
      ],
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 180,
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
           Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
            width: 130,
            child: ButtonWidget(
              text: 'Delete',
              isLoading: false.obs,
              height: 45,
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              textColor: Colors.redAccent,
              borderColor: Colors.redAccent.withOpacity(0.2),
              onTap: () {
                _showDeleteConfirm(context);
              },
            ),
          ),
          const SizedBox(width: 16),
           SizedBox(
             width: 130,
            child: ButtonWidget(
              text: 'Edit Details',
              isLoading: false.obs,
              height: 45,
              backgroundColor: Colors.blueAccent,
              textColor: Colors.white,
              onTap: () {
                 _showEditDialog(context);
              },
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context) {
      showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white10)),
          title: const Text("Delete KAM", style: TextStyle(color: Colors.redAccent)),
          content: Text("Are you sure you want to delete '${kam.name}'?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                 Navigator.pop(ctx); 
                 final ok = await kamController.deleteKam(kam.id);
                 if(ok) Navigator.pop(context); // close hero
              },
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      });
  }

  void _showEditDialog(BuildContext context) {
     kamController.nameController.text = kam.name;
     kamController.emailController.text = kam.email;
     kamController.phoneController.text = kam.phoneNumber;
     kamController.regionController.text = kam.region;

     Get.dialog(
        Dialog(
         backgroundColor: Colors.transparent,
         insetPadding: const EdgeInsets.all(20),
         child: GlassContainer(
           width: 500,
           padding: EdgeInsets.zero,
           child: SingleChildScrollView(
             child: Padding(
               padding: const EdgeInsets.all(24),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    const Text("Edit KAM", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 24),
                    _editField(kamController.nameController, "Name", Icons.person_outline),
                    const SizedBox(height: 16),
                    _editField(kamController.emailController, "Email", Icons.email_outlined),
                    const SizedBox(height: 16),
                    _editField(kamController.phoneController, "Phone", Icons.phone_outlined),
                    const SizedBox(height: 16),
                    _editField(kamController.regionController, "Region", Icons.map_outlined),
                    const SizedBox(height: 32),
                     Row(
                       children: [
                         Expanded(
                           child: ButtonWidget(
                             text: "Cancel", isLoading: false.obs, 
                             backgroundColor: Colors.white10,
                             onTap: () => Get.back(),
                           ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: ButtonWidget(
                             text: "Save Changes", isLoading: kamController.isSaving,
                             backgroundColor: Colors.blueAccent,
                             onTap: () async {
                                final ok = await kamController.updateKam(kam);
                                if(ok) {
                                  Get.back(); // close dialog
                                  Navigator.pop(context); // close hero
                                }
                             },
                           ),
                         ),
                       ],
                     )
                 ],
               ),
             ),
           ),
         ),
       )
     );
  }

  Widget _editField(TextEditingController ctrl, String hint, IconData icon) {
     return TextField(
       controller: ctrl,
       style: const TextStyle(color: Colors.white),
       decoration: InputDecoration(
         filled: true,
         fillColor: Colors.white.withOpacity(0.05),
         hintText: hint,
         hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
         prefixIcon: Icon(icon, color: Colors.blueAccent),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
       ),
     );
  }
}
