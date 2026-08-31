import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String placeName;

  // Pass your current position coordinates here when navigating to this screen
  final double? currentLatitude;
  final double? currentLongitude;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    this.currentLatitude,
    this.currentLongitude,
  });

  @override
  Widget build(BuildContext context) {
    // Build your list of markers dynamically
    final List<Marker> markers = [
      // 1. The Target Place Marker (Red)
      Marker(
        point: LatLng(latitude, longitude),
        width: 80,
        height: 80,
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40,
        ),
      ),
    ];

    // 2. Add Current Location Marker if available (Blue/Azure)
    if (currentLatitude != null && currentLongitude != null) {
      markers.add(
        Marker(
          point: LatLng(currentLatitude!, currentLongitude!),
          width: 80,
          height: 80,
          child: const Icon(
            Icons.person_pin_circle_rounded, // Distinct icon for user location
            color: Color.fromARGB(254, 3, 108, 140),
            size: 35,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(placeName)),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.geoguide',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
