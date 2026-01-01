import '../../domain/entities/school_entity.dart';

class SchoolModel extends SchoolEntity {
  SchoolModel({
    super.id,
    required super.name,
    super.location,
    super.phone,
    super.email,
    super.website,
    super.logoUrl,
    super.establishedYear,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id']?.toString(),
      name: json['name'] as String,
      location: json['location'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logo_url'] as String?,
      establishedYear: json['established_year'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (location != null) 'location': location,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (establishedYear != null) 'established_year': establishedYear,
      'is_active': isActive,
    };
  }
}