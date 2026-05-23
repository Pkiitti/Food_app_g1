class UserResponse {
  String id = "";
  String name = "";
  String email = "";

  UserResponse(
      this.id,
      this.name,
      this.email,
      );

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      json['id'] ?? "",
      json['name'] ?? "",
      json['email'] ?? "",
    );
  }
}