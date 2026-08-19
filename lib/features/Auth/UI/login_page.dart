import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart'; // مسار السناك بار المخصص تبعك
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
      backgroundColor: const Color(0xFFF4F7FC), // خلفية ويب رايقة
      body: BlocListener<AuthBloc, AuthState>(
        // ==========================================
        // هنا تتم هندلة وعرض الأخطاء والنجاح
        // ==========================================
        listener: (context, state) {
          if (state is LoginSuccess) {
            Appsnackbar.showSuccess(context, "تم تسجيل الدخول بنجاح");
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.dashboardScreen,
              (route) => false,
            );
          } else if (state is LoginError) {
            // سيتم عرض رسالة الخطأ (إنترنت، بيانات خاطئة) المبعوثة من الـ Bloc
            Appsnackbar.showError(context, state.message);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Directionality(
              // إجبار الواجهة تكون من اليمين لليسار
              textDirection: TextDirection.rtl,
              child: Container(
                width: 1000,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ==========================================
                    // القسم الأيمن: نموذج تسجيل الدخول
                    // ==========================================
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // شعار التطبيق
                              Center(
                                child: Image.asset(
                                  'assets/images/cded31803db071b98fad1c729a1dcde0ce4b4ff6.png',
                                  height: 70,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // النصوص الترحيبية
                              const Text(
                                "تسجيل الدخول",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "مرحباً بك في نظام إدارة العيادات، الرجاء إدخال بياناتك",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF718096),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // حقل رقم الهاتف مع تحقق محلي (Client-Side Validation)
                              AppTextField(
                                controller: phoneController,
                                hintText: "05xxxxxxxx",
                                prefixIcon: Icons.phone_outlined,
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

                              // حقل كلمة المرور
                              AppTextField(
                                controller: passwordController,
                                hintText: "كلمة المرور",
                                isPassword: true,
                                prefixIcon: Icons.lock_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "كلمة المرور مطلوبة";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 40),

                              // زر الدخول
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is LoginLoading) {
                                    return const Center(
                                      child: AppLoadingIndicator(),
                                    );
                                  }
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: AppButton(
                                      text: "دخول للوحة التحكم",
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          // إرسال حدث تسجيل الدخول للبلوك
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
                    // ==========================================
                    // القسم الأيسر: تصميم عصري بالـ Code
                    // ==========================================
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                "Medica Admin",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "نظام الإدارة الشامل",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
