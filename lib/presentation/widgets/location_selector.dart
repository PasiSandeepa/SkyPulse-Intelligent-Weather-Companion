import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.location_on, color: Colors.white),
      onPressed: () => _showLocationDialog(context),
    );
  }

  void _showLocationDialog(BuildContext context) {
    final TextEditingController cityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_city, color: Colors.purple),
            SizedBox(width: 10),
            Text('Change Location'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter city name or use current location:'),
            const SizedBox(height: 15),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                hintText: 'e.g., Galle, Colombo, Kandy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Popular Cities:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8,
              children: [
                _buildCityChip(context, 'Galle'),
                _buildCityChip(context, 'Colombo'),
                _buildCityChip(context, 'Kandy'),
                _buildCityChip(context, 'Jaffna'),
                _buildCityChip(context, 'Negombo'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final city = cityController.text.trim();
              if (city.isNotEmpty) {
                context.read<WeatherBloc>().add(FetchWeatherByCity(city));
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Set City'),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChip(BuildContext context, String city) {
    return ActionChip(
      label: Text(city),
      onPressed: () {
        context.read<WeatherBloc>().add(FetchWeatherByCity(city));
        Navigator.pop(context);
      },
      backgroundColor: Colors.purple.shade100,
    );
  }
}