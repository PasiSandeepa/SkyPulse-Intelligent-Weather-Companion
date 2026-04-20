import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// TODO: Import your screens and blocs later
// import 'presentation/screens/splash_screen.dart';
// import 'presentation/screens/home_screen.dart';
// import 'presentation/bloc/weather/weather_bloc.dart';
// import 'core/services/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize dependencies
  await initDependencies();
  
  runApp(const SkyPulseApp());
}

// Dependency Injection setup
Future<void> initDependencies() async {
  final getIt = GetIt.instance;
  
  // TODO: Register services
  // getIt.registerSingleton<WeatherService>(WeatherService());
  // getIt.registerFactory<WeatherBloc>(() => WeatherBloc());
}

class SkyPulseApp extends StatelessWidget {
  const SkyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyPulse - AI Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        fontFamily: 'Poppins', // Add custom font if you have
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(), // Start with splash screen
      // home: const HomeScreen(), // Or directly home screen
    );
  }
}

// Simple Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Weather Icon
              Icon(
                Icons.cloud_circle,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              
              // App Name
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
              
              // Tagline
              const Text(
                'AI-Powered Weather Assistant',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 50),
              
              // Loading indicator
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

// Simple Home Screen (Temporary)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock weather data
  String _temperature = "24°C";
  String _condition = "Sunny";
  String _location = "Colombo, Sri Lanka";
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location and settings
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white70, size: 18),
                            const SizedBox(width: 5),
                            Text(
                              _location,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Today",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Weather Animation Placeholder
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          size: 80,
                          color: Colors.yellow.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _condition,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Temperature
                Center(
                  child: Text(
                    _temperature,
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Weather Details Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Humidity
                      Column(
                        children: [
                          Icon(Icons.water_drop, color: Colors.white, size: 30),
                          const SizedBox(height: 5),
                          Text(
                            "85%",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            "Humidity",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      
                      // Wind
                      Column(
                        children: [
                          Icon(Icons.air, color: Colors.white, size: 30),
                          const SizedBox(height: 5),
                          Text(
                            "12 km/h",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            "Wind",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      
                      // UV Index
                      Column(
                        children: [
                          Icon(Icons.sunny, color: Colors.white, size: 30),
                          const SizedBox(height: 5),
                          Text(
                            "5",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            "UV Index",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 5-Day Forecast
                Text(
                  "5-Day Forecast",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _buildForecastItem("Mon", "☀️", "28°", "22°"),
                      _buildForecastItem("Tue", "⛅", "27°", "21°"),
                      _buildForecastItem("Wed", "🌧️", "25°", "20°"),
                      _buildForecastItem("Thu", "☁️", "26°", "21°"),
                      _buildForecastItem("Fri", "☀️", "29°", "23°"),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // AI Assistant Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAIAssistantDialog(context);
                    },
                    icon: Icon(Icons.mic),
                    label: Text("Ask AI Weather Assistant"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildForecastItem(String day, String icon, String high, String low) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 50,
            child: Text(day, style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Text(icon, style: TextStyle(fontSize: 24)),
          Text(
            high,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(low, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
  
  void _showAIAssistantDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 10),
            Text("AI Weather Assistant"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("How can I help you today?"),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement speech to text
                Navigator.pop(context);
              },
              icon: Icon(Icons.mic),
              label: Text("Speak Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}