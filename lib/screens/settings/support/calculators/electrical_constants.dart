import 'package:flutter/material.dart';

/// A data class holding properties for a specific wire size, based on NEC Table 8.
class WireData {
  /// The American Wire Gauge (AWG) size identifier (e.g., "14", "2/0", "250").
  final String awgSize;
  /// The cross-sectional area in circular mils.
  final double circularMils;
  /// The diameter of the bare conductor in inches.
  final double diameterInches;
  /// The cross-sectional area of the copper conductor in square inches.
  final double areaCopperSqIn;
  /// The cross-sectional area of the aluminum conductor in square inches.
  final double areaAluminumSqIn;
  /// The DC resistance of a copper conductor in ohms per 1000 feet.
  final double dcResistanceCopperPer1000Ft;
  /// The DC resistance of an aluminum conductor in ohms per 1000 feet.
  final double dcResistanceAluminumPer1000Ft;
  /// The allowable ampacity for a copper conductor with 60°C rated insulation.
  final int ampacity60C;
  /// The allowable ampacity for a copper conductor with 75°C rated insulation.
  final int ampacity75C;
  /// The allowable ampacity for a copper conductor with 90°C rated insulation.
  final int ampacity90C;
  /// The allowable ampacity for an aluminum conductor with 75°C rated insulation.
  final int ampacityAlum75C;
  /// The allowable ampacity for an aluminum conductor with 90°C rated insulation.
  final int ampacityAlum90C;

  /// Creates an instance of [WireData].
  const WireData({
    required this.awgSize,
    required this.circularMils,
    required this.diameterInches,
    required this.areaCopperSqIn,
    required this.areaAluminumSqIn,
    required this.dcResistanceCopperPer1000Ft,
    required this.dcResistanceAluminumPer1000Ft,
    required this.ampacity60C,
    required this.ampacity75C,
    required this.ampacity90C,
    required this.ampacityAlum75C,
    required this.ampacityAlum90C,
  });
}

/// A data class holding dimensional properties for a specific conduit size, based on NEC Table 4.
class ConduitData {
  /// The trade size of the conduit (e.g., "1/2"").
  final String size;
  /// The internal diameter of the conduit in inches.
  final double internalDiameter;
  /// The total internal area of the conduit in square inches.
  final double internalArea;
  /// The maximum allowable fill area for a single conductor.
  final double fill1Conductor;
  /// The maximum allowable fill area for two conductors.
  final double fill2Conductor;
  /// The maximum allowable fill area for three or more conductors.
  final double fill3OrMore;

  /// Creates an instance of [ConduitData].
  const ConduitData({
    required this.size,
    required this.internalDiameter,
    required this.internalArea,
    required this.fill1Conductor,
    required this.fill2Conductor,
    required this.fill3OrMore,
  });
}

