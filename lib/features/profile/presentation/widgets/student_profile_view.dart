import 'package:flutter/material.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';
import 'profile_view.dart';

class StudentProfileView extends StatelessWidget {
  final User currentUser;
  final VoidCallback onLogout;

  const StudentProfileView({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ExitusProfileView(
      currentUser: currentUser,
      onLogout: onLogout,
    );
  }
}
