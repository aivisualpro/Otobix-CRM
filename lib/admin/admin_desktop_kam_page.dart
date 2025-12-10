import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:otobix_crm/admin/controller/admin_kam_controller.dart';
import 'package:otobix_crm/models/kam_model.dart';
import 'package:otobix_crm/utils/app_colors.dart' show AppColors;
import 'package:otobix_crm/utils/hero_dialog_route.dart';
import 'package:otobix_crm/widgets/button_widget.dart';
import 'package:otobix_crm/widgets/empty_data_widget.dart';
import 'package:otobix_crm/widgets/expanded_kam_card_dialog.dart';
import 'package:otobix_crm/widgets/glass_container.dart';
import 'package:otobix_crm/widgets/refresh_page_widget.dart';
import 'package:otobix_crm/widgets/shimmer_widget.dart';
import 'dart:ui' as ui;

class AdminDesktopKamPage extends StatelessWidget {
  AdminDesktopKamPage({super.key});

  final AdminKamController kamController =
      Get.put(AdminKamController(), permanent: true);

  // Search
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage("assets/images/dashboard_bg.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Header
                   _buildHeader(context),
                   const SizedBox(height: 32),
                   
                   // Content
                   Expanded(
                     child: Obx(() {
                        if (kamController.isLoading.value) {
                          return GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, mainAxisExtent: 160
                            ),
                            itemCount: 6,
                            itemBuilder: (_, __) => _buildShimmerCard(),
                          );
                        }

                        if (kamController.error.value != null) {
                          return RefreshPageWidget(
                            icon: Icons.error_outline,
                            title: "Error",
                            message: kamController.error.value!,
                            actionText: "Retry",
                            onAction: kamController.fetchKamsList,
                          );
                        }
                        
                        // Filter
                        final kams = kamController.kams.where((k) {
                           final q = searchQuery.value.toLowerCase().trim();
                           return k.name.toLowerCase().contains(q) || k.email.toLowerCase().contains(q); 
                        }).toList();

                        if (kams.isEmpty) {
                           return Center(child: EmptyDataWidget(message: "No KAMs found."));
                        }

                        return GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, mainAxisExtent: 160
                            ),
                            itemCount: kams.length,
                            itemBuilder: (ctx, i) => _buildKamCard(kams[i], ctx),
                          );
                     }),
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Key Account Managers",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        
        // Search & Add
        Row(
           children: [
              SizedBox(
                width: 300,
                height: 48,
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                     filled: true,
                     fillColor: Colors.white.withOpacity(0.05),
                     hintText: "Search KAMs...",
                     hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                     prefixIcon: const Icon(Icons.search, color: Colors.white38),
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                     ),
                     contentPadding: const EdgeInsets.only(top: 10),
                  ),
                  onChanged: (val) => searchQuery.value = val,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                   icon: const Icon(Icons.add, color: Colors.black),
                   label: const Text("Add KAM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                   style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                   ),
                   onPressed: () => _showAddDialog(),
                ),
              )
           ],
        )
      ],
    );
  }

  Widget _buildKamCard(KamModel kam, BuildContext context) {
     final heroTag = 'kam-${kam.id}';
     return GestureDetector(
       onTap: () {
          Navigator.push(context, HeroDialogRoute(builder: (_) => ExpandedKamCardDialog(kam: kam, heroTag: heroTag)));
       },
       child: Hero(
         tag: heroTag,
         createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
         child: Material(
           color: Colors.transparent,
           child: Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(20),
               border: Border.all(color: Colors.white.withOpacity(0.1)),
               color: const Color(0xFF1E2430).withOpacity(0.6), 
               boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
               ]
             ),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(20),
               child: BackdropFilter(
                 filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                 child: Row(
                   children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
                        child: CircleAvatar(
                           radius: 28,
                           backgroundColor: Colors.white.withOpacity(0.1),
                           child: Text(kam.name.isNotEmpty ? kam.name[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text(kam.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                             const SizedBox(height: 4),
                             Text(kam.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                             const SizedBox(height: 8),
                             Row(
                               children: [
                                  Icon(Icons.map_outlined, size: 12, color: Colors.blueAccent),
                                  const SizedBox(width: 4),
                                  Text(kam.region, style: const TextStyle(color: Colors.blueAccent, fontSize: 11, fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.phone_outlined, size: 12, color: Colors.white38),
                                  const SizedBox(width: 4),
                                  Text(kam.phoneNumber, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                               ],
                             )
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
     );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(20),
         color: Colors.white.withOpacity(0.05),
      ),
      child: const ShimmerWidget(width: double.infinity, height: double.infinity, borderRadius: 20),
    );
  }

  void _showAddDialog() {
     final kamController = Get.find<AdminKamController>();
     kamController.nameController.clear();
     kamController.emailController.clear();
     kamController.phoneController.clear();
     kamController.regionController.clear();
     
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
                    const Text("Add New KAM", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 24),
                    _editField(kamController.nameController, "Name", Icons.person_outline),
                    const SizedBox(height: 16),
                    _editField(kamController.emailController, "Email", Icons.email_outlined),
                    const SizedBox(height: 16),
                    _editField(kamController.phoneController, "Phone", Icons.phone_outlined, isNumber: true),
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
                             text: "Create KAM", isLoading: kamController.isSaving,
                             backgroundColor: AppColors.neonGreen,
                             textColor: Colors.black,
                             onTap: () async {
                                final ok = await kamController.createKam();
                                if(ok) Get.back();
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

  Widget _editField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
     return TextField(
       controller: ctrl,
       keyboardType: isNumber ? TextInputType.number : TextInputType.text,
       inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
       style: const TextStyle(color: Colors.white),
       decoration: InputDecoration(
         filled: true,
         fillColor: Colors.white.withOpacity(0.05),
         hintText: hint,
         hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
         prefixIcon: Icon(icon, color: AppColors.neonGreen.withOpacity(0.7)),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
       ),
     );
  }
}
