import 'package:flutter/material.dart';
import 'company_profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            context,
            icon: Icons.business,
            title: 'Company Profile',
            subtitle: 'Manage company details, GST, PAN, and Logos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanyProfileScreen()),
              );
            },
          ),
          const Divider(),
          _buildMenuTile(
            context,
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'GPI Fleet',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset('assets/image/gpi_logo.png', height: 50),
                children: [
                  const Text('A comprehensive Fleet Expense Management system.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
