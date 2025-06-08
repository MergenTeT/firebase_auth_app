import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../role_selection/view/role_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Gap(40),
                    // Logo veya İkon
                    Icon(
                      Icons.agriculture,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Gap(24),
                    // Başlık
                    Text(
                      _isLogin ? 'Hoş Geldiniz!' : 'Hesap Oluştur',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    // Alt başlık
                    Text(
                      _isLogin
                          ? 'Tarım pazarına giriş yapın'
                          : 'Yeni bir hesap oluşturun',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(32),
                    // Form alanları
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Ad Soyad',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adınızı ve soyadınızı girin';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen email adresinizi girin';
                        }
                        if (!value.contains('@')) {
                          return 'Geçerli bir email adresi girin';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi girin';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                    const Gap(32),
                    // Giriş/Kayıt butonu
                    if (viewModel.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final success = _isLogin
                                ? await viewModel.signIn(
                                    _emailController.text,
                                    _passwordController.text,
                                  )
                                : await viewModel.signUp(
                                    _emailController.text,
                                    _passwordController.text,
                                  );

                            if (success && mounted) {
                              if (_isLogin) {
                                // TODO: Ana sayfaya yönlendir
                              } else {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => RoleView(
                                      email: _emailController.text,
                                      fullName: _fullNameController.text,
                                      userId: viewModel.currentUser?.uid ?? '',
                                    ),
                                  ),
                                );
                              }
                            } else if (viewModel.errorMessage != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewModel.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                      ),
                    const Gap(16),
                    // Giriş/Kayıt geçiş butonu
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Hesabınız yok mu? Kayıt olun'
                            : 'Zaten hesabınız var mı? Giriş yapın',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }
}
