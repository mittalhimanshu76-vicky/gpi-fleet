enum AlertType { maintenance, license }
enum AlertSeverity { high, medium, low }

class FleetAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String subtitle;
  final String date;
  final Map<String, dynamic> metadata;

  FleetAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.metadata,
  });
}

class FleetAlertsSummary {
  final List<FleetAlert> maintenanceOverdue;
  final List<FleetAlert> maintenanceDueSoon;
  final List<FleetAlert> licenseExpired;
  final List<FleetAlert> licenseExpiringSoon;

  FleetAlertsSummary({
    required this.maintenanceOverdue,
    required this.maintenanceDueSoon,
    required this.licenseExpired,
    required this.licenseExpiringSoon,
  });

  int get totalCount => 
    maintenanceOverdue.length + 
    maintenanceDueSoon.length + 
    licenseExpired.length + 
    licenseExpiringSoon.length;
}
