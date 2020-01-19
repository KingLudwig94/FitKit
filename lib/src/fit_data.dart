part of fit_kit;

class FitData {
  final num value;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String source;
  final bool userEntered;
  final DataType dataType;
  final String unit;

  FitData(this.value, this.dateFrom, this.dateTo, this.source, this.userEntered,
      this.dataType, this.unit);

  FitData.fromJson(Map<dynamic, dynamic> json)
      : value = json['value'],
        dateFrom = DateTime.fromMillisecondsSinceEpoch(json['date_from']),
        dateTo = DateTime.fromMillisecondsSinceEpoch(json['date_to']),
        source = json['source'],
        userEntered = json['user_entered'],
        dataType = DataType.valueOf(json['type']),
        unit = json['unit'] ?? DataType.valueOf(json['type'].unit);

  @override
  String toString() =>
      'FitData(value: $value $unit, dateFrom: $dateFrom, dateTo: $dateTo, source: $source, userEntered: $userEntered, dataType: $dataType)';
}
