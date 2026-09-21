import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PharmacyLocationPickerScreen extends StatefulWidget {
  const PharmacyLocationPickerScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<PharmacyLocationPickerScreen> createState() =>
      _PharmacyLocationPickerScreenState();
}

class _PharmacyLocationPickerScreenState
    extends State<PharmacyLocationPickerScreen> {
  static const _fallbackLocation = LatLng(24.7136, 46.6753);

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _locating = false;

  LatLng get _cameraTarget =>
      _selectedLocation ?? widget.initialLocation ?? _fallbackLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission was not granted.');
      }

      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() => _selectedLocation = location);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 16),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _selectLocation(LatLng location) {
    setState(() => _selectedLocation = location);
  }

  @override
  Widget build(BuildContext context) {
    final target = _cameraTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حدد موقع الصيدلية'),
        actions: [
          IconButton(
            tooltip: 'استخدم موقعي الحالي',
            onPressed: _locating ? null : _useCurrentLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: target, zoom: 14),
            onMapCreated: (controller) => _mapController = controller,
            onTap: _selectLocation,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers:
                _selectedLocation == null
                    ? const <Marker>{}
                    : {
                      Marker(
                        markerId: const MarkerId('selected_pharmacy'),
                        position: _selectedLocation!,
                        draggable: true,
                        onDragEnd: _selectLocation,
                      ),
                    },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _selectedLocation == null
                          ? 'اضغط على الخريطة لتحديد موقع الصيدلية.'
                          : 'الموقع المحدد: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed:
                          _selectedLocation == null
                              ? null
                              : () =>
                                  Navigator.of(context).pop(_selectedLocation),
                      icon: const Icon(Icons.check),
                      label: const Text('استخدم هذا الموقع'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_locating)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
