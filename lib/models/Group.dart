class Group {
  String _accountID;
  String _userID;
  String _groupID;

  String get userID => _userID;
  String get accountID => _accountID;
  String get groupID => _groupID;

  Group({userID, accountID, groupID}) : _userID = userID, _accountID = accountID, _groupID = groupID;


  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      userID: json['groupID']['userID'],
      accountID: json['groupID']['accountID'],
      groupID: json['groupID']['groupID'],
    );
  }
}