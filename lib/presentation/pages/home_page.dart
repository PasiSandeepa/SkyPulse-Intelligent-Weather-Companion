import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
import '../../core/services/location_service.dart';
import '../../domain/entities/weather_entity.dart';
import '../widgets/voice_assistant_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const Duration _locationRefreshCooldown = Duration(seconds: 10);
  static const double _locationRefreshDistanceMeters = 300;

  final TextEditingController _searchController = TextEditingController();
  final FavoriteService _favoriteService = FavoriteService();
  final AIService _aiService = AIService();
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<ServiceStatus>? _locationServiceSubscription;
  Position? _lastObservedPosition;
  DateTime? _lastLocationRefreshAt;
  String _aiInsight = '';
  bool _isLoadingAI = false;
  bool _isDarkMode = false;
  bool _followDeviceLocation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _favoriteService.init();
    _listenToLocationServiceChanges();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchCurrentLocationWeather(force: true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && _followDeviceLocation) {
      _fetchCurrentLocationWeather(silent: true);
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_stopLocationTracking());
    }
  }

  void _fetchCurrentLocationWeather({
    bool silent = false,
    bool force = false,
  }) {
    unawaited(
      _syncAndFetchCurrentLocationWeather(
        silent: silent,
        force: force,
      ),
    );
  }

  void _searchWeatherByCity(String city) {
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) {
      return;
    }

    _followDeviceLocation = false;
    context.read<WeatherBloc>().add(FetchWeatherByCity(trimmedCity));
    _searchController.clear();
  }

  Future<void> _syncAndFetchCurrentLocationWeather({
    bool silent = false,
    bool force = false,
  }) async {
    _followDeviceLocation = true;
    final isTrackingReady = await _ensureLocationTrackingReady();
    if (!mounted || !isTrackingReady) {
      return;
    }

    final now = DateTime.now();
    final shouldThrottle = !force &&
        _lastLocationRefreshAt != null &&
        now.difference(_lastLocationRefreshAt!) < _locationRefreshCooldown;

    if (shouldThrottle) {
      return;
    }

    _lastLocationRefreshAt = now;
    context.read<WeatherBloc>().add(FetchCurrentLocationWeather(silent: silent));
  }

  Future<bool> _ensureLocationTrackingReady() async {
    final hasLocationAccess = await _locationService.ensureLocationAccess();
    if (!hasLocationAccess) {
      await _stopLocationTracking();
      return false;
    }

    if (_locationSubscription == null) {
      _startLocationTracking();
    }

    return true;
  }

  void _listenToLocationServiceChanges() {
    _locationServiceSubscription?.cancel();
    _locationServiceSubscription = Geolocator.getServiceStatusStream().listen(
      (status) {
        if (!mounted || !_followDeviceLocation) {
          return;
        }

        if (status == ServiceStatus.enabled) {
          _fetchCurrentLocationWeather(silent: true, force: true);
        } else {
          unawaited(_stopLocationTracking());
        }
      },
      onError: (_) {
        _locationServiceSubscription = null;
      },
      onDone: () {
        _locationServiceSubscription = null;
      },
    );
  }

  void _startLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    ).listen(
      _handlePositionUpdate,
      onError: (_) {
        _locationSubscription = null;
      },
      onDone: () {
        _locationSubscription = null;
      },
    );
  }

  Future<void> _stopLocationTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _lastObservedPosition = null;
  }

  void _handlePositionUpdate(Position position) {
    if (!mounted || !_followDeviceLocation) {
      _lastObservedPosition = position;
      return;
    }

    final previousPosition = _lastObservedPosition;
    _lastObservedPosition = position;

    if (previousPosition == null) {
      _fetchCurrentLocationWeather(silent: true);
      return;
    }

    final movedDistance = Geolocator.distanceBetween(
      previousPosition.latitude,
      previousPosition.longitude,
      position.latitude,
      position.longitude,
    );

    if (movedDistance >= _locationRefreshDistanceMeters) {
      _fetchCurrentLocationWeather(silent: true);
    }
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
    if (!mounted) {
      return;
    }
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

  String _formatCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'Coordinates unavailable';
    }

    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  String _formatUpdatedAt(DateTime updatedAt) {
    return DateFormat('MMM d, hh:mm a').format(updatedAt);
  }

  String _getAQILabel(int aqi) {
    if (aqi <= 50) return 'Good 😊';
    if (aqi <= 100) return 'Fair 🙂';
    if (aqi <= 150) return 'Moderate 😐';
    if (aqi <= 200) return 'Poor 😷';
    return 'Very Poor ☠️';
  }

  Color _getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }

  // ✅ COMPLETE _getGradientColors function
  List<Color> _getGradientColors(String condition, String cityName) {
    final c = condition.toLowerCase();
    final isGalle = cityName.toLowerCase() == 'galle';
    
    // ✅ Galle special case - always show rain colors
    if (isGalle) {
      return [Colors.blueGrey.shade800, Colors.blueGrey.shade500];
    }
    
    // Weather condition based gradients
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
    } else if (c.contains('mist') || c.contains('fog') || c.contains('haze')) {
      return [Colors.grey.shade600, Colors.grey.shade400];
    } else if (c.contains('smoke')) {
      return [Colors.grey.shade800, Colors.grey.shade600];
    } else if (c.contains('dust') || c.contains('sand')) {
      return [Colors.orange.shade800, Colors.orange.shade600];
    }
    
    // Default gradient
    return [Colors.blue.shade600, Colors.purple.shade400];
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
                color: _getGradientColors(weather.condition, weather.cityName)[0],
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (state.isLiveLocation) {
                      _fetchCurrentLocationWeather(force: true);
                      return;
                    }

                    context.read<WeatherBloc>().add(
                      FetchWeatherByCity(state.cityName),
                    );
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 400,
                        floating: true,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: _buildFlexibleHeader(weather, state),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.my_location, color: Colors.white),
                            onPressed: () => _fetchCurrentLocationWeather(force: true),
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
                              // Search Bar + GPS
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
                                          _searchWeatherByCity(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _fetchCurrentLocationWeather(force: true),
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

                              // Row 1 — Humidity + Wind
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

                              // Row 2 — Feels Like + Visibility
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

                              // Row 3 — AQI Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: GlowCard(
                                      title: 'AIR QUALITY',
                                      value: _getAQILabel(weather.aqi),
                                      icon: Icons.masks,
                                      color: _getAQIColor(weather.aqi),
                                      isDark: _isDarkMode,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GlowCard(
                                      title: 'AQI INDEX',
                                      value: '${weather.aqi}',
                                      icon: Icons.eco,
                                      color: _getAQIColor(weather.aqi),
                                      isDark: _isDarkMode,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Sunrise / Sunset Card
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

                              // AI Insight Card
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

  Widget _buildFlexibleHeader(WeatherEntity weather, WeatherLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final topInset = MediaQuery.of(context).padding.top;
        final headerHeight = constraints.maxHeight;
        final collapsedHeader = headerHeight < 320;
        final compactHeader = headerHeight < 380;
        final showFeelsLike = headerHeight >= 300;
        final animationHeight = collapsedHeader ? 56.0 : compactHeader ? 72.0 : 100.0;
        final temperatureSize = collapsedHeader ? 40.0 : compactHeader ? 48.0 : 56.0;
        final descriptionSize = collapsedHeader ? 12.0 : compactHeader ? 14.0 : 16.0;
        final detailSize = collapsedHeader ? 12.0 : compactHeader ? 13.0 : 14.0;
        final citySize = collapsedHeader ? 20.0 : compactHeader ? 22.0 : 24.0;
        final sectionSpacing = collapsedHeader ? 4.0 : compactHeader ? 8.0 : 10.0;
        final bottomSpacing = collapsedHeader ? 12.0 : compactHeader ? 16.0 : 24.0;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(weather.condition, weather.cityName),
            ),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                topInset + kToolbarHeight + (collapsedHeader ? 4 : 12),
                24,
                bottomSpacing,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WeatherAnimation(
                    weatherCondition: weather.condition,
                    cityName: weather.cityName,
                    height: animationHeight,
                  ),
                  SizedBox(height: sectionSpacing),
                  AnimatedTemperature(
                    temperature: weather.temp,
                    fontSize: temperatureSize,
                  ),
                  Text(
                    weather.description.toUpperCase(),
                    style: TextStyle(fontSize: descriptionSize, color: Colors.white70),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showFeelsLike) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
                      style: TextStyle(fontSize: detailSize, color: Colors.white60),
                    ),
                  ],
                  SizedBox(height: sectionSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          weather.cityName,
                          style: TextStyle(
                            fontSize: citySize,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: compactHeader ? 40 : 44,
                          height: compactHeader ? 40 : 44,
                        ),
                        visualDensity: VisualDensity.compact,
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
        );
      },
    );
  }

  Widget _buildLocationBadge(WeatherLoaded state, {required bool compact}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.isLiveLocation ? Icons.gps_fixed : Icons.search,
            size: compact ? 16 : 18,
            color: Colors.white,
          ),
          SizedBox(width: compact ? 8 : 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isLiveLocation
                      ? 'Live location tracking • ${state.locationSource}'
                      : 'Manual city mode',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.isLiveLocation
                      ? '${_formatCoordinates(state.latitude, state.longitude)} • Updated ${_formatUpdatedAt(state.updatedAt)}'
                      : 'Showing weather for ${state.cityName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    _searchWeatherByCity(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search city instead',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _fetchCurrentLocationWeather(force: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Try Location Again'),
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
                onPressed: () => _fetchCurrentLocationWeather(force: true),
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
    WidgetsBinding.instance.removeObserver(this);
    _locationServiceSubscription?.cancel();
    _locationSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}