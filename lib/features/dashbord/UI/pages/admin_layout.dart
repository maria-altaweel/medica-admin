import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/UI/pages/clinics_screen.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/dashbord/UI/pages/dashbord_page.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/ui/pages/doctors_screen.dart'; // 👈 استيراد شاشة الأطباء
import 'package:medica_admin/features/secretaries/UI/pages/seretaries_screen.dart';
import 'package:medica_admin/features/secretaries/logic/secretary_cubit/secretary_cubit.dart';

class AdminLayout extends StatefulWidget {
  final Widget? body;
  final int initialIndex;

  const AdminLayout({super.key, this.body, this.initialIndex = 0});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  late int _selectedIndex;
  Widget? _currentCustomBody;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _currentCustomBody = widget.body;
  }

  @override
  void didUpdateWidget(covariant AdminLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.body != oldWidget.body) {
      setState(() {
        _currentCustomBody = widget.body;
      });
    }
  }

  void _onSidebarItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _currentCustomBody = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 قائمة الصفحات متطابقة مع أرقام الاندكس
    final List<Widget> pages = [
      const DashboardHomeWrapper(), // 0: لوحة التحكم
      BlocProvider(
        // 1: العيادات
        create: (context) => getIt<ClinicsBloc>(),
        child: const ClinicsScreen(),
      ),
      // 2: قائمة الأطباء 🩺
      BlocProvider(
        create: (context) => getIt<DoctorCubit>(),
        child: const DoctorsScreen(isRequestsView: false),
      ),
      // 3: طلبات انضمام الأطباء 📋
      BlocProvider(
        create: (context) => getIt<DoctorCubit>(),
        child: const DoctorsScreen(isRequestsView: true),
      ),
      const Center(child: Text('صفحة المرضى')), // 4: المرضى
      BlocProvider(
        // 5: السكرتارية
        create: (context) => getIt<SecretaryCubit>(),
        child: const SecretariesScreen(),
      ),
      const Center(child: Text('صفحة الإعدادات')), // 6: الإعدادات
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السايد بار
            Container(
              width: 260,
              color: const Color(0xFF0F172A),
              child: Column(
                children: [
                  // بيانات المدير
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أحمد المدير',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'مدير النظام',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF334155), height: 1),

                  // أزرار السايد بار
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      children: [
                        _buildSidebarItem(
                          Icons.home,
                          'لوحة التحكم',
                          _selectedIndex == 0 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(0),
                        ),
                        _buildSidebarItem(
                          Icons.local_hospital_outlined,
                          'العيادات',
                          _selectedIndex == 1 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(1),
                        ),

                        // 🩺 ExpansionTile للأطباء والقوائم الفرعية
                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: const Icon(
                              Icons.medical_services_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                            title: const Text(
                              'الأطباء',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            initiallyExpanded:
                                _selectedIndex == 2 || _selectedIndex == 3,
                            children: [
                              _buildSubSidebarItem(
                                'قائمة الأطباء',
                                _selectedIndex == 2 &&
                                    _currentCustomBody == null,
                                () => _onSidebarItemSelected(2),
                              ),
                              _buildSubSidebarItem(
                                'طلبات الانضمام',
                                _selectedIndex == 3 &&
                                    _currentCustomBody == null,
                                () => _onSidebarItemSelected(3),
                              ),
                            ],
                          ),
                        ),

                        _buildSidebarItem(
                          Icons.people_outline,
                          'المرضى',
                          _selectedIndex == 4 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(4),
                        ),
                        _buildSidebarItem(
                          Icons.badge_outlined,
                          'السكرتارية',
                          _selectedIndex == 5 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(5),
                        ),
                        _buildSidebarItem(
                          Icons.settings_outlined,
                          'الإعدادات',
                          _selectedIndex == 6 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // المحتوى الرئيسي
            Expanded(
              child:
                  _currentCustomBody ??
                  IndexedStack(index: _selectedIndex, children: pages),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        onTap: onTap,
      ),
    );
  }

  // ودجت المكونات الفرعية لداخل الأطباء
  Widget _buildSubSidebarItem(String title, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 36, left: 12, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.8)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
