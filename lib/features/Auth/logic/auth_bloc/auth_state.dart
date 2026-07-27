part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class LoginLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final AdminModel adminModel;
  LoginSuccess({required this.adminModel});
}

class LoginError extends AuthState {
  final String message;
  LoginError({required this.message});
}
