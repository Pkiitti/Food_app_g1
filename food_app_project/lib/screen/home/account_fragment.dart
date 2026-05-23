import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_app_project/model/error_response.dart';

import '../../handle_api/handle_api.dart';
import '../../model/change_account/change_account_request.dart';
import '../../model/change_account/change_account_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../../util/share_preferences.dart';
import '../../util/show_loading_dialog.dart';
import '../order/order_history_page.dart';
import 'home_page.dart';

class AccountDetail extends StatefulWidget {
  const AccountDetail({Key? key}) : super(key: key);

  @override
  State<AccountDetail> createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  TextEditingController changeOldPasswordController = TextEditingController();
  TextEditingController changeNewPasswordController = TextEditingController();
  TextEditingController changeConfirmNewPasswordController =
  TextEditingController();

  String changeOldPassword = "";
  String changeNewPassword = "";
  String changeConfirmNewPassword = "";

  bool isShowChangeOldPassword = false;
  bool isShowChangeNewPassword = false;
  bool isShowChangeConfirmNewPassword = false;

  String email = "";
  String name = "";

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  Future<void> getUserInfo() async {
    final savedEmail = await ConfigSharedPreferences()
        .getStringValue(SharedData.EMAIL.toString(), defaultValue: "");

    final savedName = await ConfigSharedPreferences()
        .getStringValue(SharedData.NAME.toString(), defaultValue: "");

    setState(() {
      email = savedEmail;
      name = savedName.isNotEmpty
          ? savedName
          : savedEmail.isNotEmpty
          ? savedEmail.split("@").first
          : "Foodie";
    });
  }

  Future<void> changeAccountApi(
      ChangeAccountRequest changeAccountRequest) async {
    setState(() {
      IsShowDialog().showLoadingDialog(context);
    });

    ErrorResponse? errorResponse;
    ChangeAccountResponse changeAccountResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/auth/changePassword"),
        RequestType.put,
        headers: null,
        body: const JsonEncoder().convert(changeAccountRequest.toBodyRequest()),
      );

      if (body == null) return;

      if (body.containsKey('statusCode')) {
        errorResponse = ErrorResponse.fromJson(body);

        if (context.mounted) {
          Navigator.of(context).pop();
        }

        Fluttertoast.showToast(
          msg: errorResponse.errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: AppColors.danger,
          textColor: Colors.white,
          fontSize: 16,
        );
      } else {
        changeAccountResponse = ChangeAccountResponse.fromJson(body);

        if (context.mounted) {
          Navigator.of(context).pop();
        }

        Fluttertoast.showToast(
          msg: changeAccountResponse.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          fontSize: 16,
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          HomePage.routeName,
              (Route<dynamic> route) => false,
        );
      }
    } catch (error) {
      debugPrint("Fail to change account $error");

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      Fluttertoast.showToast(
        msg: 'Server error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );

      rethrow;
    }

    return;
  }

  void handleChangePassword() {
    if (!Global.isAvailableToClick()) return;

    if (email.isEmpty ||
        changeOldPassword.isEmpty ||
        changeNewPassword.isEmpty ||
        changeConfirmNewPassword.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter enough information!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    if (changeNewPassword != changeConfirmNewPassword) {
      Fluttertoast.showToast(
        msg: "Password and confirm password do not match!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    ChangeAccountRequest changeAccountRequest = ChangeAccountRequest(
      email,
      changeOldPassword,
      changeNewPassword,
    );

    changeAccountApi(changeAccountRequest);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          profileCard(),
          const SizedBox(height: 18),
          quickActionsCard(),
          const SizedBox(height: 18),
          changePasswordCard(),
        ],
      ),
    );
  }

  Widget profileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "F",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget quickActionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          menuTile(
            icon: Icons.receipt_long_rounded,
            title: "Order History",
            subtitle: "View your previous orders",
            iconColor: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryPage(),
                ),
              );
            },
          ),
          const Divider(height: 18),
          menuTile(
            icon: Icons.email_rounded,
            title: "Email",
            subtitle: email.isNotEmpty ? email : "No email",
            iconColor: AppColors.secondary,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textGrey,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget changePasswordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Change Password",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Keep your account secure by updating your password regularly.",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          passwordTextField(
            controller: changeOldPasswordController,
            hintText: "Old password",
            obscureText: !isShowChangeOldPassword,
            onToggle: () {
              setState(() {
                isShowChangeOldPassword = !isShowChangeOldPassword;
              });
            },
            onChanged: (value) {
              setState(() {
                changeOldPassword = value;
              });
            },
          ),
          const SizedBox(height: 14),
          passwordTextField(
            controller: changeNewPasswordController,
            hintText: "New password",
            obscureText: !isShowChangeNewPassword,
            onToggle: () {
              setState(() {
                isShowChangeNewPassword = !isShowChangeNewPassword;
              });
            },
            onChanged: (value) {
              setState(() {
                changeNewPassword = value;
              });
            },
          ),
          const SizedBox(height: 14),
          passwordTextField(
            controller: changeConfirmNewPasswordController,
            hintText: "Confirm new password",
            obscureText: !isShowChangeConfirmNewPassword,
            onToggle: () {
              setState(() {
                isShowChangeConfirmNewPassword =
                !isShowChangeConfirmNewPassword;
              });
            },
            onChanged: (value) {
              setState(() {
                changeConfirmNewPassword = value;
              });
            },
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: handleChangePassword,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const Text(
                "Update Password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TextField(
        obscureText: obscureText,
        controller: controller,
        keyboardType: TextInputType.text,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.lock_rounded,
            color: AppColors.textGrey,
          ),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscureText
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }
}