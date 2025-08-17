import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationIndicator extends StatefulWidget {
  const LocationIndicator({super.key});

  @override
  State<LocationIndicator> createState() => _LocationIndicatorState();
}

class _LocationIndicatorState extends State<LocationIndicator> {
  final LocationService _locationService = LocationService();
  bool _hasLocation = false;
  String? _address;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    final hasLocation = _locationService.hasLocation;
    final address = _locationService.currentAddress;

    setState(() {
      _hasLocation = hasLocation;
      _address = address;
    });
  }

  Future<void> _refreshLocation() async {
    await _locationService.getCurrentLocation();
    _checkLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _hasLocation ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _hasLocation ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _hasLocation ? Icons.location_on : Icons.location_off,
            size: 16,
            color: _hasLocation
                ? Colors.green.shade600
                : Colors.orange.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            _hasLocation ? 'Location Available' : 'Location Unavailable',
            style: TextStyle(
              fontSize: 12,
              color: _hasLocation
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!_hasLocation) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _refreshLocation,
              child: Icon(
                Icons.refresh,
                size: 14,
                color: Colors.orange.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
