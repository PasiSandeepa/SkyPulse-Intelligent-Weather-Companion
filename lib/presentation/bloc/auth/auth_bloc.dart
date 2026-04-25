import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/entities/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(AuthState.initial()) {
    on<RegisterRequested>(_onRegister);
    on<LoginRequested>(_onLogin);
    on<CheckAuthStatus>(_onCheckAuth);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final success = await _authRepository.register(event.name, event.email, event.password);
    if (success) {
      await _authRepository.login(event.email, event.password);
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'User already exists'));
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final success = await _authRepository.login(event.email, event.password);
    if (success) {
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'Invalid email or password'));
    }
  }

  Future<void> _onCheckAuth(CheckAuthStatus event, Emitter<AuthState> emit) async {
    print('🔍 Checking auth status...');  // ✅ Debug print
    emit(state.copyWith(status: AuthStatus.loading));  // ✅ Add this line!
    
    final isLoggedIn = await _authRepository.isLoggedIn();
    print('📱 Is logged in: $isLoggedIn');  // ✅ Debug print
    
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      print('👤 User: ${user?.name}');  // ✅ Debug print
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      print('🚫 Not logged in - showing LoginPage');  // ✅ Debug print
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }
}