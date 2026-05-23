class UserResponseRegister {
  String id = "";
  String name = "";
  String email = "";

  UserResponseRegister(
      this.id,
      this.name,
      this.email,
      );

  UserResponseRegister.buildDefault();

  factory UserResponseRegister.fromJson(Map<String, dynamic> json) {
    return UserResponseRegister(
      json['id'] ?? "",
      json['name'] ?? "",
      json['email'] ?? "",
    );
  }
}