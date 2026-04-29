import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({Key? key}) : super(key: key);

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  List<Hospital> _hospitals = [];
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  Hospital? _selectedHospital;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.instance.getCurrentPosition();
      _currentPosition = position;

      final hospitals = await LocationService.instance.getNearbyHospitals(
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (mounted) {
        setState(() {
          _hospitals = hospitals;
          _isLoading = false;
        });

        if (position != null) {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            13.0,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load nearby hospitals: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Hospitals'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadHospitals,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Finding nearby hospitals...',
            style: TextStyle(color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHospitals,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(37.7749, -122.4194);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildMap(center),
        ),
        Expanded(
          flex: 2,
          child: _buildHospitalList(),
        ),
      ],
    );
  }

  Widget _buildMap(LatLng center) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
        onTap: (_, __) => setState(() => _selectedHospital = null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.vaxguard.app',
        ),
        MarkerLayer(
          markers: [
            if (_currentPosition != null)
              Marker(
                width: 40,
                height: 40,
                point: center,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.person_pin,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ..._hospitals.map(
              (hospital) => Marker(
                width: 44,
                height: 44,
                point: LatLng(hospital.latitude, hospital.longitude),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedHospital = hospital),
                  child: Container(
                    decoration: BoxDecoration(
                      color: hospital.isEmergency
                          ? AppTheme.accentRed
                          : AppTheme.accentTeal,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedHospital?.id == hospital.id
                            ? Colors.yellow
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_selectedHospital != null)
          MarkerLayer(
            markers: [
              Marker(
                width: 200,
                height: 80,
                point: LatLng(
                  _selectedHospital!.latitude + 0.003,
                  _selectedHospital!.longitude,
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedHospital!.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (_selectedHospital!.distanceKm != null)
                        Text(
                          LocationService.instance
                              .formatDistance(_selectedHospital!.distanceKm),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textGray,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHospitalList() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.divider),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_hospital,
                    color: AppTheme.primaryBlue, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_hospitals.length} hospitals found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _hospitals.length,
              itemBuilder: (context, index) {
                final hospital = _hospitals[index];
                final isSelected = _selectedHospital?.id == hospital.id;
                return _buildHospitalTile(hospital, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalTile(Hospital hospital, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedHospital = hospital);
        _mapController.move(
          LatLng(hospital.latitude, hospital.longitude),
          15.0,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected
            ? AppTheme.primaryBlue.withOpacity(0.06)
            : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hospital.isEmergency
                    ? AppTheme.accentRed.withOpacity(0.1)
                    : AppTheme.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_hospital,
                color: hospital.isEmergency
                    ? AppTheme.accentRed
                    : AppTheme.accentTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hospital.type,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hospital.distanceKm != null)
                  Text(
                    LocationService.instance
                        .formatDistance(hospital.distanceKm),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _callHospital(hospital.phone),
                      child: const Icon(
                        Icons.phone,
                        size: 18,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _getDirections(hospital),
                      child: const Icon(
                        Icons.directions,
                        size: 18,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callHospital(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _getDirections(Hospital hospital) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${hospital.latitude},${hospital.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
