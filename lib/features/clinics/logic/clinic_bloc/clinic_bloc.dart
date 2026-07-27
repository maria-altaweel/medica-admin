import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/features/clinics/data/repos/clinic_details_repo.dart';
import 'clinic_details_event.dart';
import 'clinic_details_state.dart';

class ClinicDetailsBloc extends Bloc<ClinicDetailsEvent, ClinicDetailsState> {
  final ClinicDetailsRepository _repository;

  ClinicDetailsBloc(this._repository) : super(ClinicDetailsInitial()) {
    on<GetClinicDetailsEvent>(_onGetClinicDetails);
  }

  Future<void> _onGetClinicDetails(
    GetClinicDetailsEvent event,
    Emitter<ClinicDetailsState> emit,
  ) async {
    emit(ClinicDetailsLoading());
    try {
      final response = await _repository.getClinicDetails(event.clinicId);

      emit(ClinicDetailsSuccess(response));
    } catch (e) {
      emit(ClinicDetailsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
