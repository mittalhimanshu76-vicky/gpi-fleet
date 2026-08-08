import '../database/database_helper.dart';
import '../models/fuel_entry.dart';

class FuelService {
  FuelService._();

  static final FuelService instance = FuelService._();

  Future<int> addFuelEntry(FuelEntry fuel) async {
    return await DatabaseHelper.instance.insertFuelEntry(fuel.toMap());
  }

  Future<int> updateFuelEntry(FuelEntry fuel) async {
    if (fuel.id == null) throw Exception('Fuel Entry ID is required for update');
    return await DatabaseHelper.instance.updateFuelEntryRecord(fuel.id!, fuel.toMap());
  }

  Future<int> deleteFuelEntry(int id) async {
    return await DatabaseHelper.instance.deleteFuelEntryRecord(id);
  }

  Future<FuelEntry?> getFuelEntry(int id) async {
    final data = await DatabaseHelper.instance.queryFuelEntry(id);
    return data != null ? FuelEntry.fromMap(data) : null;
  }

  Future<List<FuelEntry>> getAllFuelEntries({String? searchTerm}) async {
    final data = await DatabaseHelper.instance.queryFuelEntries(searchTerm: searchTerm);
    return data.map((m) => FuelEntry.fromMap(m)).toList();
  }

  Future<List<FuelEntry>> getFuelEntriesByTruck(int truckId) async {
    final data = await DatabaseHelper.instance.queryFuelEntries(truckId: truckId);
    return data.map((m) => FuelEntry.fromMap(m)).toList();
  }

  Future<List<FuelEntry>> getFuelEntriesByDateRange(String startDate, String endDate) async {
    final data = await DatabaseHelper.instance.queryFuelEntries(startDate: startDate, endDate: endDate);
    return data.map((m) => FuelEntry.fromMap(m)).toList();
  }

  Future<List<Map<String, dynamic>>> getMonthlyFuelSummary() async {
    return await DatabaseHelper.instance.queryMonthlyFuelSummary();
  }

  // Flex filter method for complex filtering in UI
  Future<List<FuelEntry>> filterFuelEntries({int? truckId, String? startDate, String? endDate, String? searchTerm}) async {
    final data = await DatabaseHelper.instance.queryFuelEntries(
      truckId: truckId,
      startDate: startDate,
      endDate: endDate,
      searchTerm: searchTerm,
    );
    return data.map((m) => FuelEntry.fromMap(m)).toList();
  }
}
