class UserAccount {
  final int? accountId;
  final String? username;
  final String?
  password; // Only for sending to server, not expected in response
  final String? dept;
  final String? prog;
  final int? sem;
  final String? sec;

  UserAccount({
    this.accountId,
    this.username,
    this.password,
    this.dept,
    this.prog,
    this.sem,
    this.sec,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      accountId: int.tryParse(json['account_id']?.toString() ?? ''),
      username: json['username'],
      dept: json['dept'],
      prog: json['prog'],
      sem: int.tryParse(json['sem']?.toString() ?? ''),
      sec: json['sec'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'account_id': accountId,
      'username': username,
      'password': password,
      'dept': dept,
      'prog': prog,
      'sem': sem,
      'sec': sec,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}
