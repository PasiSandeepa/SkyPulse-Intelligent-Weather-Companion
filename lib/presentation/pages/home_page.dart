import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_state.dart';
import '../bloc/weather_event.dart';
import '../../common/widgets/forecast_chart.dart';
import '../../common/widgets/weather_animation.dart';
import '../../common/widgets/glow_card.dart';
import '../../common/widgets/animated_temperature.dart';
import '../../common/widgets/particle_background.dart';
import '../../data/local/favorite_service.dart';
import '../../core/ai/ai_service.dart';
import '../widgets/voice_assistant_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FavoriteService _favoriteService = FavoriteService();
  final AIService _aiService = AIService();
  String _aiInsight = '';
  bool _isLoadingAI = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _favoriteService.init();
  }

  Future<void> _loadAIInsight(weather) async {
    setState(() => _isLoadingAI = true);
    final insight = await _aiService.getWeatherInsight(
      cityName: weather.cityName,
      temp: weather.temp,
      humidity: weather.humidity,
      condition: weather.condition,
      aqi: weather.aqi,
      uvIndex: weather.uvIndex,
    );
    setState(() {
      _aiInsight = insight;
      _isLoadingAI = false;
    });
  }

  String _formatTime(int timestamp) {
    if (timestamp == 0) return '--:--';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        body: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state is WeatherLoaded) {
              _loadAIInsight(state.weather);
            }
          },
          builder: (context, state) {
            if (state is WeatherLoading) return _buildLoadingScreen();
            if (state is WeatherError) return _buildErrorScreen(state.message);
            if (state is WeatherLoaded) {
              final weather = state.weather;
              final List<double> temps = state.forecast.isNotEmpty
                  ? state.forecast
                  : [28, 29, 27, 30, 28];
              final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

              return ParticleBackground(
                color: _getGradientColors(weather.condition)[0],
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<WeatherBloc>().add(FetchCurrentLocationWeather());
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 320,
                        floating: true,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _getGradientColors(weather.condition),
                              ),
                            ),
                            child: SafeArea(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WeatherAnimation(
                                    weatherCondition: weather.condition,
                                    height: 100,
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedTemperature(
                                    temperature: weather.temp,
                                    fontSize: 56,
                                  ),
                                  Text(
                                    weather.description.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white60,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        weather.cityName,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _favoriteService.isFavorite(weather.cityName)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          if (_favoriteService.isFavorite(weather.cityName)) {
                                            _favoriteService.removeFavorite(weather.cityName);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Removed from favorites')),
                                            );
                                          } else {
                                            _favoriteService.addFavorite(weather.cityName);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Added to favorites')),
                                            );
                                          }
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.my_location, color: Colors.white),
                            onPressed: () => context.read<WeatherBloc>().add(FetchCurrentLocationWeather()),
                            tooltip: 'Current Location',
                          ),
                          IconButton(
                            icon: Icon(
                              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: Colors.white,
                            ),
                            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                            tooltip: 'Toggle Theme',
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic, color: Colors.white),
                            onPressed: () => showVoiceAssistant(context, weather),
                            tooltip: 'Voice Assistant',
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              Share.share(
                                '🌤️ SkyPulse Weather\n'
                                '📍 ${weather.cityName}\n'
                                '🌡️ ${weather.temp.toStringAsFixed(1)}°C\n'
                                '💧 Humidity: ${weather.humidity}%\n'
                                '🌬️ Wind: ${weather.windSpeed} km/h\n'
                                '📅 ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                              );
                            },
                          ),
                        ],
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ✅ Search Bar + GPS Button
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _searchController,
                                        style: TextStyle(
                                          color: _isDarkMode ? Colors.white : Colors.black,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '🔍 Search city...',
                                          hintStyle: TextStyle(
                                            color: _isDarkMode ? Colors.white54 : Colors.grey.shade400,
                                          ),
                                          prefixIcon: const Icon(Icons.search, color: Colors.blue),
                                          suffixIcon: _searchController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(() {});
                                                  },
                                                )
                                              : null,
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 15,
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          if (value.isNotEmpty) {
                                            context.read<WeatherBloc>().add(FetchWeatherByCity(value));
                                            _searchController.clear();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => context.read<WeatherBloc>().add(FetchCurrentLocationWeather()),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade400,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.my_location, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ✅ Glow Cards — dark mode support
                              Row(
                                children: [
                                  Expanded(
                                    child: GlowCard(
                                      title: 'HUMIDITY',
                                      value: '${weather.humidity}%',
                                      icon: Icons.water_drop,
                                      color: Colors.blue,
                                      isDark: _isDarkMode,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GlowCard(
                                      title: 'WIND',
                                      value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                                      icon: Icons.air,
                                      color: Colors.green,
                                      isDark: _isDarkMode,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GlowCard(
                                      title: 'FEELS LIKE',
                                      value: '${weather.feelsLike.toStringAsFixed(1)}°C',
                                      icon: Icons.thermostat,
                                      color: Colors.orange,
                                      isDark: _isDarkMode,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GlowCard(
                                      title: 'VISIBILITY',
                                      value: '${weather.visibility.toStringAsFixed(1)} km',
                                      icon: Icons.visibility,
                                      color: Colors.teal,
                                      isDark: _isDarkMode,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ✅ Sunrise / Sunset Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange.shade300, Colors.pink.shade200],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        const Icon(Icons.wb_twilight, color: Colors.white, size: 32),
                                        const SizedBox(height: 8),
                                        const Text('Sunrise', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text(
                                          _formatTime(weather.sunrise),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(height: 50, width: 1, color: Colors.white30),
                                    Column(
                                      children: [
                                        const Icon(Icons.nights_stay, color: Colors.white, size: 32),
                                        const SizedBox(height: 8),
                                        const Text('Sunset', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text(
                                          _formatTime(weather.sunset),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(height: 50, width: 1, color: Colors.white30),
                                    Column(
                                      children: [
                                        const Icon(Icons.show_chart, color: Colors.white, size: 32),
                                        const SizedBox(height: 8),
                                        const Text('Min/Max', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        Text(
                                          '${weather.tempMin.toStringAsFixed(0)}°/${weather.tempMax.toStringAsFixed(0)}°',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ✅ AI Insight Card — dark mode support
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isDarkMode
                                        ? [Colors.purple.shade900, Colors.blue.shade900]
                                        : [Colors.purple.shade50, Colors.blue.shade50],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.auto_awesome, color: Colors.purple.shade700),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '🤖 AI Weather Insight',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (_isLoadingAI)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20),
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      else
                                        Text(
                                          _aiInsight.isEmpty ? 'Loading AI insights...' : _aiInsight,
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                            color: _isDarkMode ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 5-Day Forecast Chart
                              ForecastChart(
                                temperatures: temps,
                                days: days,
                              ),

                              const SizedBox(height: 20),

                              // AI Voice Assistant Button
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => showVoiceAssistant(context, weather),
                                  icon: const Icon(Icons.mic),
                                  label: const Text('Ask AI Weather Assistant'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return _buildInitialScreen();
          },
        ),
      ),
    );
  }

  List<Color> _getGradientColors(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) {
      return [Colors.blueGrey.shade800, Colors.blueGrey.shade500];
    } else if (c.contains('cloud')) {
      return [Colors.grey.shade700, Colors.grey.shade500];
    } else if (c.contains('snow')) {
      return [Colors.lightBlue.shade400, Colors.lightBlue.shade200];
    } else if (c.contains('thunder')) {
      return [Colors.deepPurple.shade900, Colors.indigo.shade700];
    } else if (c.contains('clear') || c.contains('sunny')) {
      return [Colors.blue.shade600, Colors.orange.shade400];
    }
    return [Colors.blue.shade600, Colors.purple.shade400];
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.purple.shade300],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/loading.json',
              height: 150,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                return const CircularProgressIndicator(color: Colors.white);
              },
            ),
            const SizedBox(height: 20),
            const Text('🌤️ SkyPulse',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Loading weather...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade400, Colors.orange.shade300],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text('Error', style: TextStyle(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.read<WeatherBloc>().add(FetchCurrentLocationWeather()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.purple.shade300],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/sun.json',
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.wb_sunny, size: 150, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('SkyPulse',
                  style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Your Smart Weather Companion', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.read<WeatherBloc>().add(FetchCurrentLocationWeather()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('🌍 Get Weather'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}