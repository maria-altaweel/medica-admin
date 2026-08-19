import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/networking/service_locator.dart';
import 'package:medica_admin/features/clinics/data/models/clinic_model.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/doctors/ui/widgets/select_clinic_dialog.dart';
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_cubit.dart';
import 'package:medica_admin/features/articles/logic/articles_cubit/articles_state.dart';

class ArticlesFilterBar extends StatefulWidget {
  const ArticlesFilterBar({super.key});

  @override
  State<ArticlesFilterBar> createState() => _ArticlesFilterBarState();
}

class _ArticlesFilterBarState extends State<ArticlesFilterBar> {
  int? selectedCategoryId;
  int? selectedClinicId;
  String? selectedStatus;
  String searchQuery = '';
  String? selectedDate;
  ClinicModel? currentClinicObj;

  void _openSelectClinicDialog(
    BuildContext parentContext,
    List<ClinicModel> clinics,
  ) {
    if (selectedClinicId != null && clinics.isNotEmpty) {
      try {
        currentClinicObj = clinics.firstWhere((c) => c.id == selectedClinicId);
      } catch (_) {
        currentClinicObj = clinics.first;
      }
    } else if (clinics.isNotEmpty) {
      currentClinicObj = clinics.first;
    }

    showDialog(
      context: parentContext,
      builder: (_) => BlocProvider(
        create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
        child: SelectClinicDialog(
          clinics: clinics,
          selectedClinic: currentClinicObj,
          onClinicSelected: (clinic) {
            setState(() {
              selectedClinicId = clinic.id;
              currentClinicObj = clinic;
            });
            _triggerFilter();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ClinicsBloc>()..add(FetchClinicsEvent()),
      child: BlocBuilder<ClinicsBloc, ClinicsState>(
        builder: (context, clinicState) {
          List<ClinicModel> clinics = [];
          if (clinicState is ClinicsSuccessState) {
            clinics = clinicState.clinics;
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Builder(
                builder: (innerContext) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. بحث بعنوان المقال
                      SizedBox(
                        width: 210,
                        child: TextField(
                          onChanged: (query) {
                            searchQuery = query;
                            _triggerFilter();
                          },
                          decoration: InputDecoration(
                            labelText: "بحث",
                            hintText: "بحث بعنوان المقال...",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 18,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 2. العيادة (باستخدام الديالوج)
                      SizedBox(
                        width: 150,
                        child: InkWell(
                          onTap: () =>
                              _openSelectClinicDialog(innerContext, clinics),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "العيادة",
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    currentClinicObj?.name ?? "الكل",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: currentClinicObj == null
                                          ? Colors.black87
                                          : Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 3. الحالة
                      SizedBox(
                        width: 130,
                        child: DropdownButtonFormField<String?>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: "الحالة",
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                          ),
                          hint: const Text(
                            "الكل",
                            style: TextStyle(fontSize: 13),
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                "الكل",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'published',
                              child: Text(
                                "منشور",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'draft',
                              child: Text(
                                "مسودة",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            DropdownMenuItem<String?>(
                              value: 'archived',
                              child: Text(
                                "مؤرشف",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() => selectedStatus = val);
                            _triggerFilter();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 4. الفئة
                      SizedBox(
                        width: 140,
                        child: BlocBuilder<ArticlesCubit, ArticlesState>(
                          builder: (context, state) {
                            final cubit = context.read<ArticlesCubit>();
                            return DropdownButtonFormField<int?>(
                              value: selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: "الفئة",
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.borderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: AppColors.borderColor,
                                  ),
                                ),
                              ),
                              hint: const Text(
                                "الكل",
                                style: TextStyle(fontSize: 13),
                              ),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text(
                                    "الكل",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                                ...cubit.categoriesList.map((category) {
                                  return DropdownMenuItem<int?>(
                                    value: category.id,
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() => selectedCategoryId = val);
                                _triggerFilter();
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 5. من تاريخ
                      SizedBox(
                        width: 150,
                        child: InkWell(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked.toString().split(' ')[0];
                              });
                              _triggerFilter();
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "من تاريخ",
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.borderColor,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate ?? "اختر تاريخ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: selectedDate == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _triggerFilter() {
    context.read<ArticlesCubit>().getArticles(
      isRefresh: true,
      search: searchQuery.isEmpty ? null : searchQuery,
      categoryId: selectedCategoryId,
      clinicId: selectedClinicId,
      status: selectedStatus,
    );
  }
}
