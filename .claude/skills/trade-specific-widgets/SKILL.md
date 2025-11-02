# Trade-Specific Widgets Skill

**Domain**: Frontend
**Category**: Industry-Specific UI Components
**Used By**: Electrical UI Specialist, Widget Specialist

## Skill Description
Expertise in creating specialized widgets for the electrical trade, including IBEW badges, certification displays, tool indicators, and safety compliance visualizations.

## IBEW Certification Badges

### Union Badge Widget
```dart
class IBEWBadge extends StatelessWidget {
  final CertificationLevel level;
  final int localNumber;
  final DateTime? expirationDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB87333), // Copper
            Color(0xFFD4915C), // Light copper
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCertificationIcon(level),
            color: Colors.white,
            size: 20,
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IBEW Local $localNumber',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                _getLevelText(level),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCertificationIcon(CertificationLevel level) {
    switch (level) {
      case CertificationLevel.apprentice1:
      case CertificationLevel.apprentice2:
      case CertificationLevel.apprentice3:
      case CertificationLevel.apprentice4:
        return Icons.school;
      case CertificationLevel.journeyman:
        return Icons.engineering;
      case CertificationLevel.foreman:
        return Icons.supervisor_account;
      case CertificationLevel.masterElectrician:
        return Icons.stars;
    }
  }

  String _getLevelText(CertificationLevel level) {
    switch (level) {
      case CertificationLevel.apprentice1: return '1st Year Apprentice';
      case CertificationLevel.apprentice2: return '2nd Year Apprentice';
      case CertificationLevel.apprentice3: return '3rd Year Apprentice';
      case CertificationLevel.apprentice4: return '4th Year Apprentice';
      case CertificationLevel.journeyman: return 'Journeyman';
      case CertificationLevel.foreman: return 'Foreman';
      case CertificationLevel.masterElectrician: return 'Master Electrician';
    }
  }
}
```

### Tool Requirement Indicator
```dart
class ToolRequirementCard extends StatelessWidget {
  final List<Tool> requiredTools;
  final List<Tool> userTools;

  @override
  Widget build(BuildContext context) {
    final missingTools = requiredTools
        .where((tool) => !userTools.contains(tool))
        .toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Required Tools',
                  style: Theme.of(context).textTheme.headline6,
                ),
                Spacer(),
                _buildComplianceIndicator(missingTools.isEmpty),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: requiredTools.map((tool) {
                final hasIt = userTools.contains(tool);
                return ToolChip(
                  tool: tool,
                  hasIt: hasIt,
                );
              }).toList(),
            ),
            if (missingTools.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Missing ${missingTools.length} tool(s)',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceIndicator(bool compliant) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: compliant ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            compliant ? Icons.check : Icons.warning,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            compliant ? 'Ready' : 'Missing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Safety Rating Display
```dart
class SafetyRatingWidget extends StatelessWidget {
  final double safetyScore; // 0.0 to 5.0
  final int incidentFreeDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getSafetyGradient(safetyScore),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < safetyScore ? Icons.star : Icons.star_border,
                color: Colors.white,
                size: 24,
              );
            }),
          ),
          SizedBox(height: 8),
          Text(
            '$incidentFreeDays Days',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'Incident Free',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getSafetyGradient(double score) {
    if (score >= 4.5) {
      return [Colors.green.shade600, Colors.green.shade400];
    } else if (score >= 3.5) {
      return [Colors.blue.shade600, Colors.blue.shade400];
    } else if (score >= 2.5) {
      return [Colors.orange.shade600, Colors.orange.shade400];
    } else {
      return [Colors.red.shade600, Colors.red.shade400];
    }
  }
}
```

### Electrical License Display
```dart
class ElectricalLicenseCard extends StatelessWidget {
  final License license;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: license.isValid
            ? Colors.green
            : Colors.red,
          child: Icon(
            Icons.verified_user,
            color: Colors.white,
          ),
        ),
        title: Text(license.type),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License #: ${license.number}'),
            Text('State: ${license.state}'),
            Text(
              'Expires: ${DateFormat.yMMMd().format(license.expiration)}',
              style: TextStyle(
                color: license.daysUntilExpiration < 30
                  ? Colors.orange
                  : null,
              ),
            ),
          ],
        ),
        trailing: license.daysUntilExpiration < 30
          ? Icon(Icons.warning, color: Colors.orange)
          : Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
}
```

## Integration Points
- Works with: [[electrical-ui-specialist]]
- Enhances: [[flutter-widget-architecture]]
- Supports: Electrical trade requirements

## Widget Categories
- Certification displays
- Tool indicators
- Safety visualizations
- License management
- Union affiliations
- Compliance tracking

## Performance Metrics
- Widget render: < 16ms
- Memory per widget: < 2MB
- Accessibility: WCAG 2.1 AA
- Touch targets: > 48x48dp