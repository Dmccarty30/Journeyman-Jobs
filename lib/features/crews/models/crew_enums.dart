import 'package:collection/collection.dart';

/// Crew role assignments for IBEW electrical workers
/// 
/// Defines specific roles within crew organization,
/// from leadership positions to specialized technical roles.
enum CrewRole {
  /// Crew leader responsible for overall coordination
  foreman,
  
  /// Senior journeyman providing technical guidance
  leadJourneyman,
  
  /// Standard journeyman electrician
  journeyman,
  
  /// Apprentice learning on the job
  apprentice,
  
  /// Equipment operator for specialized machinery
  operator,
  
  /// Safety coordinator ensuring compliance
  safetyCoordinator,
  
  /// Quality control inspector
  qualityInspector,
  
  /// Crew member (general assignment)
  crewMember;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case CrewRole.foreman:
        return 'Foreman';
      case CrewRole.leadJourneyman:
        return 'Lead Journeyman';
      case CrewRole.journeyman:
        return 'Journeyman';
      case CrewRole.apprentice:
        return 'Apprentice';
      case CrewRole.operator:
        return 'Operator';
      case CrewRole.safetyCoordinator:
        return 'Safety Coordinator';
      case CrewRole.qualityInspector:
        return 'Quality Inspector';
      case CrewRole.crewMember:
        return 'Crew Member';
    }
  }

  /// Convert from string representation
  static CrewRole? fromString(String? value) {
    if (value == null) return null;
    return CrewRole.values.firstWhereOrNull(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
    );
  }

  /// Get all available roles as strings
  static List<String> get allStrings => 
      CrewRole.values.map((role) => role.name).toList();

  /// Get all display names
  static List<String> get allDisplayNames => 
      CrewRole.values.map((role) => role.displayName).toList();
}

/// Response types for crew invitations and requests
/// 
/// Tracks the status of crew member responses to invitations,
/// job applications, and other crew-related requests.
enum ResponseType {
  /// Invitation or request is pending response
  pending,
  
  /// Member has accepted the invitation/request
  accepted,
  
  /// Member has declined the invitation/request
  declined,
  
  /// Request has expired without response
  expired,
  
  /// Response has been withdrawn
  withdrawn,
  
  /// Response is under review
  underReview;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case ResponseType.pending:
        return 'Pending';
      case ResponseType.accepted:
        return 'Accepted';
      case ResponseType.declined:
        return 'Declined';
      case ResponseType.expired:
        return 'Expired';
      case ResponseType.withdrawn:
        return 'Withdrawn';
      case ResponseType.underReview:
        return 'Under Review';
    }
  }

  /// Check if response allows further action
  bool get isActionable => this == ResponseType.pending;

  /// Check if response is final
  bool get isFinal => [
    ResponseType.accepted,
    ResponseType.declined,
    ResponseType.expired,
  ].contains(this);

  /// Convert from string representation
  static ResponseType? fromString(String? value) {
    if (value == null) return null;
    return ResponseType.values.firstWhereOrNull(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
    );
  }

  /// Get all available types as strings
  static List<String> get allStrings => 
      ResponseType.values.map((type) => type.name).toList();

  /// Get all display names
  static List<String> get allDisplayNames => 
      ResponseType.values.map((type) => type.displayName).toList();
}

/// Status for group bid applications
/// 
/// Tracks the progress of group bids submitted by crews
/// for IBEW electrical work opportunities.
enum GroupBidStatus {
  /// Bid is being prepared
  draft,
  
  /// Bid has been submitted
  submitted,
  
  /// Bid is under review by client
  underReview,
  
  /// Bid has been accepted
  accepted,
  
  /// Bid has been rejected
  rejected,
  
  /// Bid has been withdrawn by crew
  withdrawn,
  
  /// Bid has expired
  expired,
  
  /// Work is in progress
  inProgress,
  
  /// Work has been completed
  completed,
  