/// A list of [WireData] for standard AWG wire sizes, based on NEC Table 8.
const List<WireData> standardWireData = [
  WireData(
    awgSize: '14',
    circularMils: 4110,
    diameterInches: 0.0641,
    areaCopperSqIn: 0.0030,
    areaAluminumSqIn: 0.0030,
    dcResistanceCopperPer1000Ft: 3.07,
    dcResistanceAluminumPer1000Ft: 5.06,
    ampacity60C: 15,
    ampacity75C: 20,
    ampacity90C: 25,
    ampacityAlum75C: 0,
    ampacityAlum90C: 0,
  ),
  WireData(
    awgSize: '12',
    circularMils: 6530,
    diameterInches: 0.0808,
    areaCopperSqIn: 0.0049,
    areaAluminumSqIn: 0.0049,
    dcResistanceCopperPer1000Ft: 1.93,
    dcResistanceAluminumPer1000Ft: 3.18,
    ampacity60C: 20,
    ampacity75C: 25,
    ampacity90C: 30,
    ampacityAlum75C: 20,
    ampacityAlum90C: 25,
  ),
  WireData(
    awgSize: '10',
    circularMils: 10380,
    diameterInches: 0.1019,
    areaCopperSqIn: 0.0077,
    areaAluminumSqIn: 0.0077,
    dcResistanceCopperPer1000Ft: 1.21,
    dcResistanceAluminumPer1000Ft: 2.00,
    ampacity60C: 30,
    ampacity75C: 35,
    ampacity90C: 40,
    ampacityAlum75C: 25,
    ampacityAlum90C: 30,
  ),
  WireData(
    awgSize: '8',
    circularMils: 16510,
    diameterInches: 0.1285,
    areaCopperSqIn: 0.0123,
    areaAluminumSqIn: 0.0123,
    dcResistanceCopperPer1000Ft: 0.764,
    dcResistanceAluminumPer1000Ft: 1.26,
    ampacity60C: 40,
    ampacity75C: 50,
    ampacity90C: 55,
    ampacityAlum75C: 40,
    ampacityAlum90C: 45,
  ),
  WireData(
    awgSize: '6',
    circularMils: 26240,
    diameterInches: 0.162,
    areaCopperSqIn: 0.0194,
    areaAluminumSqIn: 0.0194,
    dcResistanceCopperPer1000Ft: 0.491,
    dcResistanceAluminumPer1000Ft: 0.808,
    ampacity60C: 55,
    ampacity75C: 65,
    ampacity90C: 75,
    ampacityAlum75C: 50,
    ampacityAlum90C: 60,
  ),
  WireData(
    awgSize: '4',
    circularMils: 41740,
    diameterInches: 0.204,
    areaCopperSqIn: 0.0308,
    areaAluminumSqIn: 0.0308,
    dcResistanceCopperPer1000Ft: 0.308,
    dcResistanceAluminumPer1000Ft: 0.508,
    ampacity60C: 70,
    ampacity75C: 85,
    ampacity90C: 95,
    ampacityAlum75C: 65,
    ampacityAlum90C: 75,
  ),
  WireData(
    awgSize: '3',
    circularMils: 52620,
    diameterInches: 0.229,
    areaCopperSqIn: 0.0388,
    areaAluminumSqIn: 0.0388,
    dcResistanceCopperPer1000Ft: 0.245,
    dcResistanceAluminumPer1000Ft: 0.403,
    ampacity60C: 85,
    ampacity75C: 100,
    ampacity90C: 110,
    ampacityAlum75C: 75,
    ampacityAlum90C: 85,
  ),
  WireData(
    awgSize: '2',
    circularMils: 66360,
    diameterInches: 0.258,
    areaCopperSqIn: 0.0491,
    areaAluminumSqIn: 0.0491,
    dcResistanceCopperPer1000Ft: 0.194,
    dcResistanceAluminumPer1000Ft: 0.319,
    ampacity60C: 95,
    ampacity75C: 115,
    ampacity90C: 130,
    ampacityAlum75C: 90,
    ampacityAlum90C: 100,
  ),
  WireData(
    awgSize: '1',
    circularMils: 83690,
    diameterInches: 0.289,
    areaCopperSqIn: 0.0618,
    areaAluminumSqIn: 0.0618,
    dcResistanceCopperPer1000Ft: 0.154,
    dcResistanceAluminumPer1000Ft: 0.253,
    ampacity60C: 110,
    ampacity75C: 130,
    ampacity90C: 145,
    ampacityAlum75C: 100,
    ampacityAlum90C: 115,
  ),
  WireData(
    awgSize: '1/0',
    circularMils: 105600,
    diameterInches: 0.325,
    areaCopperSqIn: 0.0780,
    areaAluminumSqIn: 0.0780,
    dcResistanceCopperPer1000Ft: 0.122,
    dcResistanceAluminumPer1000Ft: 0.201,
    ampacity60C: 125,
    ampacity75C: 150,
    ampacity90C: 170,
    ampacityAlum75C: 120,
    ampacityAlum90C: 135,
  ),
  WireData(
    awgSize: '2/0',
    circularMils: 133100,
    diameterInches: 0.365,
    areaCopperSqIn: 0.0983,
    areaAluminumSqIn: 0.0983,
    dcResistanceCopperPer1000Ft: 0.0967,
    dcResistanceAluminumPer1000Ft: 0.159,
    ampacity60C: 145,
    ampacity75C: 175,
    ampacity90C: 195,
    ampacityAlum75C: 135,
    ampacityAlum90C: 150,
  ),
  WireData(
    awgSize: '3/0',
    circularMils: 167800,
    diameterInches: 0.410,
    areaCopperSqIn: 0.1240,
    areaAluminumSqIn: 0.1240,
    dcResistanceCopperPer1000Ft: 0.0766,
    dcResistanceAluminumPer1000Ft: 0.126,
    ampacity60C: 165,
    ampacity75C: 200,
    ampacity90C: 225,
    ampacityAlum75C: 155,
    ampacityAlum90C: 175,
  ),
  WireData(
    awgSize: '4/0',
    circularMils: 211600,
    diameterInches: 0.460,
    areaCopperSqIn: 0.1563,
    areaAluminumSqIn: 0.1563,
    dcResistanceCopperPer1000Ft: 0.0608,
    dcResistanceAluminumPer1000Ft: 0.100,
    ampacity60C: 195,
    ampacity75C: 230,
    ampacity90C: 260,
    ampacityAlum75C: 180,
    ampacityAlum90C: 205,
  ),
  WireData(
    awgSize: '250',
    circularMils: 250000,
    diameterInches: 0.500,
    areaCopperSqIn: 0.1855,
    areaAluminumSqIn: 0.1855,
    dcResistanceCopperPer1000Ft: 0.0515,
    dcResistanceAluminumPer1000Ft: 0.0847,
    ampacity60C: 215,
    ampacity75C: 255,
    ampacity90C: 290,
    ampacityAlum75C: 205,
    ampacityAlum90C: 230,
  ),
  WireData(
    awgSize: '300',
    circularMils: 300000,
    diameterInches: 0.548,
    areaCopperSqIn: 0.2223,
    areaAluminumSqIn: 0.2223,
    dcResistanceCopperPer1000Ft: 0.0429,
    dcResistanceAluminumPer1000Ft: 0.0706,
    ampacity60C: 240,
    ampacity75C: 285,
    ampacity90C: 320,
    ampacityAlum75C: 230,
    ampacityAlum90C: 260,
  ),
  WireData(
    awgSize: '350',
    circularMils: 350000,
    diameterInches: 0.592,
    areaCopperSqIn: 0.2590,
    areaAluminumSqIn: 0.2590,
    dcResistanceCopperPer1000Ft: 0.0367,
    dcResistanceAluminumPer1000Ft: 0.0605,
    ampacity60C: 260,
    ampacity75C: 310,
    ampacity90C: 350,
    ampacityAlum75C: 250,
    ampacityAlum90C: 280,
  ),
  WireData(
    awgSize: '400',
    circularMils: 400000,
    diameterInches: 0.632,
    areaCopperSqIn: 0.2958,
    areaAluminumSqIn: 0.2958,
    dcResistanceCopperPer1000Ft: 0.0321,
    dcResistanceAluminumPer1000Ft: 0.0529,
    ampacity60C: 280,
    ampacity75C: 335,
    ampacity90C: 380,
    ampacityAlum75C: 270,
    ampacityAlum90C: 305,
  ),
  WireData(
    awgSize: '500',
    circularMils: 500000,
    diameterInches: 0.707,
    areaCopperSqIn: 0.3718,
    areaAluminumSqIn: 0.3718,
    dcResistanceCopperPer1000Ft: 0.0258,
    dcResistanceAluminumPer1000Ft: 0.0424,
    ampacity60C: 320,
    ampacity75C: 380,
    ampacity90C: 430,
    ampacityAlum75C: 310,
    ampacityAlum90C: 350,
  ),
  WireData(
    awgSize: '600',
    circularMils: 600000,
    diameterInches: 0.775,
    areaCopperSqIn: 0.4459,
    areaAluminumSqIn: 0.4459,
    dcResistanceCopperPer1000Ft: 0.0214,
    dcResistanceAluminumPer1000Ft: 0.0353,
    ampacity60C: 355,
    ampacity75C: 420,
    ampacity90C: 475,
    ampacityAlum75C: 340,
    ampacityAlum90C: 385,
  ),
  WireData(
    awgSize: '750',
    circularMils: 750000,
    diameterInches: 0.866,
    areaCopperSqIn: 0.5581,
    areaAluminumSqIn: 0.5581,
    dcResistanceCopperPer1000Ft: 0.0171,
    dcResistanceAluminumPer1000Ft: 0.0282,
    ampacity60C: 400,
    ampacity75C: 475,
    ampacity90C: 535,
    ampacityAlum75C: 385,
    ampacityAlum90C: 435,
  ),
  WireData(
    awgSize: '1000',
    circularMils: 1000000,
    diameterInches: 1.000,
    areaCopperSqIn: 0.7408,
    areaAluminumSqIn: 0.7408,
    dcResistanceCopperPer1000Ft: 0.0129,
    dcResistanceAluminumPer1000Ft: 0.0212,
    ampacity60C: 455,
    ampacity75C: 545,
    ampacity90C: 615,
    ampacityAlum75C: 445,
    ampacityAlum90C: 500,
  ),
];

