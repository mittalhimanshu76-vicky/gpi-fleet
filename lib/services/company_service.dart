import '../database/database_helper.dart';
import '../models/company_profile.dart';

class CompanyService {
  CompanyService._();

  static final CompanyService instance = CompanyService._();

  Future<CompanyProfile> getCompany() async {
    final data = await DatabaseHelper.instance.queryCompanyProfile();
    if (data == null) {
      return CompanyProfile.defaultProfile();
    }
    return CompanyProfile.fromMap(data);
  }

  Future<void> saveCompany(CompanyProfile profile) async {
    final existing = await DatabaseHelper.instance.queryCompanyProfile();
    if (existing == null) {
      await DatabaseHelper.instance.insertCompanyProfile(profile.toMap());
    } else {
      await updateCompany(profile.copyWith(id: existing['id'] as int));
    }
  }

  Future<void> updateCompany(CompanyProfile profile) async {
    if (profile.id == null) {
      await saveCompany(profile);
      return;
    }
    await DatabaseHelper.instance.updateCompanyProfileRecord(profile.id!, profile.toMap());
  }

  // Support for legacy code if any
  Future<CompanyProfile> getProfile() => getCompany();
  Future<void> saveProfile(CompanyProfile profile) => saveCompany(profile);
}

extension on CompanyProfile {
  CompanyProfile copyWith({int? id}) {
    return CompanyProfile(
      id: id ?? this.id,
      companyName: companyName,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      phone: phone,
      email: email,
      website: website,
      gstNumber: gstNumber,
      panNumber: panNumber,
      logoPath: logoPath,
      signaturePath: signaturePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
