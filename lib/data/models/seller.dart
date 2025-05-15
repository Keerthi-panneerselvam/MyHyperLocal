class Seller {
  final String id;
  final String phoneNumber;
  String? name;
  String? email;
  String? profileImageUrl;
  bool isOnboardingComplete;
  DateTime createdAt;
  DateTime updatedAt;

  Seller({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    this.profileImageUrl,
    this.isOnboardingComplete = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Seller object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isOnboardingComplete': isOnboardingComplete,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a Seller object from a map
  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      isOnboardingComplete: map['isOnboardingComplete'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Create a copy of the Seller with updated fields
  Seller copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    String? profileImageUrl,
    bool? isOnboardingComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Seller(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Seller(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email, isOnboardingComplete: $isOnboardingComplete)';
  }
}