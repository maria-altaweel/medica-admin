import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/App_Colors.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/ads/UI/widgets/ads_header.dart';
import 'package:medica_admin/features/ads/UI/widgets/ads_tabele.dart';
import 'package:medica_admin/features/ads/logic/ad_cubit/ad_cubit.dart';
import 'package:medica_admin/features/ads/logic/ad_cubit/ad_state.dart';
import 'package:medica_admin/features/ads/ui/widgets/add_edit_ad_dialog.dart';
import 'package:medica_admin/features/ads/ui/widgets/delete_ad_dialog.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  ClinicModel? selectedClinic;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // استخدام الإيفنت الصحيح لجلب العيادات
    context.read<ClinicsBloc>().add(FetchClinicsEvent());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (selectedClinic != null) {
        context.read<AdCubit>().getAds(clinicId: selectedClinic!.id);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocListener<ClinicsBloc, ClinicsState>(
        listener: (context, state) {
          // التحديث التلقائي عند نجاح جلب العيادات
          if (state is ClinicsSuccessState &&
              state.clinics.isNotEmpty &&
              selectedClinic == null) {
            setState(() {
              selectedClinic = state.clinics.first;
            });
            context.read<AdCubit>().getAds(
              clinicId: selectedClinic!.id,
              isRefresh: true,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildAdsTableSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AdsHeader(
      title: 'الإعلانات',
      selectedClinicName: selectedClinic?.name ?? 'اختر العيادة',
      onChangeClinicTap: () {
        context.read<ClinicsBloc>().add(FetchClinicsEvent());
        _showClinicDialog(context);
      },
      onAddAdTap: selectedClinic == null
          ? () {}
          : () async {
              final result = await showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<AdCubit>(),
                  child: AddEditAdDialog(
                    clinicId: selectedClinic!.id,
                    clinicName: selectedClinic!.name,
                  ),
                ),
              );

              if (result == true && context.mounted) {
                context.read<AdCubit>().getAds(
                  clinicId: selectedClinic!.id,
                  isRefresh: true,
                );
              }
            },
    );
  }

  void _showClinicDialog(BuildContext context) {
    context.read<ClinicsBloc>().add(FetchClinicsEvent());

    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ClinicsBloc>(),
        child: SelectClinicDialog(
          selectedClinic: selectedClinic,
          onClinicSelected: (clinic) {
            setState(() {
              selectedClinic = clinic;
            });
            context.read<AdCubit>().getAds(
              clinicId: clinic.id,
              isRefresh: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdsTableSection(BuildContext context) {
    return Expanded(
      child: BlocConsumer<AdCubit, AdState>(
        listener: (context, state) {
          if (state is DeleteAdSuccess) {
            Appsnackbar.showSuccess(context, 'تمت العملية بنجاح');
            if (selectedClinic != null) {
              context.read<AdCubit>().getAds(
                clinicId: selectedClinic!.id,
                isRefresh: true,
              );
            }
          }

          if (state is ToggleAdStatusError) {
            debugPrint('Toggle Error: ${state.error}');
            Appsnackbar.showError(context, state.error);
          }

          if (state is DeleteAdError) {
            debugPrint('Delete Error: ${state.error}');
            Appsnackbar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          // 1. حالة التحميل
          if (state is GetAdsLoading) {
            return AppLoadingIndicator();
          }

          // 2. عدم اختيار عيادة
          if (selectedClinic == null) {
            return const Center(
              child: Text(
                "يرجى اختيار عيادة لعرض الإعلانات",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          // 3. هندلة حالة الخطأ
          if (state is GetAdsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'حدث خطأ في الاتصال بالخادم\nيرجى التحقق من اتصالك بالإنترنت.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // إعادة جلب البيانات
                      context.read<AdCubit>().getAds(
                        clinicId: selectedClinic!.id,
                        isRefresh: true,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. حالة النجاح
          return AdsTable(
            adsList: context.read<AdCubit>().adsList,

            onEdit: (ad) async {
              // 👈 التعديل الخامس: ضفنا async هون متل زر الإضافة
              final result = await showDialog(
                // 👈 انتظار النتيجة
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<AdCubit>(),
                  child: AddEditAdDialog(
                    clinicId: selectedClinic!.id,
                    clinicName: selectedClinic!.name,
                    ad: ad,
                  ),
                ),
              );

              // 👈 التعديل السادس: تحديث إذا قفل بنجاح ورجع true
              if (result == true && context.mounted) {
                context.read<AdCubit>().getAds(
                  clinicId: selectedClinic!.id,
                  isRefresh: true,
                );
              }
            },
            onDelete: (id) => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: context.read<AdCubit>(),
                child: DeleteAdDialog(adId: id),
              ),
            ),
            onToggleStatus: (id) => context.read<AdCubit>().toggleAdStatus(id),
          );
        },
      ),
    );
  }
}
