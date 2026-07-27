part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String phone;
  final String password;

  LoginEvent({required this.phone, required this.password});
}
