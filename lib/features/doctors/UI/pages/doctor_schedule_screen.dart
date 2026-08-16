import 'package:flutter/material.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';

import 'package:medica_admin/features/doctors/UI/widgets/add_shedule_dailog.dart';
import 'package:medica_admin/features/doctors/UI/widgets/edit_schedule_dialog.dart'; // سننشئه لاحقاً
import 'package:medica_admin/features/doctors/UI/widgets/schedule_row_item.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_schedule_model.dart';
import 'package:medica_admin/features/doctors/data/repos/doctor_repo.dart';

class DoctorScheduleScreen extends StatefulWidget {
  final int clinicId;
  final int clinicDoctorId;
  final DoctorRepository doctorRepository;

  const DoctorScheduleScreen({
    super.key,
    required this.clinicId,
    required this.clinicDoctorId,
    required this.doctorRepository,
  });

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  bool _isLoading = true;
  List<DoctorScheduleModel> _schedules = [];

  final List<String> _daysNames = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorSchedules();
  }

  // جلب جداول الطبيب الفععالة فقط من الباك إند
  Future<void> _fetchDoctorSchedules() async {
    setState(() => _isLoading = true);
    try {
      final fetchedSchedules = await widget.doctorRepository.getDoctorSchedules(
        clinicId: widget.clinicId,
        clinicDoctorId: widget.clinicDoctorId,
      );
      setState(() {
        _schedules = fetchedSchedules;
      });
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // فتح ديالوج إضافة جدول جديد
  void _openAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(
        onSave: (dayOfWeek, startTime, endTime, isActive) async {
          // استدعاء دالة الحفظ أو الإضافة الخاصة بالباك إند ثم تحديث القائمة
          await _saveOrUpdateSchedule(
            DoctorScheduleModel(
              dayOfWeek: dayOfWeek,
              startTime: startTime,
              endTime: endTime,
              isActive: isActive,
            ),
          );
        },
      ),
    );
  }

  // فتح ديالوج تعديل جدول يوم موجود
  void _openEditDialog(DoctorScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) => EditScheduleDialog(
        dayName: _daysNames[schedule.dayOfWeek],
        existingSchedule: schedule,
        onSave: (startTime, endTime, isActive) async {
          await _saveOrUpdateSchedule(
            DoctorScheduleModel(
              dayOfWeek: schedule.dayOfWeek,
              startTime: startTime,
              endTime: endTime,
              isActive: isActive,
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveOrUpdateSchedule(
    DoctorScheduleModel updatedSchedule,
  ) async {
    try {
      List<DoctorScheduleModel> newList = List.from(_schedules);
      int index = newList.indexWhere(
        (s) => s.dayOfWeek == updatedSchedule.dayOfWeek,
      );
      if (index >= 0) {
        newList[index] = updatedSchedule;
      } else {
        newList.add(updatedSchedule);
      }

      await widget.doctorRepository.setDoctorSchedules(
        clinicId: widget.clinicId,
        clinicDoctorId: widget.clinicDoctorId,
        schedules: newList,
      );

      if (mounted) {
        Appsnackbar.showSuccess(context, "تم تحديث جدول دوام الطبيب بنجاح");
        _fetchDoctorSchedules();
      }
    } catch (e) {
      // 🕵️ حملة كشف الأخطاء: طباعة الخطأ الأصلي في الكونسول لتستطيع رؤيته ومعرفته
      debugPrint("=== 🚨 SCHEDULE UNHANDLED ERROR: $e ===");

      if (mounted) {
        String errorMessage = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.";
        final errorStr = e.toString().toLowerCase();

        if (errorStr.contains("socket") ||
            errorStr.contains("network") ||
            errorStr.contains("connection") ||
            errorStr.contains("internet") ||
            errorStr.contains("failed host lookup")) {
          errorMessage =
              "لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة لاحقاً.";
        } else if (errorStr.contains("format") || errorStr.contains("h:i")) {
          errorMessage = "يرجى التحقق من صيغة الأوقات المدخلة.";
        } else if (errorStr.contains("duplicate") ||
            errorStr.contains("unique") ||
            errorStr.contains("exists")) {
          errorMessage = "هذا اليوم مضاف مسبقاً، يمكنك تعديله بدلاً من إضافته.";
        }

        Appsnackbar.showError(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: const Text(
          "تفاصيل الطبيب > جدول الدوام",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "جدول دوام الطبيب",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _openAddDialog,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "إضافة جدول",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          // رأس الجدول بلون فاتح ومتوافق مع التصميم
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors
                                  .textField, // لون فاتح بدلاً من الأسود
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    "#",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "اليوم",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "من",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "إلى",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "الحالة",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "الإجراء",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // عرض الأيام المضافة فقط القادمة من الباك إند
                          Expanded(
                            child: _schedules.isEmpty
                                ? const Center(
                                    child: Text(
                                      "لا يوجد جدول دوام مضاف",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _schedules.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                          height: 1,
                                          color: AppColors.borderColor,
                                        ),
                                    itemBuilder: (context, index) {
                                      final schedule = _schedules[index];
                                      return ScheduleRowItem(
                                        index: index + 1,
                                        dayName: _daysNames[schedule.dayOfWeek],
                                        schedule: schedule,
                                        onEditPressed: () =>
                                            _openEditDialog(schedule),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
