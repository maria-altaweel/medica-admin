import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/UI/pages/clinics_screen.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/dashbord/UI/pages/dashbord_page.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/ui/pages/doctors_screen.dart';
import 'package:medica_admin/features/leaves/UI/pages/leaves_requests_screen.dart';
import 'package:medica_admin/features/leaves/logic/leave_cubit/leave_cubit.dart';
import 'package:medica_admin/features/salaries/UI/pages/create_salary_screen.dart';
import 'package:medica_admin/features/salaries/UI/pages/salaries_screen.dart';
import 'package:medica_admin/features/salaries/logic/salary_cubit/salary_cubit.dart';
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
    // 0: لوحة التحكم
    // 1: العيادات
    // 2: الأطباء
    // 3: طلبات انضمام الأطباء
    // 4: طلبات الإجازة
    // 5: قائمة الرواتب (جديد)
    // 6: إنشاء رواتب (جديد)
    // 7: السكرتارية (كان 6)
    // 8: الإعدادات (كان 7)
    final List<Widget> pages = [
      const DashboardHomeWrapper(),
      BlocProvider(
        create: (context) => getIt<ClinicsBloc>(),
        child: const ClinicsScreen(),
      ),
      BlocProvider(
        create: (context) => getIt<DoctorCubit>(),
        child: const DoctorsScreen(isRequestsView: false),
      ),
      BlocProvider(
        create: (context) => getIt<DoctorCubit>(),
        child: const DoctorsScreen(isRequestsView: true),
      ),
      BlocProvider(
        create: (context) => getIt<LeaveCubit>(),
        child: const LeaveRequestsScreen(),
      ),
      BlocProvider(
        create: (context) => getIt<SalaryCubit>(),
        child: SalariesScreen(
          onNavigateToCreateSalary: () {
            _onSidebarItemSelected(
              6,
            ); // الانتقال للتاب رقم 6 (صفحة إنشاء رواتب)
          },
        ),
      ),
      BlocProvider(
        create: (context) => getIt<SalaryCubit>(),
        child: const CreateSalaryScreen(),
      ),
      BlocProvider(
        create: (context) => getIt<SecretaryCubit>(),
        child: const SecretariesScreen(),
      ), // 7
      const Center(child: Text('صفحة الإعدادات')), // 8
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 260,
              color: const Color(0xFF0F172A),
              child: Column(
                children: [
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

                        // قائمة الأطباء
                        _buildExpansionTile(
                          icon: Icons.medical_services_outlined,
                          title: 'الأطباء',
                          isExpanded:
                              _selectedIndex == 2 || _selectedIndex == 3,
                          children: [
                            _buildSubSidebarItem(
                              'قائمة الأطباء',
                              _selectedIndex == 2 && _currentCustomBody == null,
                              () => _onSidebarItemSelected(2),
                            ),
                            _buildSubSidebarItem(
                              'طلبات الانضمام',
                              _selectedIndex == 3 && _currentCustomBody == null,
                              () => _onSidebarItemSelected(3),
                            ),
                          ],
                        ),

                        _buildSidebarItem(
                          Icons.date_range_outlined,
                          'طلبات الإجازة',
                          _selectedIndex == 4 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(4),
                        ),

                        // قائمة الرواتب (جديد)
                        _buildExpansionTile(
                          icon: Icons.payments_outlined,
                          title: 'الرواتب',
                          isExpanded:
                              _selectedIndex == 5 || _selectedIndex == 6,
                          children: [
                            _buildSubSidebarItem(
                              'قائمة الرواتب',
                              _selectedIndex == 5 && _currentCustomBody == null,
                              () => _onSidebarItemSelected(5),
                            ),
                            _buildSubSidebarItem(
                              'إنشاء رواتب',
                              _selectedIndex == 6 && _currentCustomBody == null,
                              () => _onSidebarItemSelected(6),
                            ),
                          ],
                        ),

                        _buildSidebarItem(
                          Icons.badge_outlined,
                          'السكرتارية',
                          _selectedIndex == 7 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(7),
                        ),
                        _buildSidebarItem(
                          Icons.settings_outlined,
                          'الإعدادات',
                          _selectedIndex == 8 && _currentCustomBody == null,
                          () => _onSidebarItemSelected(8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  // المساعد لإنشاء القائمة المنسدلة (ExpansionTile)
  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        initiallyExpanded: isExpanded,
        children: children,
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