/// A list of [ConduitData] for standard EMT (Electrical Metallic Tubing) sizes, based on NEC Table 4.
const List<ConduitData> emtConduitData = [
  ConduitData(
    size: '1/2"',
    internalDiameter: 0.622,
    internalArea: 0.304,
    fill1Conductor: 0.161,
    fill2Conductor: 0.094,
    fill3OrMore: 0.122,
  ),
  ConduitData(
    size: '3/4"',
    internalDiameter: 0.824,
    internalArea: 0.533,
    fill1Conductor: 0.283,
    fill2Conductor: 0.165,
    fill3OrMore: 0.213,
  ),
  ConduitData(
    size: '1"',
    internalDiameter: 1.049,
    internalArea: 0.864,
    fill1Conductor: 0.458,
    fill2Conductor: 0.268,
    fill3OrMore: 0.346,
  ),
  ConduitData(
    size: '1-1/4"',
    internalDiameter: 1.380,
    internalArea: 1.496,
    fill1Conductor: 0.793,
    fill2Conductor: 0.464,
    fill3OrMore: 0.598,
  ),
  ConduitData(
    size: '1-1/2"',
    internalDiameter: 1.610,
    internalArea: 2.036,
    fill1Conductor: 1.079,
    fill2Conductor: 0.631,
    fill3OrMore: 0.814,
  ),
  ConduitData(
    size: '2"',
    internalDiameter: 2.067,
    internalArea: 3.356,
    fill1Conductor: 1.779,
    fill2Conductor: 1.040,
    fill3OrMore: 1.342,
  ),
  ConduitData(
    size: '2-1/2"',
    internalDiameter: 2.731,
    internalArea: 5.858,
    fill1Conductor: 3.105,
    fill2Conductor: 1.816,
    fill3OrMore: 2.343,
  ),
  ConduitData(
    size: '3"',
    internalDiameter: 3.356,
    internalArea: 8.846,
    fill1Conductor: 4.688,
    fill2Conductor: 2.742,
    fill3OrMore: 3.538,
  ),
  ConduitData(
    size: '3-1/2"',
    internalDiameter: 3.834,
    internalArea: 11.545,
    fill1Conductor: 6.119,
    fill2Conductor: 3.579,
    fill3OrMore: 4.618,
  ),
  ConduitData(
    size: '4"',
    internalDiameter: 4.334,
    internalArea: 14.753,
    fill1Conductor: 7.819,
    fill2Conductor: 4.573,
    fill3OrMore: 5.901,
  ),
  ConduitData(
    size: '5"',
    internalDiameter: 5.047,
    internalArea: 20.000,
    fill1Conductor: 10.600,
    fill2Conductor: 6.200,
    fill3OrMore: 8.000,
  ),
  ConduitData(
    size: '6"',
    internalDiameter: 6.065,
    internalArea: 28.890,
    fill1Conductor: 15.310,
    fill2Conductor: 8.956,
    fill3OrMore: 11.560,
  ),
];

