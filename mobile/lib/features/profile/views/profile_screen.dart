import 'package:flutter/material.dart';

import 'package:mobile/features/profile/viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.profileViewModel});

  final ProfileViewModel profileViewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: profileViewModel,
      builder: (context, _) {
        if (profileViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profileViewModel.errorMessage != null) {
          return Center(child: Text(profileViewModel.errorMessage!));
        }

        final user = profileViewModel.user;
        final username = user?.username ?? '';
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Perfil', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 36,
              child: Text(username.isEmpty ? '?' : username[0].toUpperCase()),
            ),
            const SizedBox(height: 16),
            Text(username.isEmpty ? 'Sem perfil carregado' : username),
            Text(user?.email ?? ''),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await profileViewModel.loadProfile();
              },
              child: const Text('Atualizar perfil'),
            ),
          ],
        );
      },
    );
  }
}