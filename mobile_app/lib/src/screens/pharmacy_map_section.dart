import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class PharmacyMapSection extends StatelessWidget {
  final double pharmacyLatitude;
  final double pharmacyLongitude;
  final double? userLatitude;
  final double? userLongitude;

  const PharmacyMapSection({
    super.key,
    required this.pharmacyLatitude,
    required this.pharmacyLongitude,
    this.userLatitude,
    this.userLongitude,
  });

  String get _distanceText {
    if (userLatitude == null || userLongitude == null) {
      return 'Location unavailable';
    }

    final distance = Geolocator.distanceBetween(
      userLatitude!,
      userLongitude!,
      pharmacyLatitude,
      pharmacyLongitude,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m away';
    }

    return '${(distance / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = CameraPosition(
      target: LatLng(pharmacyLatitude, pharmacyLongitude),
      zoom: 14,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: GoogleMap(
            initialCameraPosition: initialPosition,
            markers: {
              Marker(
                markerId: const MarkerId('pharmacy'),
                position: LatLng(pharmacyLatitude, pharmacyLongitude),
                infoWindow: const InfoWindow(title: 'Pharmacy Location'),
              ),
            },
            myLocationEnabled: userLatitude != null && userLongitude != null,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
        ),
        const SizedBox(height: 12),
        Text(_distanceText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
