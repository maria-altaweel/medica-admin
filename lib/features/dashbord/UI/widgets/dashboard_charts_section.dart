import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/features/dashbord/data/models/dashboard_model.dart';

class DashboardChartsSection extends StatelessWidget {
  final TodayAppointments todayAppointments;
  final double monthlyRevenue;
  final num revenueChangePercentage;
  final DoctorAttendance doctorAttendance;

  const DashboardChartsSection({
    super.key,
    required this.todayAppointments,
    required this.monthlyRevenue,
    required this.revenueChangePercentage,
    required this.doctorAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. مخطط المواعيد اليومية حسب الحالة (Donut Chart)
        Expanded(
          flex: 1,
          child: Container(
            height: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المواعيد اليوم حسب الحالة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      // الرسم البياني الدائري
                      Expanded(
                        flex: 1,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 45,
                                sections: _getPieSections(),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  todayAppointments.total.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Text(
                                  'إجمالي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // مفتاح الألوان (Legend) المختصر
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: todayAppointments.byStatus.entries.map((
                              entry,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3.0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getStatusColor(entry.key),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${_getStatusArabicName(entry.key)}: ${entry.value}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 2. مخطط الإيرادات هذا الشهر (Line Chart)
        Expanded(
          flex: 1,
          child: Container(
            height: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الإيرادات هذا الشهر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$monthlyRevenue \$',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: revenueChangePercentage >= 0
                            ? AppColors.successLight
                            : AppColors.errorLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${revenueChangePercentage >= 0 ? '+' : ''}$revenueChangePercentage%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: revenueChangePercentage >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'مقارنة بالشهر الماضي',
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 20),
                // مساحة رسم الخط البياني للإيرادات
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.lightPrimary.withOpacity(0.4),
                          ),
                          spots: const [
                            FlSpot(0, 5000),
                            FlSpot(1, 8000),
                            FlSpot(2, 12000),
                            FlSpot(3, 10000),
                            FlSpot(4, 15000),
                            FlSpot(5, 20000),
                            FlSpot(6, 24560),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 3. نسبة حضور الأطباء اليوم
        Expanded(
          flex: 1,
          child: Container(
            height: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نسبة حضور الأطباء اليوم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // مؤشر دائري للحضور بحجم كبير وبارز
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: (doctorAttendance.rate / 100).toDouble(),
                                strokeWidth: 14,
                                backgroundColor: AppColors.borderColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            Text(
                              '${doctorAttendance.rate}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // تفاصيل الحاضرين والغياب
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAttendanceInfo(
                            'الحاضرون',
                            doctorAttendance.presentCount.toString(),
                            AppColors.success,
                          ),
                          _buildAttendanceInfo(
                            'الغياب',
                            doctorAttendance.absentCount.toString(),
                            AppColors.error,
                          ),
                          _buildAttendanceInfo(
                            'إجمالي الأطباء',
                            doctorAttendance.totalCount.toString(),
                            AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getPieSections() {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      AppColors.error,
      AppColors.textTertiary,
    ];

    int i = 0;
    // إذا كانت البيانات كلها أصفار، نعرض دائرة وهمية برمجياً لكي لا تختفي الدائرة وتظهر بشكل متناسق
    bool allZeros = todayAppointments.byStatus.values.every(
      (val) => (val is num ? val : 0) == 0,
    );
    if (allZeros) {
      return [
        PieChartSectionData(
          color: AppColors.borderColor,
          value: 1,
          title: '',
          radius: 35, // تم تكبير الـ radius لتصبح الدائرة ضخمة وواضحة
        ),
      ];
    }

    return todayAppointments.byStatus.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: (entry.value is num) ? (entry.value as num).toDouble() : 0.0,
        title: '',
        radius:
            35, // تم تكبير الـ radius هنا أيضاً لتصبح الدائرة متناسقة وكبيرة
      );
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'scheduled':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      case 'no_show':
        return AppColors.textTertiary;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusArabicName(String status) {
    switch (status) {
      case 'scheduled':
        return 'مجدولة';
      case 'confirmed':
        return 'مؤكدة';
      case 'checked_in':
        return 'تسجيل الحضور';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغاة';
      case 'no_show':
        return 'لم يحضر';
      default:
        return status;
    }
  }

  Widget _buildAttendanceInfo(String title, String value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
