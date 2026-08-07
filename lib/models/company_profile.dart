class CompanyProfile {
  final int? id;
  final String companyName;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final String? email;
  final String? website;
  final String? gstNumber;
  final String? panNumber;
  final String? logoPath;
  final String? signaturePath;
  final String? createdAt;
  final String? updatedAt;

  CompanyProfile({
    this.id,
    required this.companyName,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.email,
    this.website,
    this.gstNumber,
    this.panNumber,
    this.logoPath,
    this.signaturePath,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'phone': phone,
      'email': email,
      'website': website,
      'gst_number': gstNumber,
      'pan_number': panNumber,
      'logo_path': logoPath,
      'signature_path': signaturePath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      id: map['id'] as int?,
      companyName: map['company_name'] as String? ?? map['name'] as String? ?? '',
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      pincode: map['pincode'] as String?,
      phone: map['phone'] as String? ?? map['phone_number'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      gstNumber: map['gst_number'] as String?,
      panNumber: map['pan_number'] as String?,
      logoPath: map['logo_path'] as String?,
      signaturePath: map['signature_path'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  factory CompanyProfile.defaultProfile() {
    return CompanyProfile(
      companyName: 'Gautam Parkash India Private Limited',
      address: '60/128, Laxman Vihar',
      city: 'Muzaffarnagar',
      state: 'Uttar Pradesh',
      pincode: '251001',
      phone: '+91 9760811758',
      email: 'gautamparkashindia@gmail.com',
      website: 'www.gautamparkashindia.com',
    );
  }
}
