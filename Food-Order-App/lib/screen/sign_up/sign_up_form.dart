import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../handle_api/handle_api.dart';
import '../../model/error_response.dart';
import '../../model/register/register_request.dart';
import '../../model/register/register_response.dart';
import '../../util/app_colors.dart';
import '../../util/global.dart';
import '../../util/show_loading_dialog.dart';
import '../sign_in/sign_in_page.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();

  bool isShowPassword = false;
  bool isShowConfirmPassword = false;

  Future<void> registerApi(RegisterRequest registerRequest) async {
    IsShowDialog().showLoadingDialog(context);

    RegisterResponse registerResponse;
    ErrorResponse? errorResponse;
    Map<String, dynamic>? body;

    try {
      body = await HttpHelper.invokeHttp(
        Uri.parse("${Global.apiAddress}/api/auth/register"),
        RequestType.post,
        headers: null,
        body: const JsonEncoder().convert(registerRequest.toBodyRequest()),
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
        registerResponse = RegisterResponse.fromJson(body);

        Fluttertoast.showToast(
          msg: "Register successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          fontSize: 16,
        );

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            SignInPage.routeName,
                (Route<dynamic> route) => false,
          );
        }
      }
    } catch (error) {
      debugPrint("Fail to register $error");

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      Fluttertoast.showToast(
        msg: "Register failed. Please try again.",
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

  void handleRegister() {
    if (!Global.isAvailableToClick()) return;

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter enough information!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
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
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    if (password != confirmPassword) {
      Fluttertoast.showToast(
        msg: "Password and confirm password do not match!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    RegisterRequest registerRequest = RegisterRequest(
      fullName,
      email,
      password,
    );

    registerApi(registerRequest);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Column(
          children: [
            headerSection(),
            const SizedBox(height: 14),
            formCard(),
          ],
        ),
      ),
    );
  }

  Widget headerSection() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
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
                color: AppColors.primary.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.fastfood_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Create Account",
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Create your account and start ordering.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget formCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
          fullNameField(),
          const SizedBox(height: 11),
          emailField(),
          const SizedBox(height: 11),
          passwordField(),
          const SizedBox(height: 11),
          confirmPasswordField(),
          const SizedBox(height: 16),
          registerButton(),
          const SizedBox(height: 14),
          signInRow(),
        ],
      ),
    );
  }

  Widget fullNameField() {
    return inputContainer(
      child: TextField(
        controller: fullNameController,
        keyboardType: TextInputType.text,
        cursorColor: AppColors.primary,
        decoration: const InputDecoration(
          hintText: "Full name",
          hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.person_rounded, color: AppColors.textGrey),
        ),
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget emailField() {
    return inputContainer(
      child: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        cursorColor: AppColors.primary,
        decoration: const InputDecoration(
          hintText: "Email address",
          hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.email_rounded, color: AppColors.textGrey),
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
    return inputContainer(
      child: TextField(
        obscureText: !isShowPassword,
        controller: passwordController,
        keyboardType: TextInputType.text,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textGrey),
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

  Widget confirmPasswordField() {
    return inputContainer(
      child: TextField(
        obscureText: !isShowConfirmPassword,
        controller: confirmController,
        keyboardType: TextInputType.text,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: "Confirm password",
          hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textGrey),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                isShowConfirmPassword = !isShowConfirmPassword;
              });
            },
            child: Icon(
              isShowConfirmPassword
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

  Widget inputContainer({required Widget child}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget registerButton() {
    return InkWell(
      onTap: handleRegister,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget signInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              SignInPage.routeName,
                  (Route<dynamic> route) => false,
            );
          },
          child: const Text(
            "Sign in",
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}