import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/doctors/data/models/doctor_model.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_cubit.dart';
import 'package:medica_admin/features/doctors/logic/doctor_cubit/doctor_state.dart';

class DoctorRequestsTable extends StatefulWidget {
  final int clinicId;

  const DoctorRequestsTable({super.key, required this.clinicId});

  @override
  State<DoctorRequestsTable> createState() => _DoctorRequestsTableState();
}

class _DoctorRequestsTableState extends State<DoctorRequestsTable> {
  // متغير لمعرفة الإجراء الأخير الذي قام به المستخدم (لتعيين الرسالة المناسبة بدقة)
  bool? _isLastActionAccept;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        // معالجة حالات الخطأ بأسلوب عربي واضح
        if (state is ActionDoctorRequestErrorState) {
          Appsnackbar.showError(
            context,
            'فشل تنفيذ الإجراء، يرجى المحاولة لاحقاً',
          );
        } else if (state is GetDoctorRequestsErrorState) {
          Appsnackbar.showError(context, 'حدث خطأ أثناء تحميل طلبات الأطباء');
        }

        // معالجة حالة النجاح بناءً على الإجراء (قبول أو رفض)
        if (state is ActionDoctorRequestSuccessState) {
          if (_isLastActionAccept == true) {
            Appsnackbar.showSuccess(
              context,
              'تم قبول طلب انضمام الطبيب بنجاح ✅',
            );
          } else if (_isLastActionAccept == false) {
            Appsnackbar.showSuccess(
              context,
              'تم رفض طلب انضمام الطبيب بنجاح ❌',
            );
          } else {
            // رسالة افتراضية احترافية إن لم يتم تحديد الحالة
            Appsnackbar.showSuccess(context, 'تمت العملية بنجاح');
          }

          // إعادة تعيين المتغير بعد ظهور السناك بار
          _isLastActionAccept = null;

          // تحديث القائمة فوراً لجلب القائمة الجديدة
          context.read<DoctorCubit>().fetchDoctorRequests(widget.clinicId);
        }
      },
      builder: (context, state) {
        // حالة التحميل أثناء جلب الطلبات
        if (state is GetDoctorRequestsLoadingState) {
          return const Center(child: AppLoadingIndicator());
        }

        final cubit = context.read<DoctorCubit>();
        final requests = cubit.requestsList;

        if (requests.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد طلبات انضمام معلقة حالياً',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            children: [
              // الهيدر الخاص بالجدول
              _buildTableHeader(),

              // قائمة الطلبات
              Expanded(
                child: ListView.separated(
                  itemCount: requests.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderColor),
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return _buildRequestRow(context, request, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // رأس الجدول
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkHeader,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'الطبيب',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkHeader,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'التخصص',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkHeader,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الهاتف',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkHeader,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'رسوم المعاينة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkHeader,
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              'الإجراءات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkHeader,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // صف الطلب
  Widget _buildRequestRow(
    BuildContext context,
    DoctorModel request,
    int index,
  ) {
    final hasProfile =
        request.profile != null && request.profile!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),

          // الطبيب وصورته
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.lightPrimary,
                  backgroundImage: hasProfile
                      ? NetworkImage(request.profile!)
                      : null,
                  child: !hasProfile
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    request.doctorName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // التخصص
          Expanded(
            flex: 2,
            child: Text(
              request.specialization,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          // الهاتف
          Expanded(
            flex: 2,
            child: Text(
              request.doctorPhone,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),

          // رسوم المعاينة
          Expanded(
            flex: 2,
            child: Text(
              '\$ ${request.consultationFee}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // أزرار قبول ورفض
          SizedBox(
            width: 180,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      setState(() {
                        _isLastActionAccept = true; // تحديد أن الإجراء هو قبول
                      });
                      _showConfirmDialog(
                        context,
                        doctor: request,
                        isAccept: true,
                      );
                    },
                    child: const Text('قبول'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      setState(() {
                        _isLastActionAccept = false; // تحديد أن الإجراء هو رفض
                      });
                      _showConfirmDialog(
                        context,
                        doctor: request,
                        isAccept: false,
                      );
                    },
                    child: const Text('رفض'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // نافذة التأكيد قبل اتخاذ القرار
  void _showConfirmDialog(
    BuildContext context, {
    required DoctorModel doctor,
    required bool isAccept,
  }) {
    final doctorCubit = context.read<DoctorCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isAccept ? 'قبول طلب الانضمام' : 'رفض طلب الانضمام'),
        content: Text(
          isAccept
              ? 'هل أنت متأكد من قبول طلب انضمام د. ${doctor.doctorName}؟'
              : 'هل أنت متأكد من رفض طلب انضمام د. ${doctor.doctorName}؟',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isLastActionAccept = null; // إعادة تعيين في حال الإلغاء
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccept ? AppColors.success : AppColors.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              if (isAccept) {
                doctorCubit.acceptRequest(
                  clinicId: widget.clinicId,
                  clinicDoctorId: doctor.id,
                );
              } else {
                doctorCubit.rejectRequest(
                  clinicId: widget.clinicId,
                  clinicDoctorId: doctor.id,
                );
              }
            },
            child: Text(
              isAccept ? 'قبول' : 'رفض',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
