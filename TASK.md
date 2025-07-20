# Journeyman Jobs - Task Tracking

## Completed
- [x] Integrate interactive real-time weather radar for storm page - Completed: 2025-07-20
  - Added dependencies: flutter_map, latlong2, dio, geolocator
  - Enhanced LocationService with real device permissions
  - Created WeatherRadarService with RainViewer API integration
  - Built InteractiveRadarMap widget with zoom/pan/animation controls
  - Integrated into StormScreen with "View Live Weather Radar" button
  - Configured iOS and Android permissions for location access

- [x] Replace RainViewer with NOAA Weather API - Completed: 2025-07-20
  - Created NoaaWeatherService for official US government weather data
  - Integrated National Weather Service API for alerts and forecasts
  - Added NOAA radar station imagery support
  - Integrated National Hurricane Center tropical system tracking
  - Built NoaaRadarMap widget with alert display capabilities
  - Updated StormScreen to use NOAA data with alert details dialog

- [x] Update project documentation - Completed: 2025-07-20
  - Updated README.md with comprehensive project information
  - Created plan.md with architecture and implementation phases
  - Enhanced CLAUDE.md with weather integration guidelines
  - Updated guide/screens.md with weather radar feature
  - Updated PRD with NOAA weather integration details
  - Created CHANGELOG.md for version tracking
  - Created docs/WEATHER_API.md for weather service documentation

## In Progress

## Discovered During Work
- [ ] Need to add real NHC API endpoints when available (currently using placeholder)
- [ ] Consider adding radar animation frames from NOAA ridge2 system
- [ ] Could enhance with lightning strike data from NOAA/GOES satellites
- [ ] May want to cache radar images for offline viewing during storms
- [ ] Could integrate with NOAA's CAP (Common Alerting Protocol) for standardized alerts