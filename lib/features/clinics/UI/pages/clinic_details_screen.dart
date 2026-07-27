import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/UI/widgets/clinic_header_card.dart';
import 'package:medica_admin/features/clinics/UI/widgets/clinic_stat_card.dart';
import 'package:medica_admin/features/clinics/UI/widgets/specialization_table_widget.dart';
import 'package:medica_admin/features/clinics/logic/clinic_details_bloc/clinic_details_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_details_bloc/clinic_details_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_details_bloc/clinic_details_state.dart';

class ClinicDetailsScreen extends StatelessWidget {
  final int clinicId;

  const ClinicDetailsScreen({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ClinicDetailsBloc>()..add(GetClinicDetailsEvent(clinicId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocBuilder<ClinicDetailsBloc, ClinicDetailsState>(
          builder: (context, state) {
            if (state is ClinicDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClinicDetailsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (state is ClinicDetailsSuccess) {
              final data = state.clinicDetails.data;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الهيدر المنفصل
                    ClinicHeaderCard(clinicData: data),

                    const SizedBox(height: 24),

                    // 2. الكروت الإحصائية المنفصلة
                    Row(
                      children: [
                        Expanded(
                          child: ClinicStatCard(
                            title: 'عدد الأطباء',
                            value: '${data.doctorsCount}',
                            icon: Icons.medical_services_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ClinicStatCard(
                            title: 'متوسط التقييم',
                            value: '${data.averageRating}',
                            icon: Icons.star_outline_rounded,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ClinicStatCard(
                            title: 'عدد التخصصات',
                            value: '${data.specializations.length}',
                            icon: Icons.category_outlined,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 3. جدول التخصصات المنفصل
                    SpecializationsTableWidget(
                      specializations: data.specializations,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
