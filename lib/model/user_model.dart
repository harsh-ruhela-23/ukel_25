class UserModel {
  String? id;
  String? role;
  String? email;
  String? createdBy;

  UserModel({this.id, this.role, this.email, this.createdBy});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      role: json["role"],
      email: json["email"],
      createdBy: json["createdBy"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data["id"] = id;
    data["role"] = role;
    data["email"] = email;
    data["createdBy"] = createdBy;
    return data;
  }

}