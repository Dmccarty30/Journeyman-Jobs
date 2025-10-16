/// Model representing a union pay scale for a specific local
class PayScale {
  /// Local union number
  final String localNumber;

  /// City where the local is located
  final String city;

  /// State where the local is located
  final String state;

  /// Yearly salary based on 40-hour weeks
  final double? yearlySalaryBasedOn40hrWeeks;

  /// Hourly wage rate
  final double? hourlyRate;

  /// Total compensation package
  final double? totalPackage;

  /// Cost of living as a percentage of national average (0.01 = 1%)
  final double? costOfLivingAsAPercentageOfNationalAvg;

  /// Adjusted base wage for cost of living
  final double? adjustedBaseWageForCostOfLiving;

  /// Defined pension benefit
  final double? definedPension;

  /// Contribution to pension
  final double? contributionPension;

  /// 401K or annuity contribution
  final double? pension401k;

  /// Daily per diem allowance
  final double? perDiem;

  /// NEBF (National Electrical Benefit Fund) contribution
  final double? nebf;

  /// Vacation pay benefit
  final double? vacationPay;

  /// Health and welfare benefit
  final double? healthAndWelfare;

  /// Union dues (can be percentage or fixed amount)
  final String? dues;

  /// When this pay scale was last updated
  final String? lastUpdated;

  /// URL to wage sheet document
  final String? wageSheet;

  const PayScale({
    required this.localNumber,
    required this.city,
    required this.state,
    this.yearlySalaryBasedOn40hrWeeks,
    this.hourlyRate,
    this.totalPackage,
    this.costOfLivingAsAPercentageOfNationalAvg,
    this.adjustedBaseWageForCostOfLiving,
    this.definedPension,
    this.contributionPension,
    this.pension401k,
    this.perDiem,
    this.nebf,
    this.vacationPay,
    this.healthAndWelfare,
    this.dues,
    this.lastUpdated,
    this.wageSheet,
  });

  /// Create PayScale from Firestore document data
  factory PayScale.fromFirestore(Map<String, dynamic> data) {
    return PayScale(
      localNumber: data['localNumber']?.toString() ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      yearlySalaryBasedOn40hrWeeks: data['yearlySalaryBasedOn40hrWeeks'] as double?,
      hourlyRate: data['hourlyRate'] as double?,
      totalPackage: data['totalPackage'] as double?,
      costOfLivingAsAPercentageOfNationalAvg: data['costOfLivingAsAPercentageOfNationalAvg'] as double?,
      adjustedBaseWageForCostOfLiving: data['adjustedBaseWageForCostOfLiving'] as double?,
      definedPension: data['definedPension'] as double?,
      contributionPension: data['contributionPension'] as double?,
      pension401k: data['pension401K'] as double?,
      perDiem: data['perDiem'] as double?,
      nebf: data['nebf'] as double?,
      vacationPay: data['vacationPay'] as double?,
      healthAndWelfare: data['healthAndWelfare'] as double?,
      dues: data['dues'] as String?,
      lastUpdated: data['lastUpdated'] as String?,
      wageSheet: data['wageSheet'] as String?,
    );
  }

  /// Convert to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'localNumber': localNumber,
      'city': city,
      'state': state,
      'yearlySalaryBasedOn40hrWeeks': yearlySalaryBasedOn40hrWeeks,
      'hourlyRate': hourlyRate,
      'totalPackage': totalPackage,
      'costOfLivingAsAPercentageOfNationalAvg': costOfLivingAsAPercentageOfNationalAvg,
      'adjustedBaseWageForCostOfLiving': adjustedBaseWageForCostOfLiving,
      'definedPension': definedPension,
      'contributionPension': contributionPension,
      'pension401K': pension401k,
      'perDiem': perDiem,
      'nebf': nebf,
      'vacationPay': vacationPay,
      'healthAndWelfare': healthAndWelfare,
      'dues': dues,
      'lastUpdated': lastUpdated,
      'wageSheet': wageSheet,
    };
  }

  /// Get formatted local identifier: "Local {number}"
  String get localIdentifier => 'Local $localNumber';

  /// Get formatted location: "City, State"
  String get location => '$city, $state';

  /// Get formatted hourly rate
  String get formattedHourlyRate => hourlyRate != null ? '\$${hourlyRate!.toStringAsFixed(2)}' : 'N/A';

  /// Get formatted total package
  String get formattedTotalPackage => totalPackage != null ? '\$${totalPackage!.toStringAsFixed(2)}' : 'N/A';

  /// Get formatted yearly salary
  String get formattedYearlySalary => yearlySalaryBasedOn40hrWeeks != null ? '\$${yearlySalaryBasedOn40hrWeeks!.toStringAsFixed(0)}' : 'N/A';

  /// Get formatted cost of living
  String get formattedCostOfLiving => costOfLivingAsAPercentageOfNationalAvg != null ? '${(costOfLivingAsAPercentageOfNationalAvg! * 100).toStringAsFixed(1)}%' : 'N/A';

  /// Get formatted adjusted wage
  String get formattedAdjustedWage => adjustedBaseWageForCostOfLiving != null ? '\$${adjustedBaseWageForCostOfLiving!.toStringAsFixed(2)}' : 'N/A';
}
