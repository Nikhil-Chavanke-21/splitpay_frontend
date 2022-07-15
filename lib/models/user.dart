class UserId {
  final String ?uid;
  final String ?name;
  final String ?email;
  final String ?photoURL;
  final DateTime ?creationTime;
  final DateTime ?lastSignInTime;

  UserId({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoURL,
    required this.creationTime,
    required this.lastSignInTime,
  });
}