/// A class that holds various constant values used in electrical calculations,
/// derived from the National Electrical Code (NEC).
class ElectricalConstants {
  /// The resistivity of copper in ohms per circular mil-foot.
  static const double copperResistivity = 12.9;
  /// The resistivity of aluminum in ohms per circular mil-foot.
  static const double aluminumResistivity = 21.2;
  
  /// The NEC recommended voltage drop limit for a branch circuit (3%).
  static const double branchCircuitVoltageDropLimit = 3.0;
  /// The NEC recommended voltage drop limit for a feeder (5%).
  static const double feederVoltageDropLimit = 5.0;
  /// The NEC recommended total voltage drop limit for a system (5%).
  static const double totalVoltageDropLimit = 5.0;
  
  /// A list of standard system voltages.
  static const List<int> standardVoltages = [120, 240, 277, 480, 600];
  
  /// The maximum conduit fill percentage for one conductor (53%).
  static const double fill1Conductor = 0.53;
  /// The maximum conduit fill percentage for two conductors (31%).
  static const double fill2Conductor = 0.31;
  /// The maximum conduit fill percentage for three or more conductors (40%).
  static const double fill3OrMore = 0.40;
  
  /// A typical power factor for motor loads.
  static const double powerFactorMotors = 0.8;
  /// A typical power factor for lighting loads.
  static const double powerFactorLighting = 1.0;
  /// A typical power factor for mixed loads.
  static const double powerFactorMixed = 0.9;
  
