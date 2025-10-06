import 'electrical_constants.dart';

/// A base class for holding the results of an electrical calculation.
///
/// It includes the primary calculated value, its units, compliance status,
/// a descriptive message, and a reference to the relevant NEC article.
class CalculationResults {
  /// The primary numerical result of the calculation.
  final double value;
  /// The units for the [value] (e.g., '%', 'VA').
  final String units;
  /// A boolean indicating if the result is compliant with NEC standards.
  final bool isCompliant;
  /// A user-friendly message describing the outcome of the calculation.
  final String message;
  /// A reference to the relevant National Electrical Code (NEC) article.
  final String necReference;

  /// Creates an instance of [CalculationResults].
  CalculationResults({
    required this.value,
    required this.units,
    required this.isCompliant,
    required this.message,
    required this.necReference,
  });
}

/// A specialized [CalculationResults] class for voltage drop calculations.
class VoltageDropResult extends CalculationResults {
  /// The calculated voltage drop in volts.
  final double voltageDropVolts;
  /// The voltage drop expressed as a percentage of the system voltage.
  final double voltageDropPercentage;
  /// The final voltage at the end of the circuit after the drop.
  final double finalVoltage;

  /// Creates an instance of [VoltageDropResult].
  VoltageDropResult({
    required this.voltageDropVolts,
    required this.voltageDropPercentage,
    required this.finalVoltage,
    required super.isCompliant,
    required super.message,
    required super.necReference,
  }) : super(
          value: voltageDropPercentage,
          units: '%',
        );
}

/// A specialized [CalculationResults] class for conduit fill calculations.
class ConduitFillResult extends CalculationResults {
  /// The total cross-sectional area of all conductors in square inches.
  final double totalConductorArea;
  /// The internal area of the conduit in square inches.
  final double conduitArea;
  /// The percentage of the conduit's area that is filled by conductors.
  final double fillPercentage;
  /// The total number of conductors inside the conduit.
  final int conductorCount;

  /// Creates an instance of [ConduitFillResult].
  ConduitFillResult({
    required this.totalConductorArea,
    required this.conduitArea,
    required this.fillPercentage,
    required this.conductorCount,
    required super.isCompliant,
    required super.message,
    required super.necReference,
  }) : super(
          value: fillPercentage,
          units: '%',
        );
}

/// A specialized [CalculationResults] class for residential load calculations.
class LoadCalculationResult extends CalculationResults {
  /// The total connected load in VA before applying demand factors.
  final double totalLoad;
  /// The calculated load in VA after applying NEC demand factors.
  final double demandLoad;
  /// The recommended minimum electrical service size in amps.
  final int recommendedServiceSize;
  /// A breakdown of the different load components and their VA values.
  final Map<String, double> loadBreakdown;

  /// Creates an instance of [LoadCalculationResult].
  LoadCalculationResult({
    required this.totalLoad,
    required this.demandLoad,
    required this.recommendedServiceSize,
    required this.loadBreakdown,
    required super.isCompliant,
    required super.message,
    required super.necReference,
  }) : super(
          value: demandLoad,
          units: 'VA',
        );
}

