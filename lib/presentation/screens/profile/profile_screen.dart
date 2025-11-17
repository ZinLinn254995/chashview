import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/route_names.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthViewModel authVM = context.read<AuthViewModel>();

  @override
  void initState() {
    super.initState();

    authVM.addListener(_authListener);
  }

  void _authListener() {


    if (!authVM.isLoading && authVM.user == null && mounted) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          RouteNames.login,
              (route) => false,
        );
      });
    }

  }

  @override
  void dispose() {

    authVM.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        return Scaffold(
          body: Center(
            child: authVM.isLoading
                ? const CircularProgressIndicator()
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (authVM.user != null) ...[
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(authVM.user!.photoUrl),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    authVM.user!.displayName,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 5),
                  Text(authVM.user!.email),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {

                    authVM.signOut();
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
