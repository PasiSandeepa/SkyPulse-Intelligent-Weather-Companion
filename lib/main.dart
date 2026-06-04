import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/api/weather_api.dart';
import 'core/services/ip_location_service.dart';
import 'core/services/notification_service.dart'; // ✅ Add
import 'data/repositories/weather_repository_impl.dart';
import 'domain/usecases/get_weather_usecase.dart';
import 'domain/usecases/get_forecast_usecase.dart';
import 'presentation/bloc/weather_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');
  await Hive.openBox('weather_cache');

  // ✅ Notification service init
  await NotificationService().init();

  runApp(const SkyPulseApp());
}

class SkyPulseApp extends StatelessWidget {
  const SkyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherApi = WeatherApi();
    final ipLocationService = IpLocationService();
    final weatherRepository = WeatherRepositoryImpl(weatherApi);
    final getWeatherUseCase = GetWeatherUseCase(weatherRepository);
    final getForecastUseCase = GetForecastUseCase(weatherRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => WeatherBloc(
            getWeatherUseCase: getWeatherUseCase,
            getForecastUseCase: getForecastUseCase,
            ipLocationService: ipLocationService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SkyPulse - AI Weather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              return const HomePage();
            }
            if (state.status == AuthStatus.initial ||
                state.status == AuthStatus.loading) {
              return const SplashScreen();
            }
            return const LoginPage();
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, const Color.fromARGB(255, 155, 64, 171)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_circle, size: 120, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'SkyPulse',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'AI-Powered Weather Assistant',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}