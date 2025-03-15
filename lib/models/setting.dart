class Setting {
  final int settingId;
  final bool isCheck;
  final String name;
  final String type;

  Setting({
    required this.settingId,
    required this.isCheck,
    required this.name,
    required this.type,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      settingId: json['setting_id'],
      isCheck: json['is_check'] == 1,
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setting_id': settingId,
      'is_check': isCheck ? 1 : 0,
      'name': name,
      'type': type,
    };
  }
}