  /// Work has been cancelled
  cancelled;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case GroupBidStatus.draft:
        return 'Draft';
      case GroupBidStatus.submitted:
        return 'Submitted';
      case GroupBidStatus.underReview:
        return 'Under Review';
      case GroupBidStatus.accepted:
        return 'Accepted';
      case GroupBidStatus.rejected:
        return 'Rejected';
      case GroupBidStatus.withdrawn:
        return 'Withdrawn';
      case GroupBidStatus.expired:
        return 'Expired';
      case GroupBidStatus.inProgress:
        return 'In Progress';
      case GroupBidStatus.completed:
        return 'Completed';
      case GroupBidStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if bid can be modified
  bool get canModify => this == GroupBidStatus.draft;

  /// Check if bid is active
  bool get isActive => [
    GroupBidStatus.submitted,
    GroupBidStatus.underReview,
    GroupBidStatus.accepted,
    GroupBidStatus.inProgress,
  ].contains(this);

  /// Check if bid is final
  bool get isFinal => [
    GroupBidStatus.completed,
    GroupBidStatus.cancelled,
    GroupBidStatus.rejected,
    GroupBidStatus.expired,
  ].contains(this);

  /// Convert from string representation
  static GroupBidStatus? fromString(String? value) {
    if (value == null) return null;
    return GroupBidStatus.values.firstWhereOrNull(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
    );
  }

  /// Get all available statuses as strings
  static List<String> get allStrings => 
      GroupBidStatus.values.map((status) => status.name).toList();

  /// Get all display names
  static List<String> get allDisplayNames => 
      GroupBidStatus.values.map((status) => status.displayName).toList();
}

/// Message types for crew communication
/// 
/// Categorizes different types of messages within crew chat
/// and communication systems for better organization.
enum MessageType {
  /// Standard text message
  text,
  
  /// System-generated notification
  system,
  
  /// Job-related announcement
  jobUpdate,
  
  /// Safety alert or reminder
  safetyAlert,
  
  /// Schedule change notification
  scheduleChange,
  
  /// Location sharing message
  locationShare,
  
  /// File or document attachment
  fileAttachment,
  
  /// Image or photo message
  image,
  
  /// Audio message or voice note
  audio,
  
  /// Video message or clip
  video,
  
  /// Emergency alert
  emergency,
  
  /// Weather or environmental alert
  weatherAlert,
  
  /// Equipment status update
  equipmentStatus;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text Message';
      case MessageType.system:
        return 'System Message';
      case MessageType.jobUpdate:
        return 'Job Update';
      case MessageType.safetyAlert:
        return 'Safety Alert';
      case MessageType.scheduleChange:
        return 'Schedule Change';
      case MessageType.locationShare:
        return 'Location Share';
      case MessageType.fileAttachment:
        return 'File Attachment';
      case MessageType.image:
        return 'Image';
      case MessageType.audio:
        return 'Audio Message';
      case MessageType.video:
        return 'Video Message';
      case MessageType.emergency:
        return 'Emergency Alert';
      case MessageType.weatherAlert:
        return 'Weather Alert';
      case MessageType.equipmentStatus:
        return 'Equipment Status';
    }
  }

  /// Check if message type is critical
  bool get isCritical => [
    MessageType.emergency,
    MessageType.safetyAlert,
    MessageType.weatherAlert,
  ].contains(this);

  /// Check if message type is system-generated
  bool get isSystemGenerated => [
    MessageType.system,
    MessageType.jobUpdate,
    MessageType.scheduleChange,
    MessageType.weatherAlert,
    MessageType.equipmentStatus,
  ].contains(this);

  /// Check if message contains media
  bool get hasMedia => [
    MessageType.fileAttachment,
    MessageType.image,
    MessageType.audio,
    MessageType.video,
  ].contains(this);

  /// Convert from string representation
  static MessageType? fromString(String? value) {
    if (value == null) return null;
    return MessageType.values.firstWhereOrNull(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
    );
  }

  /// Get all available types as strings
  static List<String> get allStrings => 
      MessageType.values.map((type) => type.name).toList();

  /// Get all display names
  static List<String> get allDisplayNames => 
      MessageType.values.map((type) => type.displayName).toList();
}

