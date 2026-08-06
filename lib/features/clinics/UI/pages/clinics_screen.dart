import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/core/helpers/AppsnackBar.dart';
import 'package:medica_admin/core/helpers/app_colors.dart';
import 'package:medica_admin/core/widgets/App_Loadingindicator.dart';
import 'package:medica_admin/features/clinics/UI/widgets/delete_clinic_dialog.dart';

import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_bloc.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_event.dart';
import 'package:medica_admin/features/clinics/logic/clinic_bloc/clinic_state.dart';
import 'package:medica_admin/features/dashbord/UI/pages/admin_layout.dart';

import '../../data/models/clinic_model.dart';

import '../widgets/add_edit_clinic_dialog.dart';
import '../widgets/clinics_data_table.dart';
import '../widgets/clinics_header.dart';
import '../widgets/clinics_search_bar.dart';
import 'clinic_details_screen.dart';

class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ClinicModel> _allClinics = [];
  List<ClinicModel> _filteredClinics = [];

  @override
  void initState() {
    super.initState();
    _fetchClinics();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchClinics() {
    context.read<ClinicsBloc>().add(FetchClinicsEvent());
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredClinics = _allClinics.where((clinic) {
        return clinic.name.toLowerCase().contains(query) ||
            clinic.address.toLowerCase().contains(query) ||
            clinic.phone.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClinicsHeader(
              onRefresh: _fetchClinics,
              onAddClinic: () => _openAddEditDialog(),
            ),
            const SizedBox(height: 24),
            ClinicsSearchBar(controller: _searchController),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<ClinicsBloc, ClinicsState>(
                listener: (context, state) {
                  if (state is ClinicActionSuccessState) {
                    Appsnackbar.showSuccess(context, state.message);
                  } else if (state is ClinicsErrorState) {
                    Appsnackbar.showError(context, state.errorMessage);
                  }
                },
                builder: (context, state) {
                  if (state is ClinicsLoadingState) {
                    return const Center(child: AppLoadingIndicator());
                  } else if (state is ClinicsSuccessState) {
                    _allClinics = state.clinics;
                    _filteredClinics = _searchController.text.isEmpty
                        ? _allClinics
                        : _filteredClinics;

                    return ClinicsDataTable(
                      clinics: _filteredClinics,
                      onView: _navigateToDetails,
                      onEdit: (clinic) => _openAddEditDialog(clinic: clinic),
                      onDelete: _openDeleteDialog,
                    );
                  }
                  return ClinicsDataTable(
                    clinics: _filteredClinics,
                    onView: _navigateToDetails,
                    onEdit: (clinic) => _openAddEditDialog(clinic: clinic),
                    onDelete: _openDeleteDialog,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(ClinicModel clinic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminLayout(
          initialIndex: 1,
          body: BlocProvider.value(
            value: context.read<ClinicsBloc>(),
            child: ClinicDetailsScreen(clinicId: clinic.id),
          ),
        ),
      ),
    );
  }

  void _openAddEditDialog({ClinicModel? clinic}) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ClinicsBloc>(),
        child: AddEditClinicDialog(clinic: clinic),
      ),
    );
  }

  void _openDeleteDialog(ClinicModel clinic) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ClinicsBloc>(),
        child: DeleteClinicDialog(clinic: clinic),
      ),
    );
  }
}
