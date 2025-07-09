# FEATURES

1. **Job Aggregation System** - Automated scraping service that consolidates job postings from multiple legacy IBEW union job boards into a centralized Firebase database.
2. **Personalized Dashboard** - AI-powered recommendation engine that analyzes user profiles to surface the most relevant electrical job opportunities.
3. **Advanced Filtering** - Multi-criteria search system allowing filtering by location, pay rate, electrical classification, and construction type.
4. **Union Directory** - Comprehensive database of 797+ IBEW locals with integrated contact functionality for phone, email, and navigation.
5. **Storm Work Highlighting** - Priority notification system for emergency restoration work with enhanced visibility and real-time alerts.
6. **Bid Management System** - Complete job application tracking from initial bid submission through acceptance, with status updates and history.

## IMPLEMENTATION EXAMPLES

### Job Aggregation System

In the `lib/services/job_aggregator/` folder:

- `scraper_service.dart` - Web scraping logic for legacy union portals
- `job_parser.dart` - Extracts structured data from various HTML formats
- `firebase_sync.dart` - Syncs aggregated jobs to Firestore
- `scheduler.dart` - Runs periodic scraping tasks

### Personalized Dashboard

In the `lib/screens/home/` folder:

- `dashboard_screen.dart` - Main personalized job feed UI
- `recommendation_engine.dart` - AI-powered job matching algorithm
- `job_card_widget.dart` - Reusable job display component
- `quick_filters.dart` - Fast access to common filter combinations

### Advanced Filtering

In the `lib/widgets/filters/` folder:

- `filter_bottom_sheet.dart` - Comprehensive filter UI with multiple criteria
- `location_filter.dart` - Geographic radius and specific location selection
- `classification_filter.dart` - Electrical trade classification selector
- `pay_range_slider.dart` - Minimum/maximum hourly rate filter
- `construction_type_chips.dart` - Commercial/Industrial/Residential/Utility selection
