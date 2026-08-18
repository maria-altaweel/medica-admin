part of 'leave_cubit.dart';

abstract class LeaveState {}

class LeaveInitial extends LeaveState {}

class LeavesLoading extends LeaveState {}

class LeavesLoaded extends LeaveState {
  final List<LeaveModel> leaves;
  LeavesLoaded(this.leaves);
}

class LeaveDetailsLoaded extends LeaveState {
  final LeaveModel leave;
  LeaveDetailsLoaded(this.leave);
}

class LeaveActionLoading extends LeaveState {}

class LeaveActionSuccess extends LeaveState {
  final String message;
  LeaveActionSuccess(this.message);
}

class LeaveError extends LeaveState {
  final String error;
  LeaveError(this.error);
}