/// Attachment types for crew messages
/// 
/// Specifies the type of file or media attachments
/// that can be shared within crew communications.
enum AttachmentType {
  /// Document files (PDF, DOC, etc.)
  document,
  
  /// Image files (JPG, PNG, etc.)
  image,
  
  /// Audio files (MP3, WAV, etc.)
  audio,
  
  /// Video files (MP4, MOV, etc.)
  video,
  
  /// Electrical diagrams and schematics
  schematic,
  
  /// Safety documentation
  safetyDoc,
  
  /// Job specification documents
  jobSpec,
  
  /// Equipment manuals
  manual,
  
  /// Code compliance documentation
  codeDoc,
  
  /// Work order or permit
  workOrder,
  
  /// Inspection report
  inspectionReport,
  
  /// Time sheet or log
  timeSheet;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case AttachmentType.document:
        return 'Document';
      case AttachmentType.image:
        return 'Image';
      case AttachmentType.audio:
        return 'Audio';
      case AttachmentType.video:
        return 'Video';
      case AttachmentType.schematic:
        return 'Schematic';
      case AttachmentType.safetyDoc:
        return 'Safety Document';
      case AttachmentType.jobSpec:
        return 'Job Specification';
      case AttachmentType.manual:
        return 'Manual';
      case AttachmentType.codeDoc:
        return 'Code Documentation';
      case AttachmentType.workOrder:
        return 'Work Order';
      case AttachmentType.inspectionReport:
        return 'Inspection Report';
      case AttachmentType.timeSheet:
        return 'Time Sheet';
    }
  }

  /// Get common file extensions for this attachment type
  List<String> get fileExtensions {
    switch (this) {
      case AttachmentType.document:
        return ['pdf', 'doc', 'docx', 'txt', 'rtf'];
      case AttachmentType.image:
        return ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      case AttachmentType.audio:
        return ['mp3', 'wav', 'm4a', 'aac'];
      case AttachmentType.video:
        return ['mp4', 'mov', 'avi', 'mkv'];
      case AttachmentType.schematic:
        return ['pdf', 'dwg', 'dxf', 'png', 'jpg'];
      case AttachmentType.safetyDoc:
        return ['pdf', 'doc', 'docx'];
      case AttachmentType.jobSpec:
        return ['pdf', 'doc', 'docx'];
      case AttachmentType.manual:
        return ['pdf', 'doc', 'docx'];
      case AttachmentType.codeDoc:
        return ['pdf', 'doc', 'docx'];
      case AttachmentType.workOrder:
        return ['pdf', 'doc', 'docx'];
      case AttachmentType.inspectionReport:
        return ['pdf', 'doc', 'docx', 'xls', 'xlsx'];
      case AttachmentType.timeSheet:
        return ['pdf', 'xls', 'xlsx', 'csv'];
    }
  }

  /// Check if attachment type is critical for safety
  bool get isSafetyCritical => [
    AttachmentType.safetyDoc,
    AttachmentType.schematic,
    AttachmentType.codeDoc,
    AttachmentType.inspectionReport,
  ].contains(this);

  /// Convert from string representation
  static AttachmentType? fromString(String? value) {
    if (value == null) return null;
    return AttachmentType.values.firstWhereOrNull(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
    );
  }

  /// Get all available types as strings
  static List<String> get allStrings => 
      AttachmentType.values.map((type) => type.name).toList();

  /// Get all display names
  static List<String> get allDisplayNames => 
      AttachmentType.values.map((type) => type.displayName).toList();
}

/// Job types specific to IBEW electrical work
/// 
/// Comprehensive categorization of electrical work types
/// for better job matching and crew specialization.
enum JobType {
  /// Inside electrical work
  insideWireman,
  
  /// Power line work
  journeymanLineman,
  
  /// Tree trimming operations
  treeTrimmer,
  
  /// Equipment operation
  equipmentOperator,
  
  /// Inside journeyman electrical work
  insideJourneymanElectrician,
  
