class DigitPermission {
  DigitPermission({
    this.user,
    this.digitPermission,
    this.totalPermission,
  });

  DigitPermission.fromJson(dynamic json) {
    user = json['user'];
    digitPermission = json['digitPermission'];
    totalPermission = json['totalPermission'];
  }

  String? user;
  int? digitPermission;
  int? totalPermission;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user'] = user;
    map['digitPermission'] = digitPermission;
    map['totalPermission'] = totalPermission;
    return map;
  }
}
