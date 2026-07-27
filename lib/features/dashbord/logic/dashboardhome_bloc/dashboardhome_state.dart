import 'package:medica_admin/features/dashbord/data/models/dashboard_model.dart';

abstract class DashboardHomeState {}

class DashboardHomeInitial extends DashboardHomeState {}

class DashboardHomeLoading extends DashboardHomeState {}

class DashboardHomeSuccess extends DashboardHomeState {
  final DashboardHomeResponse response;
  DashboardHomeSuccess(this.response);
}

class DashboardHomeError extends DashboardHomeState {
  final String message;
  DashboardHomeError(this.message);
}
