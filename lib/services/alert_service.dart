import '../database/database_helper.dart';
import '../models/fleet_alert.dart';

class AlertService {
  AlertService._();

  static final AlertService instance = AlertService._();

  Future<FleetAlertsSummary> getFleetAlerts() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thirtyDaysLater = today.add(const Duration(days: 30));

    // 1. Maintenance Alerts
    final maintenanceData = await db.rawQuery('''
      SELECT m.id, m.maintenance_type, m.next_service_date, t.truck_number
      FROM maintenance_entries m
      JOIN trucks t ON m.truck_id = t.id
      WHERE m.next_service_date IS NOT NULL AND m.next_service_date != ''
    ''');

    final maintenanceOverdue = <FleetAlert>[];
    final maintenanceDueSoon = <FleetAlert>[];

    for (final row in maintenanceData) {
      final dateStr = row['next_service_date'] as String;
      final nextDate = DateTime.tryParse(dateStr);
      if (nextDate == null) continue;

      if (nextDate.isBefore(today)) {
        maintenanceOverdue.add(FleetAlert(
          id: 'maint_${row['id']}',
          type: AlertType.maintenance,
          severity: AlertSeverity.high,
          title: 'Overdue: ${row['truck_number']}',
          subtitle: '${row['maintenance_type']} was due on $dateStr',
          date: dateStr,
          metadata: {'id': row['id'], 'truck_number': row['truck_number']},
        ));
      } else if (!nextDate.isAfter(thirtyDaysLater)) {
        maintenanceDueSoon.add(FleetAlert(
          id: 'maint_${row['id']}',
          type: AlertType.maintenance,
          severity: AlertSeverity.medium,
          title: 'Due Soon: ${row['truck_number']}',
          subtitle: '${row['maintenance_type']} due on $dateStr',
          date: dateStr,
          metadata: {'id': row['id'], 'truck_number': row['truck_number']},
        ));
      }
    }

    // 2. Driver License Alerts
    final driverData = await db.rawQuery('''
      SELECT id, driver_name, license_expiry
      FROM drivers
      WHERE license_expiry IS NOT NULL AND license_expiry != ''
    ''');

    final licenseExpired = <FleetAlert>[];
    final licenseExpiringSoon = <FleetAlert>[];

    for (final row in driverData) {
      final dateStr = row['license_expiry'] as String;
      final expiryDate = DateTime.tryParse(dateStr);
      if (expiryDate == null) continue;

      if (expiryDate.isBefore(today)) {
        licenseExpired.add(FleetAlert(
          id: 'lic_${row['id']}',
          type: AlertType.license,
          severity: AlertSeverity.high,
          title: 'Expired: ${row['driver_name']}',
          subtitle: 'License expired on $dateStr',
          date: dateStr,
          metadata: {'id': row['id'], 'driver_name': row['driver_name']},
        ));
      } else if (!expiryDate.isAfter(thirtyDaysLater)) {
        licenseExpiringSoon.add(FleetAlert(
          id: 'lic_${row['id']}',
          type: AlertType.license,
          severity: AlertSeverity.medium,
          title: 'Expiring Soon: ${row['driver_name']}',
          subtitle: 'License expires on $dateStr',
          date: dateStr,
          metadata: {'id': row['id'], 'driver_name': row['driver_name']},
        ));
      }
    }

    return FleetAlertsSummary(
      maintenanceOverdue: maintenanceOverdue,
      maintenanceDueSoon: maintenanceDueSoon,
      licenseExpired: licenseExpired,
      licenseExpiringSoon: licenseExpiringSoon,
    );
  }
}
