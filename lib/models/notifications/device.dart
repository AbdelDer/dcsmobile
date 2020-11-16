class Device {
  String _deviceID;
  String _vehicleModel;
  bool _selected = true;


  String get deviceID => _deviceID;

  String get vehicleModel => _vehicleModel;


  bool get selected => _selected;

  set selected(bool value) {
    _selected = value;
  }

  Device({accountID, deviceID, vehicleModel})
       : _deviceID = deviceID,
        _vehicleModel = vehicleModel;

  factory Device.fromJson(Map<dynamic, dynamic> json) {
    return Device(
      deviceID: json['deviceID'],
      vehicleModel: json['vehicleModel'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return _deviceID;
  }

  toJson() => _deviceID;
}
