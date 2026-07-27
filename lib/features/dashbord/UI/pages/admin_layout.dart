import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/dashbord/UI/pages/dashbord_page.dart';

class AdminLayout extends StatefulWidget {
  final Widget? body; // يُستخدم فقط إذا أردنا فتح صفحة فرعية طارئة مثل التفاصيل
  final int initialIndex;

  const AdminLayout({super.key, this.body, this.initialIndex = 0});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onSidebarItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // قائمة الصفحات الرئيسية المتطابقة مع عناصر السايد بار
    final List<Widget> pages = [
      const DashboardHomeWrapper(), // 0: لوحة التحكم
      const Center(
        child: Text('صفحة العيادات الرئيسية'),
      ), // 1: العيادات (سنستبدلها بـ ClinicsPage)
      const Center(child: Text('صفحة الأطباء')), // 2: الأطباء
      const Center(child: Text('صفحة المرضى')), // 3: المرضى
      const Center(child: Text('صفحة السكرتارية')), // 4: السكرتارية
      const Center(child: Text('صفحة الإعدادات')), // 5: الإعدادات
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. السايد بار الثابت (Sidebar)
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
                          _selectedIndex == 0 && widget.body == null,
                          () => _onSidebarItemSelected(0),
                        ),
                        _buildSidebarItem(
                          Icons.local_hospital_outlined,
                          'العيادات',
                          _selectedIndex == 1 || widget.body != null,
                          () => _onSidebarItemSelected(1),
                        ),
                        _buildSidebarItem(
                          Icons.medical_services_outlined,
                          'الأطباء',
                          _selectedIndex == 2 && widget.body == null,
                          () => _onSidebarItemSelected(2),
                        ),
                        _buildSidebarItem(
                          Icons.people_outline,
                          'المرضى',
                          _selectedIndex == 3 && widget.body == null,
                          () => _onSidebarItemSelected(3),
                        ),
                        _buildSidebarItem(
                          Icons.badge_outlined,
                          'السكرتارية',
                          _selectedIndex == 4 && widget.body == null,
                          () => _onSidebarItemSelected(4),
                        ),
                        _buildSidebarItem(
                          Icons.settings_outlined,
                          'الإعدادات',
                          _selectedIndex == 5 && widget.body == null,
                          () => _onSidebarItemSelected(5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. المحتوى المتغير (Dynamic Body)
            Expanded(
              child:
                  widget.body ??
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
}