/// A utility class providing static methods for common electrical calculations
/// based on the National Electrical Code (NEC).
class ElectricalCalculations {
  // Voltage Drop Calculations
  /// Calculates the voltage drop for a circuit.
  ///
  /// - [wireSize]: The AWG size of the wire.
  /// - [current]: The current in amps flowing through the circuit.
  /// - [length]: The one-way length of the circuit in feet.
  /// - [systemVoltage]: The voltage of the system (e.g., 120, 240, 480).
  /// - [material]: The conductor material ([ConductorMaterial.copper] or [ConductorMaterial.aluminum]).
  /// - [circuitType]: The type of circuit ([CircuitType.singlePhase] or [CircuitType.threePhase]).
  ///
  /// Returns a [VoltageDropResult] object with the detailed results.
  static VoltageDropResult calculateVoltageDrop({
    required String wireSize,
    required double current,
    required double length,
    required int systemVoltage,
    required ConductorMaterial material,
    required CircuitType circuitType,
  }) {
    final wireData = ElectricalHelpers.getWireData(wireSize);
    if (wireData == null) {
      return VoltageDropResult(
        voltageDropVolts: 0,
        voltageDropPercentage: 0,
        finalVoltage: systemVoltage.toDouble(),
        isCompliant: false,
        message: 'Invalid wire size selected',
        necReference: 'NEC Table 8',
      );
    }

    // Get resistivity constant based on material
    double resistivity = material == ConductorMaterial.copper
        ? ElectricalConstants.copperResistivity
        : ElectricalConstants.aluminumResistivity;

    // Calculate voltage drop using: VD = (K × I × L) / CM
    // For single-phase: multiply by 2 (both conductors)
    // For three-phase: multiply by √3 ≈ 1.732
    double multiplier = circuitType == CircuitType.singlePhase ? 2.0 : 1.732;
    
    double voltageDropVolts = (multiplier * resistivity * current * length) / wireData.circularMils;
    double voltageDropPercentage = (voltageDropVolts / systemVoltage) * 100;
    double finalVoltage = systemVoltage - voltageDropVolts;

    // Check NEC compliance (3% for branch circuits, 5% total)
    bool isCompliant = voltageDropPercentage <= ElectricalConstants.branchCircuitVoltageDropLimit;
    
    String message = isCompliant
        ? 'Voltage drop is within NEC limits'
        : 'Voltage drop exceeds NEC recommendations';
    
    if (voltageDropPercentage > ElectricalConstants.totalVoltageDropLimit) {
      message = 'Voltage drop exceeds NEC maximum limits - consider larger wire';
    }

    return VoltageDropResult(
      voltageDropVolts: voltageDropVolts,
      voltageDropPercentage: voltageDropPercentage,
      finalVoltage: finalVoltage,
      isCompliant: isCompliant,
      message: message,
      necReference: 'NEC 210.19(A), 215.2(A)',
    );
  }

  // Conduit Fill Calculations
  /// Calculates the conduit fill percentage.
  ///
  /// - [conduitSize]: The trade size of the conduit (e.g., "1/2").
  /// - [conduitType]: The type of conduit (e.g., [ConduitType.EMT]).
  /// - [conductors]: A list of [ConductorInfo] objects representing the wires in the conduit.
  ///
  /// Returns a [ConduitFillResult] with the detailed results.
  static ConduitFillResult calculateConduitFill({
    required String conduitSize,
    required ConduitType conduitType,
    required List<ConductorInfo> conductors,
  }) {
    final conduitData = ElectricalHelpers.getConduitData(conduitSize, conduitType);
    if (conduitData == null) {
      return ConduitFillResult(
        totalConductorArea: 0,
        conduitArea: 0,
        fillPercentage: 0,
        conductorCount: 0,
        isCompliant: false,
        message: 'Invalid conduit size or type',
        necReference: 'NEC Chapter 9, Table 4',
      );
    }

    // Calculate total conductor area
    double totalConductorArea = 0;
    int totalConductorCount = 0;
    
    for (final conductor in conductors) {
      final wireData = ElectricalHelpers.getWireData(conductor.awgSize);
      if (wireData != null) {
        totalConductorArea += wireData.areaCopperSqIn * conductor.quantity;
        totalConductorCount += conductor.quantity;
      }
    }

    // Determine fill limit based on conductor count
    double fillLimit;
    if (totalConductorCount == 1) {
      fillLimit = ElectricalConstants.fill1Conductor;
    } else if (totalConductorCount == 2) {
      fillLimit = ElectricalConstants.fill2Conductor;
    } else {
      fillLimit = ElectricalConstants.fill3OrMore;
    }

    double allowableFillArea = conduitData.internalArea * fillLimit;
    double fillPercentage = (totalConductorArea / conduitData.internalArea) * 100;
    bool isCompliant = totalConductorArea <= allowableFillArea;

    String message = isCompliant
        ? 'Conduit fill is within NEC limits'
        : 'Conduit fill exceeds NEC limits - use larger conduit';

    return ConduitFillResult(
      totalConductorArea: totalConductorArea,
      conduitArea: conduitData.internalArea,
      fillPercentage: fillPercentage,
      conductorCount: totalConductorCount,
      isCompliant: isCompliant,
      message: message,
      necReference: 'NEC Chapter 9, Table 1',
    );
  }

