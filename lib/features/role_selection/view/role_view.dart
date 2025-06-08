import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import '../../dashboard/view/dashboard_view.dart';

class RoleView extends StatefulWidget {
  final String email;
  final String fullName;
  final String userId;

  const RoleView({
    super.key,
    required this.email,
    required this.fullName,
    required this.userId,
  });

  @override
  State<RoleView> createState() => _RoleViewState();
}

class _RoleViewState extends State<RoleView> {
  String? selectedRole;
  bool isLoading = false;

  Future<void> saveRole() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir rol seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
        'email': widget.email,
        'fullName': widget.fullName,
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DashboardView(
              userId: widget.userId,
              userRole: selectedRole!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(40),
              Icon(
                Icons.person_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(24),
              Text(
                'Rolünüzü Seçin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Pazaryerine nasıl katılmak istediğinizi seçin',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const Gap(48),
              _buildRoleCard(
                'Çiftçi',
                'Ürünlerinizi satın',
                Icons.agriculture,
                'farmer',
              ),
              const Gap(16),
              _buildRoleCard(
                'Alıcı',
                'Ürün satın alın',
                Icons.store,
                'buyer',
              ),
              const Gap(16),
              _buildRoleCard(
                'Her İkisi',
                'Hem alın hem satın',
                Icons.swap_horiz,
                'both',
              ),
              const Spacer(),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: saveRole,
                  child: const Text('Devam Et'),
                ),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    String title,
    String subtitle,
    IconData icon,
    String role,
  ) {
    final isSelected = selectedRole == role;
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.white,
      child: InkWell(
        onTap: () => setState(() => selectedRole = role),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
