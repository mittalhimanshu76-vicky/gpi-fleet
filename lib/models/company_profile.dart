class CompanyProfile {
  final int? id;
  final String name;
  final String? address;
  final String? gstNumber;
  final String? panNumber;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? logoPath;
  final String? signaturePath;
  final String? notes;

  CompanyProfile({
    this.id,
    required this.name,
    this.address,
    this.gstNumber,
    this.panNumber,
    this.phoneNumber,
    this.email,
    this.website,
    this.logoPath,
    this.signaturePath,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'phone_number': phoneNumber,
      'email': email,
      'website': website,
      'logo_path': logoPath,
      'signature_path': signaturePath,
      'notes': notes,
    };
  }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String?,
      gstNumber: map['gst_number'] as String?,
      panNumber: map['pan_number'] as String?,
      phoneNumber: map['phone_number'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      logoPath: map['logo_path'] as String?,
      signaturePath: map['signature_path'] as String?,
      notes: map['notes'] as String?,
    );
  }

  factory CompanyProfile.defaultProfile() {
    return CompanyProfile(
      name: 'Gautam Parkash India Private Limited',
      address: '60/128, Laxman Vihar, Muzaffarnagar - 251001',
      phoneNumber: '+91 9760811758',
      email: 'gautamparkashindia@gmail.com',
      website: 'www.gautamparkashindia.com',
    );
  }
}
