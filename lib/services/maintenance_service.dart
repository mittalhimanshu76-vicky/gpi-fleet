import '../database/database_helper.dart';
import '../models/maintenance_entry.dart';

class MaintenanceService {
  MaintenanceService._();

  static final MaintenanceService instance = MaintenanceService._();

  Future<int> addMaintenanceEntry(MaintenanceEntry entry) async {
    return await DatabaseHelper.instance.insertMaintenanceEntry(entry.toMap());
  }

  Future<int> updateMaintenanceEntry(MaintenanceEntry entry) async {
    if (entry.id == null) throw Exception('Maintenance Entry ID is required for update');
    return await DatabaseHelper.instance.updateMaintenanceEntryRecord(entry.id!, entry.toMap());
  }

  Future<int> deleteMaintenanceEntry(int id) async {
    return await DatabaseHelper.instance.deleteMaintenanceEntryRecord(id);
  }

  Future<MaintenanceEntry?> getMaintenanceEntry(int id) async {
    final data = await DatabaseHelper.instance.queryMaintenanceEntry(id);
    return data != null ? MaintenanceEntry.fromMap(data) : null;
  }

  Future<List<MaintenanceEntry>> getAllMaintenanceEntries({
    int? truckId,
    String? startDate,
    String? endDate,
    String? type,
    String? searchTerm,
  }) async {
    final data = await DatabaseHelper.instance.queryMaintenanceEntries(
      truckId: truckId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      searchTerm: searchTerm,
    );
    return data.map((m) => MaintenanceEntry.fromMap(m)).toList();
  }

  Future<List<MaintenanceEntry>> getMaintenanceEntriesByTruck(int truckId) async {
    return getAllMaintenanceEntries(truckId: truckId);
  }

  Future<List<Map<String, dynamic>>> getMaintenanceSummary() async {
    return await DatabaseHelper.instance.queryMaintenanceSummary();
  }
}