  /// Storm restoration work
  stormWork,
  
  /// Maintenance line work
  maintenanceLineman,
  
  /// Electrical testing and commissioning
  testingTechnician,
  
  /// Substation construction and maintenance
  substationWork,
  
  /// Underground electrical work
  undergroundWork,
  
  /// High voltage transmission work
  transmissionWork,
  
  /// Distribution system work
  distributionWork,
  
  /// Renewable energy projects
  renewableEnergy,
  
  /// Industrial electrical work
  industrialElectrical,
  
  /// Commercial electrical work
  commercialElectrical,
  
  /// Data center electrical work
  dataCenterWork,
  
  /// Traffic signal and lighting
  trafficSignal,
  
  /// Telecommunications work
  telecommunications,
  
  /// Railroad electrical systems
  railroadElectrical;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case JobType.insideWireman:
        return 'Inside Wireman';
      case JobType.journeymanLineman:
        return 'Journeyman Lineman';
      case JobType.treeTrimmer:
        return 'Tree Trimmer';
      case JobType.equipmentOperator:
        return 'Equipment Operator';
      case JobType.insideJourneymanElectrician:
        return 'Inside Journeyman Electrician';
      case JobType.stormWork:
        return 'Storm Work';
      case JobType.maintenanceLineman:
        return 'Maintenance Lineman';
      case JobType.testingTechnician:
        return 'Testing Technician';
      case JobType.substationWork:
        return 'Substation Work';
      case JobType.undergroundWork:
        return 'Underground Work';
      case JobType.transmissionWork:
        return 'Transmission Work';
      case JobType.distributionWork:
        return 'Distribution Work';
      case JobType.renewableEnergy:
        return 'Renewable Energy';
      case JobType.industrialElectrical:
        return 'Industrial Electrical';
      case JobType.commercialElectrical:
        return 'Commercial Electrical';
      case JobType.dataCenterWork:
        return 'Data Center Work';
      case JobType.trafficSignal:
        return 'Traffic Signal';
      case JobType.telecommunications:
        return 'Telecommunications';
      case JobType.railroadElectrical:
        return 'Railroad Electrical';
    }
  }

  /// Get job type description
  String get description {
    switch (this) {
      case JobType.insideWireman:
        return 'Electrical installation and maintenance in buildings';
      case JobType.journeymanLineman:
        return 'Power line construction, maintenance, and repair';
      case JobType.treeTrimmer:
        return 'Vegetation management around power lines';
      case JobType.equipmentOperator:
        return 'Operation of specialized electrical equipment';
      case JobType.insideJourneymanElectrician:
        return 'Licensed electrical work in commercial/industrial settings';
      case JobType.stormWork:
        return 'Emergency power restoration after storms';
      case JobType.maintenanceLineman:
        return 'Routine maintenance of electrical distribution systems';
      case JobType.testingTechnician:
        return 'Testing and commissioning of electrical systems';
      case JobType.substationWork:
        return 'Substation construction, maintenance, and upgrades';
      case JobType.undergroundWork:
        return 'Underground electrical system installation and repair';
      case JobType.transmissionWork:
        return 'High voltage transmission line work';
      case JobType.distributionWork:
        return 'Electrical distribution system maintenance';
      case JobType.renewableEnergy:
        return 'Solar, wind, and renewable energy projects';
      case JobType.industrialElectrical:
        return 'Electrical work in industrial facilities';
      case JobType.commercialElectrical:
        return 'Commercial building electrical systems';
      case JobType.dataCenterWork:
        return 'Data center electrical infrastructure';
      case JobType.trafficSignal:
        return 'Traffic signal and street lighting systems';
      case JobType.telecommunications:
        return 'Telecommunications infrastructure work';
      case JobType.railroadElectrical:
        return 'Railroad electrical and signal systems';
    }
  }

  /// Check if job type is emergency/priority work
  bool get isEmergencyWork => [
    JobType.stormWork,
  ].contains(this);

  /// Check if job type requires special certifications
  bool get requiresSpecialCertification => [
    JobType.testingTechnician,
    JobType.railroadElectrical,
    JobType.renewableEnergy,
  ].contains(this);

  /// Check if job type is outdoor work
  bool get isOutdoorWork => [
    JobType.journeymanLineman,
    JobType.treeTrimmer,
    JobType.stormWork,
    JobType.maintenanceLineman,
    JobType.substationWork,
    JobType.transmissionWork,
    JobType.distributionWork,
    JobType.renewableEnergy,
    JobType.trafficSignal,
    JobType.railroadElectrical,
  ].contains(this);

  /// Convert from string representation
  static JobType? fromString(String? value) {
    if (value == null) return null;
    return JobType.values.firstWhereOrNull(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
    );
  }

  /// Get all available types as strings
  static List<String> get allStrings => 
      JobType.values.map((type) => type.name).toList();

  /// Get all display names
  static List<String> get allDisplayNames => 
      JobType.values.map((type) => type.displayName).toList();

  /// Get job types by category
  static List<JobType> get lineWork => [
    JobType.journeymanLineman,
    JobType.maintenanceLineman,
    JobType.transmissionWork,
    JobType.distributionWork,
    JobType.stormWork,
  ];

  static List<JobType> get insideWork => [
    JobType.insideWireman,
    JobType.insideJourneymanElectrician,
    JobType.industrialElectrical,
    JobType.commercialElectrical,
    JobType.dataCenterWork,
  ];

  static List<JobType> get specializedWork => [
    JobType.treeTrimmer,
    JobType.equipmentOperator,
    JobType.testingTechnician,
    JobType.substationWork,
    JobType.renewableEnergy,
    JobType.trafficSignal,
    JobType.telecommunications,
    JobType.railroadElectrical,
  ];
}

