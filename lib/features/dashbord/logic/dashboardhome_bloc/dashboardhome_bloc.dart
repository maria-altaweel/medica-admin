import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medica_admin/features/dashbord/data/repos/dashboard_repo.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_event.dart';
import 'package:medica_admin/features/dashbord/logic/dashboardhome_bloc/dashboardhome_state.dart';

class DashboardHomeBloc extends Bloc<DashboardHomeEvent, DashboardHomeState> {
  final DashboardHomeRepo _repo;

  DashboardHomeBloc(this._repo) : super(DashboardHomeInitial()) {
    on<FetchDashboardHomeData>(_onFetchData);
  }

  Future<void> _onFetchData(
    FetchDashboardHomeData event,
    Emitter<DashboardHomeState> emit,
  ) async {
    emit(DashboardHomeLoading());
    try {
      final data = await _repo.getDashboardHomeData();
      emit(DashboardHomeSuccess(data));
    } catch (e) {
      emit(DashboardHomeError(e.toString()));
    }
  }
}
