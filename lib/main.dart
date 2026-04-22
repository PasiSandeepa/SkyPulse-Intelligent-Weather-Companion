import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';  // ✅ මෙය add කරන්න
import 'core/api/weather_api.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/usecases/get_weather_usecase.dart';
import 'presentation/bloc/weather_bloc.dart';
import 'presentation/bloc/weather_event.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Load .env file
  await dotenv.load(fileName: ".env");
  
  // ✅ Initialize Hive
  await Hive.initFlutter();
  
  // ✅ Open required boxes (ඔයාගේ box names දාන්න)
  await Hive.openBox('settings');   // settings box එක
  await Hive.openBox('cache');       // cache box එක
  await Hive.openBox('weather_cache'); // weather cache box එක (තියෙනවා නම්)
  
  runApp(const SkyPulseApp());
}

class SkyPulseApp extends StatelessWidget {
  const SkyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherApi = WeatherApi();
    final weatherRepository = WeatherRepositoryImpl(weatherApi);
    final getWeatherUseCase = GetWeatherUseCase(weatherRepository);
    final getForecastUseCase = GetForecastUseCase(weatherRepository);

    return BlocProvider(
      create: (context) => WeatherBloc(
        getWeatherUseCase: getWeatherUseCase,
        getForecastUseCase: getForecastUseCase,
      )..add(FetchCurrentLocationWeather()),
      child: MaterialApp(
        title: 'SkyPulse - AI Weather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}

// ... SplashScreen එක එහෙමම තියෙන්න ...

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.purple.shade400],
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