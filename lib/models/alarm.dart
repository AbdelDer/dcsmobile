class Alarm {
  String _accountID;
  String _userID;
  String _deviceID;
  double _maxSpeed;
  num _startUp;
  num _battery;
  num _disconnect;
  num _bonnet;
  num _towing;
  num _crash;
  num _driver;
  double _minTemp;
  double _maxTemp;

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

  Map<String, dynamic> toJson() =>
      {
        "accountID": _accountID,
        "userID": _userID ?? "",
        "deviceID": _deviceID,
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

  double get maxTemp => _maxTemp;

  double get minTemp => _minTemp;

  num get driver => _driver;

  num get crash => _crash;

  num get towing => _towing;

  num get bonnet => _bonnet;

  num get disconnect => _disconnect;

  num get battery => _battery;

  num get startUp => _startUp;

  double get maxSpeed => _maxSpeed;

  String get deviceID => _deviceID;

  String get userID => _userID;

  String get accountID => _accountID;
}
