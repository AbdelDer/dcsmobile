class Alarm {
  String _accountID;
  String _userID;
  String _deviceID;
  double _maxSpeed;
  bool _startUp;
  bool _battery;
  bool _disconnect;
  bool _bonnet;
  bool _towing;
  bool _crash;
  bool _driver;
  double _minTemp;
  double _maxTemp;

  Alarm.byDefault({accountID, userID, deviceID})
      : this._accountID = accountID,
        this._userID = userID,
        this._deviceID = deviceID,
        this._startUp = false,
        this._battery = false,
        this._disconnect = false,
        this._bonnet = false,
        this._towing = false,
        this._crash = false,
        this._driver = false;

  Alarm.id({accountID, userID, deviceID})
      : this._accountID = accountID,
        this._userID = userID ?? "",
        this._deviceID = deviceID;

  Alarm(
      {accountID,
      userID,
      deviceID,
      maxSpeed,
      startUp,
      battery,
      disconnect,
      bonnet,
      towing,
      crash,
      driver,
      minTemp,
      maxTemp})
      : this._accountID = accountID,
        this._userID = userID,
        this._deviceID = deviceID,
        this._maxSpeed = maxSpeed,
        this._startUp = startUp,
        this._battery = battery,
        this._disconnect = disconnect,
        this._bonnet = bonnet,
        this._towing = towing,
        this._crash = crash,
        this._driver = driver,
        this._minTemp = minTemp,
        this._maxTemp = maxTemp;

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
        accountID: json['alarmID']['accountID'],
        userID: json['alarmID']['userID'],
        deviceID: json['alarmID']['deviceID'],
        battery: json['battery'],
        bonnet: json['bonnet'],
        crash: json['crash'],
        disconnect: json['disconnect'],
        driver: json['driver'],
        maxSpeed: json['maxSpeed'],
        maxTemp: json['maxTemp'],
        minTemp: json['minTemp'],
        startUp: json['startUp'],
        towing: json['towing']);
  }

  Map<String, dynamic> toJson() => {
        "alarmID": {
          "accountID": _accountID,
          "userID": _userID ?? "",
          "deviceID": _deviceID
        },
        "maxSpeed": _maxSpeed,
        "startUp": _startUp,
        "battery": _battery,
        "disconnect": _disconnect,
        "bonnet": _bonnet,
        "towing": _towing,
        "crash": _crash,
        "driver": _driver,
        "minTemp": _minTemp,
        "maxTemp": _maxTemp
      };

  Map<String, dynamic> toJsonID() => {
        "accountID": _accountID,
        "userID": _userID ?? "",
        "deviceID": _deviceID
      };

  double get maxTemp => _maxTemp;

  double get minTemp => _minTemp;

  bool get driver => _driver;

  bool get crash => _crash;

  bool get towing => _towing;

  bool get bonnet => _bonnet;

  bool get disconnect => _disconnect;

  bool get battery => _battery;

  bool get startUp => _startUp;

  double get maxSpeed => _maxSpeed;

  String get deviceID => _deviceID;

  String get userID => _userID;

  String get accountID => _accountID;

  set maxTemp(double value) {
    _maxTemp = value;
  }

  set minTemp(double value) {
    _minTemp = value;
  }

  set driver(bool value) {
    _driver = value;
  }

  set crash(bool value) {
    _crash = value;
  }

  set towing(bool value) {
    _towing = value;
  }

  set bonnet(bool value) {
    _bonnet = value;
  }

  set disconnect(bool value) {
    _disconnect = value;
  }

  set battery(bool value) {
    _battery = value;
  }

  set startUp(bool value) {
    _startUp = value;
  }

  set maxSpeed(double value) {
    _maxSpeed = value;
  }

  set deviceID(String value) {
    _deviceID = value;
  }

  set userID(String value) {
    _userID = value;
  }

  set accountID(String value) {
    _accountID = value;
  }
}
