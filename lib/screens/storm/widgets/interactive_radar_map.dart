import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/weather_radar_service.dart';
import '../../../services/location_service.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/electrical_loader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Interactive weather radar map widget with real-time storm tracking
/// 
/// Features:
/// - Pan and zoom with touch gestures
/// - Real-time weather radar overlay
/// - User location tracking
/// - Storm severity indicators
/// - Electrical-themed UI elements
class InteractiveRadarMap extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final bool showControls;
  final bool animateRadar;
  final Function(LatLng)? onLocationTap;
  
  const InteractiveRadarMap({
    super.key,
    this.initialLatitude = 39.8283, // US center
    this.initialLongitude = -98.5795,
    this.initialZoom = 5.0,
    this.showControls = true,
    this.animateRadar = false,
    this.onLocationTap,
  });

  @override
  State<InteractiveRadarMap> createState() => _InteractiveRadarMapState();
}

class _InteractiveRadarMapState extends State<InteractiveRadarMap> 
    with TickerProviderStateMixin {
  late final MapController _mapController;
  final WeatherRadarService _radarService = WeatherRadarService();
  final LocationService _locationService = LocationService();
  
  // Radar animation
  List<RadarFrame> _radarFrames = [];
  int _currentFrameIndex = 0;
  Timer? _animationTimer;
  AnimationController? _fadeController;
  
  // Map state
  LatLng? _userLocation;
  double _currentZoom = 5.0;
  bool _isLoading = true;
  String? _error;
  
  // Radar settings
  double _radarOpacity = 0.7;
  final RadarColorScheme _colorScheme = RadarColorScheme.universal;
  bool showSatellite = false;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentZoom = widget.initialZoom;
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _initializeRadar();
  }
  
  @override
  void dispose() {
    _animationTimer?.cancel();
    _fadeController?.dispose();
    super.dispose();
  }
  
  Future<void> _initializeRadar() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // Initialize radar service
      await _radarService.initialize();
      
      // Get radar data
      final radarData = await _radarService.getRadarData();
      if (radarData != null) {
        _radarFrames = _radarService.getAnimationFrames();
      }
      
      // Try to get user location
      await _getUserLocation();
      
      setState(() {
        _isLoading = false;
      });
      
      // Start animation if requested
      if (widget.animateRadar && _radarFrames.isNotEmpty) {
        _startAnimation();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load radar data';
      });
    }
  }
  
  Future<void> _getUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Center map on user location
        _mapController.move(_userLocation!, _currentZoom);
      }
    } catch (e) {
      // Location not available, use default
    }
  }
  
  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        _currentFrameIndex = (_currentFrameIndex + 1) % _radarFrames.length;
      });
      
      _fadeController?.forward(from: 0);
    });
  }
  
  void _toggleAnimation() {
    if (_animationTimer?.isActive ?? false) {
      _animationTimer?.cancel();
    } else {
      _startAnimation();
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
                'Loading Weather Radar...',
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
                onPressed: _initializeRadar,
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
            maxZoom: 18.0,
            onPositionChanged: (position, hasGesture) {
              setState(() {
                _currentZoom = position.zoom;
              });
            },
            onTap: (tapPosition, latLng) {
              widget.onLocationTap?.call(latLng);
            },
          ),
          children: [
            // Base map tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.journeymanjobs.app',
              tileProvider: NetworkTileProvider(),
            ),
            
            // Weather radar overlay
            if (_radarFrames.isNotEmpty)
              FadeTransition(
                opacity: _fadeController != null
                    ? Tween(begin: 0.0, end: _radarOpacity).animate(_fadeController!)
                    : AlwaysStoppedAnimation(_radarOpacity),
                child: TileLayer(
                  urlTemplate: _getRadarTileUrl(),
                  tileProvider: NetworkTileProvider(),
                  keepBuffer: 2,
                ),
              ),
            
            // Satellite overlay (if enabled)
            if (showSatellite)
              Opacity(
                opacity: 0.3,
                child: TileLayer(
                  urlTemplate: _radarService.getSatelliteTileUrl(
                    zoom: _currentZoom.round(),
                    x: 0, // Will be replaced by flutter_map
                    y: 0, // Will be replaced by flutter_map
                  ).replaceAll('/0/0/', '/{x}/{y}/'),
                  tileProvider: NetworkTileProvider(),
                ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
        
        // Controls
        if (widget.showControls) ...[
          // Zoom controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      (_currentZoom + 1).clamp(3.0, 18.0),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      (_currentZoom - 1).clamp(3.0, 18.0),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Location button
          Positioned(
            right: 16,
            bottom: 180,
            child: _buildControlButton(
              icon: FontAwesomeIcons.locationCrosshairs,
              onPressed: () async {
                await _getUserLocation();
                if (_userLocation != null) {
                  _mapController.move(_userLocation!, 10.0);
                }
              },
            ),
          ),
          
          // Radar controls
          Positioned(
            left: 16,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animation toggle
                _buildControlButton(
                  icon: _animationTimer?.isActive ?? false
                      ? Icons.pause
                      : Icons.play_arrow,
                  onPressed: _toggleAnimation,
                ),
                const SizedBox(height: 8),
                
                // Opacity slider
                Container(
                  width: 48,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.accentCopper,
                      width: 2,
                    ),
                  ),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Slider(
                      value: _radarOpacity,
                      min: 0.0,
                      max: 1.0,
                      activeColor: AppTheme.accentCopper,
                      inactiveColor: AppTheme.textLight,
                      onChanged: (value) {
                        setState(() {
                          _radarOpacity = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Radar timestamp
          if (_radarFrames.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.9),
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
                      FontAwesomeIcons.cloudBolt,
                      color: AppTheme.accentCopper,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getFrameTimeString(),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_radarFrames[_currentFrameIndex].type == RadarFrameType.forecast)
                      Text(
                        ' (Forecast)',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.warningYellow,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
        
        // Legend
        Positioned(
          bottom: 16,
          left: 16,
          child: _buildRadarLegend(),
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
        color: AppTheme.primaryNavy.withValues(alpha: 0.9),
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
  
  Widget _buildRadarLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentCopper,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Intensity:',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(width: 8),
          _buildIntensityIndicator(Colors.green, 'Light'),
          _buildIntensityIndicator(Colors.yellow, 'Moderate'),
          _buildIntensityIndicator(Colors.orange, 'Heavy'),
          _buildIntensityIndicator(Colors.red, 'Severe'),
        ],
      ),
    );
  }
  
  Widget _buildIntensityIndicator(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textLight,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getRadarTileUrl() {
    if (_radarFrames.isEmpty) return '';
    
    final frame = _radarFrames[_currentFrameIndex];
    
    // Build the tile URL template for flutter_map
    return _radarService.getRadarTileUrl(
      timestamp: frame.timestamp,
      zoom: 1, // Will be replaced by {z}
      x: 0,    // Will be replaced by {x}
      y: 0,    // Will be replaced by {y}
      colorScheme: _colorScheme,
      smooth: true,
      snow: false,
    ).replaceAll('/1/0/0/', '/{z}/{x}/{y}/');
  }
  
  String _getFrameTimeString() {
    if (_radarFrames.isEmpty) return '';
    
    final frame = _radarFrames[_currentFrameIndex];
    final time = frame.dateTime.toLocal();
    final now = DateTime.now();
    final difference = time.difference(now);
    
    if (difference.inMinutes.abs() < 60) {
      if (difference.isNegative) {
        return '${difference.inMinutes.abs()} min ago';
      } else {
        return 'In ${difference.inMinutes} min';
      }
    }
    
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
