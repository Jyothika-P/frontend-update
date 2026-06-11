class SupportContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  SupportContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  factory SupportContact.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SupportContact(
      id: id,
      name: map['name'],
      phone: map['phone'],
      relationship: map['relationship'],
    );
  }
}
