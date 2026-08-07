import '../database/database_helper.dart';
import '../models/driver.dart';

class DriverService {
  DriverService._();

  static final DriverService instance = DriverService._();

  Future<int> addDriver(Driver driver) async {
    final now = DateTime.now().toIso8601String();
    final data = driver.toMap();
    data['created_at'] = now;
    data['updated_at'] = now;
    data.remove('id');
    return await DatabaseHelper.instance.insertDriver(data);
  }

  Future<int> updateDriver(Driver driver) async {
    if (driver.id == null) throw Exception('Driver ID is required for update');
    final data = driver.toMap();
    data['updated_at'] = DateTime.now().toIso8601String();
    data.remove('id');
    data.remove('created_at');
    return await DatabaseHelper.instance.updateDriverRecord(driver.id!, data);
  }

  Future<int> deleteDriver(int id) async {
    return await DatabaseHelper.instance.deleteDriverRecord(id);
  }

  Future<Driver?> getDriver(int id) async {
    final data = await DatabaseHelper.instance.queryDriver(id);
    return data != null ? Driver.fromMap(data) : null;
  }

  Future<List<Driver>> getAllDrivers() async {
    final data = await DatabaseHelper.instance.queryAllDrivers();
    return data.map((m) => Driver.fromMap(m)).toList();
  }

  Future<List<Driver>> getActiveDrivers() async {
    final data = await DatabaseHelper.instance.queryActiveDrivers();
    return data.map((m) => Driver.fromMap(m)).toList();
  }

  Future<List<Driver>> searchDrivers(String query) async {
    final data = await DatabaseHelper.instance.querySearchDrivers(query);
    return data.map((m) => Driver.fromMap(m)).toList();
  }
}
