import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skypulse/presentation/pages/login_page.dart';
import '../bloc/auth/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const ProfilePage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isDarkMode
                      ? [Colors.grey.shade900, Colors.blueGrey.shade900]
                      : [Colors.blue.shade600, Colors.purple.shade400],
                ),
              ),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                          ),
                          padding: const EdgeInsets.all(20),
                          child:
                              const Icon(Icons.person, size: 60, color: Colors.blue),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? 'email@example.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isDarkMode ? Colors.white60 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(
                            color: _isDarkMode
                                ? Colors.white24
                                : Colors.grey.shade300),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Icon(Icons.cloud,
                              color: _isDarkMode ? Colors.white70 : null),
                          title: Text('Weather Preferences',
                              style: TextStyle(
                                  color:
                                      _isDarkMode ? Colors.white : Colors.black)),
                          trailing: Icon(Icons.chevron_right,
                              color: _isDarkMode ? Colors.white54 : null),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: Icon(Icons.notifications,
                              color: _isDarkMode ? Colors.white70 : null),
                          title: Text('Notifications',
                              style: TextStyle(
                                  color:
                                      _isDarkMode ? Colors.white : Colors.black)),
                          trailing: Icon(Icons.chevron_right,
                              color: _isDarkMode ? Colors.white54 : null),
                          onTap: () {},
                        ),
                        // ✅ FIXED — dark mode switch properly connected
                        ListTile(
                          leading: Icon(
                            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: _isDarkMode ? Colors.white70 : null,
                          ),
                          title: Text(
                            'Dark Mode',
                            style: TextStyle(
                                color:
                                    _isDarkMode ? Colors.white : Colors.black),
                          ),
                          trailing: Switch(
                            value: _isDarkMode,
                            activeColor: Colors.purple,
                            onChanged: (value) {
                              setState(() => _isDarkMode = value);
                              widget.onDarkModeChanged(value); // ← home_page ලට notify
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}