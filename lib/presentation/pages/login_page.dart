import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.purple.shade400],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud, size: 80, color: Colors.blue),
                          const SizedBox(height: 16),
                          const Text('SkyPulse', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const Text('Sign in to continue', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              labelText: 'Email',
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Email required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Password required' : null,
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state.status == AuthStatus.loading ? null : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      LoginRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: state.status == AuthStatus.loading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Login', style: TextStyle(fontSize: 16)),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                                  );
                                },
                                child: const Text('Register'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}