/// Extension methods for enum serialization compatibility
extension CrewEnumExtensions<T extends Enum> on T {
  /// Serialize enum to string (compatible with existing codebase)
  String serialize() => name;
}

/// Extension methods for enum list deserialization
extension CrewEnumListExtensions<T extends Enum> on Iterable<T> {
  /// Deserialize string to enum (compatible with existing codebase)
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

/// Share status for job sharing notifications
/// 
/// Tracks the status of job shares between users
enum ShareStatus {
  /// Share has been created but not yet viewed
  pending,
  
  /// Share has been viewed by the recipient
  viewed,
  
  /// Share has been accepted by the recipient
  accepted,
  
  /// Share has been declined by the recipient
  declined,
  
  /// Share has expired
  expired;

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case ShareStatus.pending:
        return 'Pending';
      case ShareStatus.viewed:
        return 'Viewed';
      case ShareStatus.accepted:
        return 'Accepted';
      case ShareStatus.declined:
        return 'Declined';
      case ShareStatus.expired:
        return 'Expired';
    }
  }

  /// Convert from string representation
  static ShareStatus? fromString(String? value) {
    if (value == null) return null;
    return ShareStatus.values.firstWhereOrNull(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
    );
  }

  /// Get all available statuses as strings
  static List<String> get allStrings => 
      ShareStatus.values.map((status) => status.name).toList();

  /// Get all display names
  static List<String> get allDisplayNames => 
      ShareStatus.values.map((status) => status.displayName).toList();
}

/// Generic deserialization function for crew enums
T? deserializeCrewEnum<T>(String? value) {
  switch (T) {
    case CrewRole _:
      return CrewRole.values.deserialize(value) as T?;
    case ResponseType _:
      return ResponseType.values.deserialize(value) as T?;
    case GroupBidStatus _:
      return GroupBidStatus.values.deserialize(value) as T?;
    case MessageType _:
      return MessageType.values.deserialize(value) as T?;
    case AttachmentType _:
      return AttachmentType.values.deserialize(value) as T?;
    case JobType _:
      return JobType.values.deserialize(value) as T?;
    case ShareStatus _:
      return ShareStatus.values.deserialize(value) as T?;
    default:
      return null;
  }
}
