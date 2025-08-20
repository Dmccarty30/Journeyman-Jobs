import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/noaa_weather_service.dart';
import '../../services/location_service.dart';
import '../../design_system/app_theme.dart';
import '../../electrical_components/electrical_loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// NOAA Weather Radar Map - Official US government weather data
/// 
/// Features:
/// - Real-time NOAA/NWS radar imagery
/// - Active weather alerts and warnings
/// - Hurricane tracking from National Hurricane Center
/// - Storm Prediction Center outlooks
/// - Electrical worker safety information
class NoaaRadarMap extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final bool showAlerts;
  final bool showHurricanes;
  final Function(NoaaAlert)? onAlertTap;
  
  const NoaaRadarMap({
    Key? key,
    this.initialLatitude = 39.8283, // US center
    this.initialLongitude = -98.5795,
    this.initialZoom = 5.0,
    this.showAlerts = true,
    this.showHurricanes = true,
    this.onAlertTap,
  }) : super(key: key);

  @override
  State<NoaaRadarMap> createState() => _NoaaRadarMapState();
}

class _NoaaRadarMapState extends State<NoaaRadarMap> {
  late final MapController _mapController;
  final NoaaWeatherService _noaaService = NoaaWeatherService();
  final LocationService _locationService = LocationService();
  
  // Map state
  LatLng? _userLocation;
  NoaaRadarStation? _nearestRadar;
  List<NoaaAlert> _activeAlerts = [];
  List<TropicalSystem> _tropicalSystems = [];
  bool _isLoading = true;
  String? _error;
  
