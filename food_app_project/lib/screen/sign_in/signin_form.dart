import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../assets/images.dart';
import '../../handle_api/handle_api.dart';
import '../../model/error_response.dart';
import '../../model/login/login_request.dart';
import '../../model/login/login_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../../util/share_preferences.dart';
import '../../util/show_loading_dialog.dart';
import '../home/home_page.dart';
import '../sign_up/sign_up_page.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isShowPassword = false;

  Future<void> loginApi(LoginRequest loginRequest) async {
    IsShowDialog().showLoadingDialog(context);

    LoginResponse loginResponse;
    ErrorResponse? errorResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/auth/login"),
        RequestType.post,
        headers: null,
        body: const JsonEncoder().convert(loginRequest.toBodyRequest()),
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (body == null) return;

      if (body.containsKey('statusCode')) {
        errorResponse = ErrorResponse.fromJson(body);

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
        loginResponse = LoginResponse.fromJson(body);

        ConfigSharedPreferences().setStringValue(
          SharedData.TOKEN.toString(),
          loginResponse.token ?? "",
        );

        ConfigSharedPreferences().setStringValue(
          SharedData.EMAIL.toString(),
          loginResponse.userResponse?.email ?? "",
        );

        ConfigSharedPreferences().setStringValue(
          SharedData.ID.toString(),
          loginResponse.userResponse?.id ?? "",
        );

        ConfigSharedPreferences().setStringValue(
          SharedData.NAME.toString(),
          loginResponse.userResponse?.name ?? "",
        );

        Global.token = loginResponse.token ?? "";

        Fluttertoast.showToast(
          msg: "Login successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          fontSize: 16,
        );

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            HomePage.routeName,
                (Route<dynamic> route) => false,
          );
        }
      }
    } catch (error) {
      debugPrint("Fail to login $error");

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      Fluttertoast.showToast(
        msg: "Login failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );

      rethrow;
    }
  }

  void handleLogin() {
    if (!Global.isAvailableToClick()) return;

    final email = usernameController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter email and password!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    if (!Global().checkEmailAddress(email)) {
      Fluttertoast.showToast(
        msg: "Invalid email. Please try again!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    LoginRequest loginRequest = LoginRequest(email, password);
    loginApi(loginRequest);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          headerSection(),
          const SizedBox(height: 28),
          formCard(),
        ],
      ),
    );
  }

  Widget headerSection() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Welcome Back",
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sign in to continue ordering your favorite meals.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget formCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          emailField(),
          const SizedBox(height: 16),
          passwordField(),
          const SizedBox(height: 22),
          loginButton(),
          const SizedBox(height: 20),
          const Text(
            "or continue with",
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          socialButtons(),
          const SizedBox(height: 22),
          signUpRow(),
        ],
      ),
    );
  }

  Widget emailField() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: usernameController,
        keyboardType: TextInputType.emailAddress,
        cursorColor: AppColors.primary,
        decoration: const InputDecoration(
          hintText: "Email address",
          hintStyle: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.email_rounded,
            color: AppColors.textGrey,
          ),
        ),
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget passwordField() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        obscureText: !isShowPassword,
        controller: passwordController,
        keyboardType: TextInputType.text,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: "Password",
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
            onTap: () {
              setState(() {
                isShowPassword = !isShowPassword;
              });
            },
            child: Icon(
              isShowPassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget loginButton() {
    return InkWell(
      onTap: handleLogin,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
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
              color: AppColors.primary.withOpacity(0.26),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Text(
          "Sign In",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        socialButton(
          child: const Icon(
            Icons.facebook_outlined,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 14),
        socialButton(
          child: Image.asset(ImageAssets.icGoogle),
        ),
        const SizedBox(width: 14),
        socialButton(
          child: Image.asset(ImageAssets.icTwitter),
        ),
      ],
    );
  }

  Widget socialButton({required Widget child}) {
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget signUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpPage(),
              ),
            );
          },
          child: const Text(
            "Sign up",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}