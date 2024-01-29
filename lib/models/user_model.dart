class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String userType;
  double paypalBalance;
  double creditBalance;

  UserModel(
      {required this.uid,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.userType,
      required this.paypalBalance,
      required this.creditBalance});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'paypal-balance': paypalBalance,
      'credit-balance': creditBalance
    };
  }
}

class UserSingleton {
  static final UserSingleton _singleton = UserSingleton._internal();

  factory UserSingleton() {
    return _singleton;
  }

  UserSingleton._internal();

  UserModel? user;

  void setUser(UserModel newUser) {
    user = newUser;
  }

  void clearUser() {
    user = null;
  }
}
