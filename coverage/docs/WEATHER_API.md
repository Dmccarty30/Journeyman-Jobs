# Weather API Documentation

## Overview

Journeyman Jobs integrates with official NOAA/NWS weather services to provide real-time weather data for storm work planning and safety. All weather data is free and requires no API keys.

## Services Used

### 1. National Weather Service API
**Base URL**: `https://api.weather.gov`

#### Endpoints Used:
- `/points/{latitude},{longitude}` - Get forecast office and grid coordinates
- `/alerts/active` - Get active weather alerts
- `/products` - Get forecast discussions and other text products

#### Example Usage:
```dart
// Get active alerts for a location
final response = await dio.get(
  'https://api.weather.gov/alerts/active',
  queryParameters: {
    'point': '29.7604,-95.3698', // Houston, TX
    'status': 'actual',
    'message_type': 'alert,update',
  },
);
```

### 2. NOAA Radar Imagery
**Base URL**: `https://radar.weather.gov/ridge`

#### Products Available:
- **N0R**: Base Reflectivity (default) - Shows precipitation intensity
- **N0V**: Base Velocity - Detects storm rotation
- **NTP**: Storm Total Precipitation - Accumulated rainfall
- **NCR**: Composite Reflectivity - Full atmosphere scan

#### Image URL Format:
```
https://radar.weather.gov/ridge/standard/{station_id}/{station_id}_{product}_0.gif
```

#### Example:
```
https://radar.weather.gov/ridge/standard/KHGX/KHGX_N0R_0.gif
```

### 3. National Hurricane Center
**Base URL**: `https://www.nhc.noaa.gov`

#### Data Feeds:
- Current tropical systems
- Hurricane forecasts and tracks
- Storm surge predictions

*Note: Full API integration pending - currently using placeholder endpoints*

### 4. Storm Prediction Center
**Base URL**: `https://www.spc.noaa.gov`

#### Outlooks:
- Day 1-3 convective outlooks
- Tornado probabilities
- Severe weather risk categories

## Implementation Details

### NoaaWeatherService

Located at: `lib/services/noaa_weather_service.dart`

#### Key Methods:

```dart
// Get weather alerts for a location
Future<List<NoaaAlert>> getActiveAlerts({
  required double latitude,
  required double longitude,
});

// Find nearest radar station
Future<NoaaRadarStation?> getNearestRadarStation({
  required double latitude,
  required double longitude,
});

// Get radar image URL
String getRadarImageUrl({
  required String stationId,
  String product = 'N0R',
  bool loop = false,
});

// Get active hurricanes/tropical storms
Future<List<TropicalSystem>> getActiveTropicalSystems();
```

### Alert Severity Levels

Alerts are filtered for relevance to electrical work:

1. **Extreme** (Magenta) - Immediate threat to life and property
2. **Severe** (Red) - Significant threat requiring preparation
3. **Moderate** (Yellow) - Possible threat, stay alert
4. **Minor** (Orange) - Minimal threat, stay informed

### Relevant Weather Events

The following events trigger storm work notifications:
- Hurricane Warning/Watch
- Tropical Storm Warning/Watch
- Tornado Warning/Watch
- Severe Thunderstorm Warning/Watch
- High Wind Warning/Watch
- Ice Storm Warning
- Winter Storm Warning
- Blizzard Warning
- Flood Warning
- Flash Flood Warning

## Radar Station Coverage

Major NOAA radar stations covering storm-prone areas:

| Station ID | Location | Coverage Area |
|------------|----------|---------------|
| KJAX | Jacksonville, FL | Northeast Florida |
| KHGX | Houston, TX | Southeast Texas |
| KLIX | New Orleans, LA | Southeast Louisiana |
| KTBW | Tampa Bay, FL | West Central Florida |
| KOKX | New York City, NY | NYC Metro Area |
| KTLX | Oklahoma City, OK | Central Oklahoma |

*Full list of 200+ stations available in the app*

## Rate Limits and Caching

- NWS API: No official rate limits, but be respectful
- Radar images: Updated every 4-10 minutes
- Alerts: Cached for 5 minutes
- Hurricane data: Cached for 15 minutes

## Error Handling

All weather services include fallback mechanisms:
1. Cached data used when offline
2. Graceful degradation if services unavailable
3. User-friendly error messages
4. Automatic retry with exponential backoff

## Privacy and Permissions

- Location data only used for weather services
- No location tracking without user consent
- Location accuracy: High for radar, balanced for alerts
- All data transmission encrypted

---

For more information about NOAA weather services:
- [NWS API Documentation](https://www.weather.gov/documentation/services-web-api)
- [NOAA Radar Information](https://www.roc.noaa.gov/WSR88D/)
- [National Hurricane Center](https://www.nhc.noaa.gov/)