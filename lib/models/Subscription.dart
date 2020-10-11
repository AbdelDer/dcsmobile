class Subscription {
  String _vehicleModel;
  String _deviceID;
  num _startDate;
  num _endDate;

  String get vehicleModel => _vehicleModel;

  String get deviceID => _deviceID;

  num get startDate => _startDate;

  num get endDate => _endDate;

  int get subscriptionTime {
    final start =
        new DateTime.fromMillisecondsSinceEpoch(startDate.toInt() * 1000);
    final end = new DateTime.fromMillisecondsSinceEpoch(endDate.toInt() * 1000);
    final subscriptionTime = end.difference(start);
    return subscriptionTime.inDays;
  }

  Subscription({vehicleModel, deviceID, endDate, startDate})
      : _vehicleModel = vehicleModel,
        _deviceID = deviceID,
        _startDate = startDate,
        _endDate = endDate;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
        deviceID: json['deviceID'],
        vehicleModel: json['vehicleModel'],
        endDate: json['endDate'],
        startDate: json['startDate']);
  }
}