  // Load Calculations
  /// Performs a standard residential load calculation based on NEC Article 220.
  ///
  /// - [squareFootage]: The total square footage of the dwelling.
  /// - [smallApplianceCircuits]: The number of small appliance branch circuits.
  /// - [hasLaundryCircuit]: Whether a dedicated laundry circuit is present.
  /// - [appliances]: A list of fixed appliances and their loads.
  /// - [hvacLoad]: The total load of the HVAC system in VA.
  /// - [systemVoltage]: The service voltage.
  ///
  /// Returns a [LoadCalculationResult] with the detailed results.
  static LoadCalculationResult calculateResidentialLoad({
    required double squareFootage,
    required int smallApplianceCircuits,
    required bool hasLaundryCircuit,
    required List<ApplianceLoad> appliances,
    required double hvacLoad,
    required int systemVoltage,
  }) {
    Map<String, double> loadBreakdown = {};

    // General lighting load (NEC 220.12)
    double lightingLoad = squareFootage * ElectricalConstants.generalLightingVAPerSqFt;
    loadBreakdown['General Lighting'] = lightingLoad;

    // Small appliance circuits (NEC 220.52(A))
    double smallApplianceLoad = smallApplianceCircuits * ElectricalConstants.smallApplianceCircuitVA;
    loadBreakdown['Small Appliance Circuits'] = smallApplianceLoad;

    // Laundry circuit (NEC 220.52(B))
    double laundryLoad = hasLaundryCircuit ? ElectricalConstants.laundryCircuitVA : 0;
    if (hasLaundryCircuit) {
      loadBreakdown['Laundry Circuit'] = laundryLoad;
    }

    // Calculate base load before demand factors
    double baseLoad = lightingLoad + smallApplianceLoad + laundryLoad;

    // Apply demand factors (NEC 220.42)
    double demandLoad = _applyDwellingDemandFactors(baseLoad);
    loadBreakdown['Base Load (after demand factors)'] = demandLoad;

    // Add appliances
    double applianceLoad = 0;
    for (final appliance in appliances) {
      applianceLoad += appliance.load;
      loadBreakdown[appliance.name] = appliance.load;
    }
    demandLoad += applianceLoad;

    // Add HVAC load
    demandLoad += hvacLoad;
    if (hvacLoad > 0) {
      loadBreakdown['HVAC'] = hvacLoad;
    }

    double totalLoad = baseLoad + applianceLoad + hvacLoad;

    // Calculate service size
    double currentAmps = demandLoad / systemVoltage;
    int recommendedServiceSize = _calculateServiceSize(currentAmps);

    bool isCompliant = recommendedServiceSize >= 100; // Minimum 100A service per NEC

    String message = isCompliant
        ? 'Load calculation complete - service size determined'
        : 'Service size below minimum NEC requirements';

    return LoadCalculationResult(
      totalLoad: totalLoad,
      demandLoad: demandLoad,
      recommendedServiceSize: recommendedServiceSize,
      loadBreakdown: loadBreakdown,
      isCompliant: isCompliant,
      message: message,
      necReference: 'NEC Article 220',
    );
  }

  /// A helper method to apply NEC demand factors for general lighting and receptacle loads
  /// in dwelling units.
  static double _applyDwellingDemandFactors(double baseLoad) {
    double demandLoad = 0;
    
    if (baseLoad <= 3000) {
      demandLoad = baseLoad;
    } else if (baseLoad <= 120000) {
      demandLoad = 3000 + ((baseLoad - 3000) * 0.35);
    } else {
      demandLoad = 3000 + (117000 * 0.35) + ((baseLoad - 120000) * 0.25);
    }
    
    return demandLoad;
  }