  // Radar settings
  String _radarProduct = 'N0R'; // Base reflectivity
  bool _showRadarLoop = false;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeMap() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // Get user location
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Find nearest radar station
        _nearestRadar = await _noaaService.getNearestRadarStation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        
        // Get active alerts
        if (widget.showAlerts) {
          _activeAlerts = await _noaaService.getActiveAlerts(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      }
      
      // Get tropical systems
      if (widget.showHurricanes) {
        _tropicalSystems = await _noaaService.getActiveTropicalSystems();
      }
      
      setState(() {
        _isLoading = false;
      });
      
      // Set up refresh timer for radar updates
      _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
        if (mounted) setState(() {}); // Refresh radar image
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load weather data';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: AppTheme.primaryNavy,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElectricalLoader(
                size: 60,
                color: AppTheme.accentCopper,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading NOAA Weather Data...',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_error != null) {
      return Container(
        color: AppTheme.primaryNavy,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.triangleExclamation,
                size: 48,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeMap,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(
              widget.initialLatitude,
              widget.initialLongitude,
            ),
            initialZoom: widget.initialZoom,
            minZoom: 3.0,
            maxZoom: 12.0,
          ),
          children: [
            // Base map tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.journeymanjobs.app',
              tileProvider: NetworkTileProvider(),
            ),
            
            // NOAA Radar overlay (if station available)
            if (_nearestRadar != null)
              Opacity(
                opacity: 0.7,
                child: OverlayImageLayer(
                  overlayImages: [
                    OverlayImage(
                      bounds: LatLngBounds(
                        LatLng(
                          _nearestRadar!.latitude - 2.5,
                          _nearestRadar!.longitude - 2.5,
                        ),
                        LatLng(
                          _nearestRadar!.latitude + 2.5,
                          _nearestRadar!.longitude + 2.5,
                        ),
                      ),
                      imageProvider: CachedNetworkImageProvider(
                        _noaaService.getRadarImageUrl(
                          stationId: _nearestRadar!.id,
                          product: _radarProduct,
                          loop: _showRadarLoop,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Hurricane/Tropical system markers
            if (_tropicalSystems.isNotEmpty)
              MarkerLayer(
                markers: _tropicalSystems.map((system) => Marker(
                  point: LatLng(system.latitude, system.longitude),
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _showTropicalSystemDetails(system),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStormColor(system.classification),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.hurricane,
                              color: Colors.white,
                              size: 24,
                            ),
                            Text(
                              system.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            
            // User location marker
            if (_userLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentCopper,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.locationCrosshairs,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        
        // Alert banner
        if (_activeAlerts.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => _showAlertsList(),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: _getAlertColor(_activeAlerts.first.severity),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: [AppTheme.shadowMd],
                ),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.triangleExclamation,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeAlerts.first.event,
                            style: AppTheme.headlineSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_activeAlerts.length > 1)
                            Text(
                              '+${_activeAlerts.length - 1} more alerts',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Controls
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // Radar product selector
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentCopper,
                    width: 2,
                  ),
                ),
                child: PopupMenuButton<String>(
                  initialValue: _radarProduct,
                  onSelected: (value) {
                    setState(() {
                      _radarProduct = value;
                    });
                  },
                  itemBuilder: (context) => NoaaWeatherService.radarProducts.entries
                      .map((e) => PopupMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      FontAwesomeIcons.layerGroup,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Animation toggle
              _buildControlButton(
                icon: _showRadarLoop ? Icons.pause : Icons.play_arrow,
                onPressed: () {
                  setState(() {
                    _showRadarLoop = !_showRadarLoop;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Station info
        if (_nearestRadar != null)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentCopper,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.towerBroadcast,
                    color: AppTheme.accentCopper,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NOAA ${_nearestRadar!.id} - ${_nearestRadar!.name}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.accentCopper,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: AppTheme.textLight,
        onPressed: onPressed,
      ),
    );
  }
  
  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'Extreme':
        return Color(0xFFD8006D); // Magenta
      case 'Severe':
        return AppTheme.errorRed;
      case 'Moderate':
        return AppTheme.warningYellow;
      case 'Minor':
        return Colors.orange;
      default:
        return AppTheme.infoBlue;
    }
  }
  
  Color _getStormColor(String classification) {
    if (classification.contains('Hurricane')) {
      if (classification.contains('5')) return Color(0xFFD8006D); // Cat 5
      if (classification.contains('4')) return Color(0xFFFF0000); // Cat 4
      if (classification.contains('3')) return Color(0xFFFF6060); // Cat 3
      if (classification.contains('2')) return Color(0xFFFFB366); // Cat 2
      return Color(0xFFFFD966); // Cat 1
    }
    if (classification.contains('Tropical Storm')) {
      return Color(0xFF00C5FF);
    }
    return Color(0xFF00FA9A); // Tropical Depression
  }
  
  void _showAlertsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Active Weather Alerts',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _activeAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = _activeAlerts[index];
                        return _buildAlertCard(alert);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildAlertCard(NoaaAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: _getAlertColor(alert.severity),
          width: 2,
        ),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () {
            widget.onAlertTap?.call(alert);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: _getAlertColor(alert.severity),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        alert.severity.toUpperCase(),
                        style: AppTheme.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Text(
                      alert.urgency,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  alert.event,
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  alert.headline,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: ${_formatDateTime(alert.expires)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showTropicalSystemDetails(TropicalSystem system) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.hurricane,
              color: _getStormColor(system.classification),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(system.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              system.classification,
              style: AppTheme.headlineSmall.copyWith(
                color: _getStormColor(system.classification),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildStormDetail('Max Winds', '${system.maxWindsMph} mph'),
            _buildStormDetail('Movement', '${system.movementDirection} at ${system.movementSpeedMph} mph'),
            _buildStormDetail('Pressure', '${system.pressure} mb'),
            _buildStormDetail('Location', '${system.latitude.toStringAsFixed(1)}°N, ${system.longitude.abs().toStringAsFixed(1)}°W'),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Last Update: ${_formatDateTime(system.lastUpdate)}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStormDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inHours.abs() < 24) {
      if (difference.isNegative) {
        return '${difference.inHours.abs()} hours ago';
      } else {
        return 'in ${difference.inHours} hours';
      }
    }
    
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}