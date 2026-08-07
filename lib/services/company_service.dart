import '../database/database_helper.dart';
import '../models/company_profile.dart';

class CompanyService {
  CompanyService._();

  static final CompanyService instance = CompanyService._();

  Future<CompanyProfile> getProfile() async {
    final data = await DatabaseHelper.instance.getCompanyProfile();
    if (data == null) {
      return CompanyProfile.defaultProfile();
    }
    return CompanyProfile.fromMap(data);
  }

  Future<void> saveProfile(CompanyProfile profile) async {
    await DatabaseHelper.instance.saveCompanyProfile(profile.toMap());
  }
}