  /// The standard load value for general lighting in VA per square foot.
  static const double generalLightingVAPerSqFt = 3.0;
  /// The standard load value for a small appliance circuit in VA.
  static const double smallApplianceCircuitVA = 1500.0;
  /// The standard load value for a laundry circuit in VA.
  static const double laundryCircuitVA = 1500.0;
  /// The standard load value for a general-purpose receptacle in VA.
  static const double receptacleVA = 180.0;
  
  /// Demand factors for dwelling unit load calculations.
  static const Map<String, double> dwellingDemandFactors = {
    'first3000': 1.0,
    'next117000': 0.35,
    'over120000': 0.25,
  };
}

/// The material of a conductor.
enum ConductorMaterial { copper, aluminum }
/// The type of electrical circuit.
enum CircuitType { singlePhase, threePhase }
/// The type of conduit.
enum ConduitType { emt, imc, rmc, pvc }
/// The temperature rating of a conductor's insulation.
enum TemperatureRating { temp60C, temp75C, temp90C }
/// The type of electrical load.
enum LoadType { lighting, motor, heating, appliance, receptacle }

/// A utility class providing helper functions for electrical calculations.
class ElectricalHelpers {
  /// Retrieves [WireData] for a given [awgSize] from the [standardWireData] list.
  /// Returns `null` if the size is not found.
  static WireData? getWireData(String awgSize) {
    try {
      return standardWireData.firstWhere((wire) => wire.awgSize == awgSize);
    } catch (e) {
      return null;
    }
  }
  
  /// Retrieves [ConduitData] for a given [size] and [type].
  /// **Note:** Currently, only EMT data is implemented.
  static ConduitData? getConduitData(String size, ConduitType type) {
    // Currently only EMT data is provided
    if (type == ConduitType.emt) {
      try {
        return emtConduitData.firstWhere((conduit) => conduit.size == size);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// Formats a wire size string for user-friendly display.
  static String formatAwgSize(String size) {
    // Format AWG size for display
    if (size.contains('/')) {
      return '#$size AWG';
    } else if (int.tryParse(size) != null && int.parse(size) >= 14) {
      return '#$size AWG';
    } else {
      return '$size MCM';
    }
  }
  
  /// Returns a color indicating compliance status based on a percentage and a limit.
  ///
  /// - Green: Compliant.
  /// - Orange: Approaching the limit.
  /// - Red: Exceeds the limit.
  static Color getComplianceColor(double percentage, double limit) {
    if (percentage <= limit) {
      return Colors.green;
    } else if (percentage <= limit + 1) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}