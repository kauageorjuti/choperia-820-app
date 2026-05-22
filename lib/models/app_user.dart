class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return AppUser(
      id: documentId ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }
}
