import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_state.dart';
import '../bloc/weather_event.dart';
import '../../common/widgets/weather_card.dart';
import '../../common/widgets/forecast_chart.dart';
import '../../common/widgets/weather_animation.dart';
import '../../data/local/favorite_service.dart';
import '../../core/ai/ai_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state is WeatherLoaded) {
            _loadAIInsight(state.weather);
          }
        },
        builder: (context, state) {
          if (state is WeatherLoading) {
            return _buildLoadingScreen();
          }

          if (state is WeatherError) {
            return _buildErrorScreen(state.message);
          }

          if (state is WeatherLoaded) {
            final weather = state.weather;
            
            // Sample forecast data
            final List<double> temps = state.forecast.isNotEmpty 
                ? state.forecast 
                : [28, 29, 27, 30, 28];
            final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WeatherBloc>().add(FetchCurrentLocationWeather());
              },
              child: CustomScrollView(
                slivers: [
                  // App Bar with Weather Animation
                  SliverAppBar(
                    expandedHeight: 280,
                    floating: true,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade300,
                            ],
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
                              Text(
                                '${weather.temp.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                weather.description.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
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
                  
                  // Main Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                              decoration: InputDecoration(
                                hintText: '🔍 Search city...',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
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
                          const SizedBox(height: 20),
                          
                          // Weather Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: WeatherCard(
                                  title: 'HUMIDITY',
                                  value: '${weather.humidity}%',
                                  icon: Icons.water_drop,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: WeatherCard(
                                  title: 'WIND',
                                  value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                                  icon: Icons.air,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: WeatherCard(
                                  title: 'FEELS LIKE',
                                  value: '${weather.feelsLike.toStringAsFixed(1)}°C',
                                  icon: Icons.thermostat,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: WeatherCard(
                                  title: 'MIN/MAX',
                                  value: '${weather.tempMin.toStringAsFixed(0)}°/${weather.tempMax.toStringAsFixed(0)}°',
                                  icon: Icons.show_chart,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // AI Insight Card
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple.shade50, Colors.blue.shade50],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Card(
                              elevation: 0,
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
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
                                          child: Icon(Icons.auto_awesome, 
                                              color: Colors.purple.shade700),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          '🤖 AI Weather Insight',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                                        _aiInsight.isEmpty
                                            ? 'Loading AI insights...'
                                            : _aiInsight,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 5-Day Forecast Chart
                          ForecastChart(
                            temperatures: temps,
                            days: days,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildInitialScreen();
        },
      ),
    );
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              '🌤️ SkyPulse',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Loading weather...',
              style: TextStyle(color: Colors.white70),
            ),
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
              const Text(
                'Error',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  context.read<WeatherBloc>().add(FetchCurrentLocationWeather());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.wb_sunny, size: 150, color: Colors.white);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'SkyPulse',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your Smart Weather Companion',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  context.read<WeatherBloc>().add(FetchCurrentLocationWeather());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
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