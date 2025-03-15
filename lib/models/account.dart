class Account {
  final int? id;
  final DateTime? birthday;
  final DateTime? created_at;
  final DateTime? deleted_date;
  final String? email;
  final String? fullname;
  final String? gender;
  final String? google_id;
  final String? image;
  final bool? is_deleted;
  final int? is_google_account;
  final String? password;
  final String? phone;
  final DateTime? updated_at;
  final int? role_id;
  final bool? status;
  

  Account({
    this.id,
    this.birthday,
    this.created_at,
    this.deleted_date,
    this.email,
    this.fullname,
    this.gender,
    this.google_id,
    this.image,
    this.is_deleted,
    this.is_google_account,
    this.password,
    this.phone,
    this.updated_at,
    this.role_id,
    this.status,
   
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      birthday: json['birthday'],
      created_at: json['created_at'],
      deleted_date: json['deleted_date'],
      email: json['email'],
      fullname: json['fullname'],
      gender: json['gender'],
      google_id: json['google_id'],
      image: json['image'],
      is_deleted: json['is_deleted'],
      is_google_account: json['is_google_account'],
      password: json['password'],
      phone: json['phone'],
      updated_at: json['updated_at'],
      role_id: json['role_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'birthday': birthday,
      'created_at': created_at,
      'deleted_date': deleted_date,
      'email': email,
      'fullname': fullname,
      'gender': gender,
      'google_id': google_id,
      'image': image,
      'is_deleted': is_deleted,
      'is_google_account': is_google_account,
      'password': password,
      'phone': phone,
      'updated_at': updated_at,
      'role_id': role_id,
      'status': status,
    };
  }
}