  /// A helper method to determine the next standard service size based on the
  /// calculated current.
  static int _calculateServiceSize(double currentAmps) {
    List<int> standardServiceSizes = [100, 125, 150, 200, 225, 300, 400, 600, 800, 1000, 1200];
    
    for (int serviceSize in standardServiceSizes) {
      if (currentAmps <= serviceSize * 0.8) { // 80% derating
        return serviceSize;
      }
    }
    
    return 1200; // Maximum standard service size
  }

  /// Calculates the adjusted ampacity of a conductor after applying derating factors.
  ///
  /// - [wireSize]: The AWG size of the wire.
  /// - [material]: The conductor material.
  /// - [tempRating]: The temperature rating of the conductor's insulation.
  /// - [conductorCount]: The number of current-carrying conductors in the raceway.
  /// - [ambientTemp]: The ambient temperature in Celsius.
  ///
  /// Returns the derated ampacity in amps.
  static double calculateAmpacityDerating({
    required String wireSize,
    required ConductorMaterial material,
    required TemperatureRating tempRating,
    required int conductorCount,
    required double ambientTemp,
  }) {
    final wireData = ElectricalHelpers.getWireData(wireSize);
    if (wireData == null) return 0;

    // Get base ampacity
    int baseAmpacity;
    switch (tempRating) {
      case TemperatureRating.temp60C:
        baseAmpacity = wireData.ampacity60C;
        break;
      case TemperatureRating.temp75C:
        baseAmpacity = material == ConductorMaterial.copper 
            ? wireData.ampacity75C 
            : wireData.ampacityAlum75C;
        break;
      case TemperatureRating.temp90C:
        baseAmpacity = material == ConductorMaterial.copper 
            ? wireData.ampacity90C 
            : wireData.ampacityAlum90C;
        break;
    }

    // Apply derating factors
    double tempDerating = _getTemperatureDerating(ambientTemp, tempRating);
    double fillDerating = _getFillDerating(conductorCount);
    
    return baseAmpacity * tempDerating * fillDerating;
  }

  static double _getTemperatureDerating(double ambientTemp, TemperatureRating rating) {
    // Simplified temperature derating - normally would use NEC Table 310.15(B)(2)(a)
    if (ambientTemp <= 30) return 1.0;
    if (ambientTemp <= 40) return 0.82;
    if (ambientTemp <= 45) return 0.71;
    if (ambientTemp <= 50) return 0.58;
    return 0.41;
  }

  static double _getFillDerating(int conductorCount) {
    // NEC Table 310.15(B)(3)(a) - simplified
    if (conductorCount <= 3) return 1.0;
    if (conductorCount <= 6) return 0.8;
    if (conductorCount <= 9) return 0.7;
    if (conductorCount <= 20) return 0.5;
    return 0.45;
  }
}

// Supporting classes
// Supporting classes
/// A data class to hold information about a group of conductors for calculations.
class ConductorInfo {
  /// The AWG size of the conductor (e.g., "12", "2/0").
  final String awgSize;
  /// The number of conductors of this size.
  final int quantity;
  /// The type of insulation (e.g., "THWN"), which affects conductor area.
  final String insulationType;

  /// Creates an instance of [ConductorInfo].
  ConductorInfo({
    required this.awgSize,
    required this.quantity,
    this.insulationType = 'THWN',
  });
}

/// A data class representing a single fixed appliance for load calculations.
class ApplianceLoad {
  /// The name of the appliance (e.g., "Dishwasher").
  final String name;
  /// The load of the appliance in Volt-Amps (VA).
  final double load;
  /// A flag indicating if the appliance is a motor load.
  final bool isMotor;
  /// The power factor of the appliance.
  final double powerFactor;

  /// Creates an instance of [ApplianceLoad].
  ApplianceLoad({
    required this.name,
    required this.load,
    this.isMotor = false,
    this.powerFactor = 1.0,
  });
}