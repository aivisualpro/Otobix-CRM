import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otobix_crm/admin/Admin_Home_View.dart';
import 'package:otobix_crm/admin/admin_dashboard.dart';
import 'package:otobix_crm/admin/admin_desktop_dashboard.dart';
import 'package:otobix_crm/network/api_service.dart';
import 'package:otobix_crm/utils/app_constants.dart';
import 'package:otobix_crm/utils/app_urls.dart';
import 'package:otobix_crm/utils/responsive_layout.dart';
import 'package:otobix_crm/utils/shared_prefs_helper.dart';
import 'package:otobix_crm/views/desktop_homepage.dart';
import 'package:otobix_crm/widgets/toast_widget.dart';

class LoginController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    clearFields();
  }

  RxBool isLoading = false.obs;
  RxBool obsecureText = true.obs;
  final userNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  Future<void> loginUser() async {
    isLoading.value = true;
    try {
      String dealerName = userNameController.text.trim();
      String contactNumber = phoneNumberController.text.trim();
      String password = passwordController.text.trim();

      final requestBody = {
        "userName": dealerName,
        "phoneNumber": contactNumber,
        "password": password,
      };

      final response = await ApiService.post(
        endpoint: AppUrls.login,
        body: requestBody,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];
        final userRole = user['userType'];
        final userId = user['id'];
        final userImageUrl = user['imageUrl'];
        final approvalStatus = user['approvalStatus'];
        final userName = user['userName'];
        final userEmail = user['email'];
        final userPhone = user['phoneNumber'];

        // Permissions field
        final permissions = user['permissions'] as List<dynamic>? ?? [];
        print("permission after response $permissions");
        // ✅ Store all user data
        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.permissionsKey,
          jsonEncode(permissions),
        );
        print(token);
        await SharedPrefsHelper.saveString(SharedPrefsHelper.tokenKey, token);
        print("token saved in preference");
        await SharedPrefsHelper.saveString(
            SharedPrefsHelper.userKey, jsonEncode(user));
        await SharedPrefsHelper.saveString(SharedPrefsHelper.userIdKey, userId);
        await SharedPrefsHelper.saveString(
            SharedPrefsHelper.userNameKey, userName);
        await SharedPrefsHelper.saveString(
            SharedPrefsHelper.userEmailKey, userEmail);
        await SharedPrefsHelper.saveString(
            SharedPrefsHelper.userPhoneKey, userPhone);
        await SharedPrefsHelper.saveString(
            SharedPrefsHelper.userRoleKey, userRole);
        await SharedPrefsHelper.saveString(
          SharedPrefsHelper.userImageUrlKey,
          userImageUrl ?? "",
        );
        await SharedPrefsHelper.saveString(
            SharedPrefsHelper.approvalStatusKey, approvalStatus);

        // ✅ SIMPLE NAVIGATION: All approved users go to AdminDashboard
        if (approvalStatus == 'Approved') {
          Get.offAll(
            () => AdminDesktopDashboard(),
          );
        } else if (approvalStatus == 'Pending') {
          ToastWidget.show(
            context: Get.context!,
            title: "Your account is pending approval.",
            subtitle: "Please wait for administrator approval.",
            type: ToastType.warning,
          );
        } else {
          ToastWidget.show(
            context: Get.context!,
            title: "Account not approved.",
            subtitle: "Please contact administrator.",
            type: ToastType.error,
          );
        }
      } else {
        debugPrint("Failed: $data");
        ToastWidget.show(
          context: Get.context!,
          title: data['message'] ?? "Failed to login",
          subtitle: "Please try again later.",
          type: ToastType.error,
        );
      }
    } catch (error) {
      debugPrint("Error: $error");
      ToastWidget.show(
        context: Get.context!,
        title: "Error during login. Please try again.",
        subtitle: "Please try again later.",
        type: ToastType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return "Password is required.";
    if (password.length < 8) {
      return "Password must be at least 8 characters long.";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "At least one uppercase letter required.";
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "At least one lowercase letter required.";
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(password)) {
      return "At least one special character required.";
    }
    return null;
  }

  // Clear fields
  void clearFields() {
    userNameController.clear();
    phoneNumberController.clear();
    passwordController.clear();
    obsecureText.value = true;
  }
}
