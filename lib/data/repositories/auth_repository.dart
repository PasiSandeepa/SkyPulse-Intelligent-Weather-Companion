import '../datasources/auth_local_datasource.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final AuthLocalDataSource _dataSource = AuthLocalDataSource();

  Future<bool> register(String name, String email, String password) async {
    final users = await _dataSource.getUsers();
    if (users.containsKey(email)) return false;
    await _dataSource.saveUser(email, password, name);
    return true;
  }

  Future<bool> login(String email, String password) async {
    final isValid = await _dataSource.getUser(email, password);
    if (isValid) {
      await _dataSource.setLoggedIn(true);
      final users = await _dataSource.getUsers();
      final name = users[email]['name'];
      await _dataSource.saveCurrentUser(email, name);
    }
    return isValid;
  }

  Future<bool> isLoggedIn() async {
    return await _dataSource.isLoggedIn();
  }

  Future<UserEntity?> getCurrentUser() async {
    final userData = await _dataSource.getCurrentUser();
    if (userData == null) return null;
    return UserEntity(
      name: userData['name']!,
      email: userData['email']!,
    );
  }

  Future<void> logout() async {
    await _dataSource.logout();
  }
}