class UserAccount {
  final int? accountId;
  final String? username;
  final String? password;
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
      accountId: json['account_id'],
      username: json['username'],
      password: json['password'],
      dept: json['dept'],
      prog: json['prog'],
      sem: json['sem'],
      sec: json['sec'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'account_id': accountId,
      'username': username,
      'password': password,
      'dept': dept,
      'prog': prog,
      'sem': sem,
      'sec': sec,
    };

    // Remove null values but keep the map structure
    data.removeWhere((key, value) => value == null);

    print('UserAccount toJson: $data'); // Debug print
    return data;
  }

  @override
  String toString() {
    return 'UserAccount(accountId: $accountId, username: $username, dept: $dept, prog: $prog, sem: $sem, sec: $sec)';
  }
}
