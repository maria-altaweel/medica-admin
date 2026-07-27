import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/core/widgets/App_TextField.dart';
import 'package:medica_admin/features/Auth/logic/auth_bloc/auth_bloc.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/routing/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Appsnackbar.showSuccess(context, "تم تسجيل الدخول بنجاح");
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.dashboardScreen,
              (route) => false,
            );
          } else if (state is LoginError) {
            Appsnackbar.showError(context, state.message);
          }
        },
        child: Row(
          children: [
            // القسم الأيسر: صورة الأطباء التوضيحية
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFFEBF3FC),
                child: Center(
                  child: Image.asset(
                    'assets/images/photo_2026-07-21_14-55-15.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // القسم الأيمن: نموذج تسجيل الدخول
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: SizedBox(
                    width: 450,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // شعار التطبيق
                          Image.asset(
                            'assets/images/cded31803db071b98fad1c729a1dcde0ce4b4ff6.png',
                            height: 70,
                          ),
                          const SizedBox(height: 20),

                          // العنوان تماماً كما في التصميم
                          const Text(
                            "مرحباً بك في نظام إدارة العيادات",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // حقل رقم الهاتف مع أيقونة الهاتف الحقيقية كما صممتها
                          AppTextField(
                            controller: phoneController,
                            hintText: "05xxxxxxxx",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length != 10) {
                                return "يرجى إدخال رقم هاتف صحيح (10 أرقام)";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // حقل كلمة المرور مع أيقونة القفل وحجب النص
                          AppTextField(
                            controller: passwordController,
                            hintText: "****",
                            isPassword: true,
                            prefixIcon: Icons.lock,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "كلمة المرور مطلوبة";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // زر تسجيل الدخول (مع حالة اللودينغ)
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is LoginLoading) {
                                return const AppLoadingIndicator();
                              }
                              return SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: AppButton(
                                  text: "تسجيل الدخول",
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        LoginEvent(
                                          phone: phoneController.text,
                                          password: passwordController.text,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
