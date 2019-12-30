import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'data_type.g.dart';

abstract class Enum {
  //String get type;
  String get string;
  String get unit;
}

/// Example of how to use [EnumClass].
///
/// Enum constants must be declared as `static const`. Initialize them from
/// the generated code. You can use any initializer starting _$ and the
/// generated code will match it. For example, you could initialize "yes" to
/// "_$yes", "_$y" or even "_$abc".
///
/// You need to write three pieces of boilerplate to hook up the generated
/// code: a constructor called `_`, a `values` method, and a `valueOf` method.
class DataType extends EnumClass implements Enum {
  /// Example of how to make an [EnumClass] serializable.
  ///
  /// Declare a static final [Serializers] field called `serializer`.
  /// The built_value code generator will provide the implementation. You need
  /// to do this for every type you want to serialize.
  static Serializer<DataType> get serializer => _$dataTypeSerializer;

  static const DataType height = _$hgt;
  static const DataType blood_glucose = _$bg;
  static const DataType sleep = _$sl;
  static const DataType heart_rate = _$hr;
  static const DataType step_count = _$sc;
  static const DataType weight = _$wgt;
  static const DataType distance = _$dst;
  static const DataType energy = _$en;
  static const DataType water = _$wat;

  const DataType._(String name) : super(name);

/*   static const _icon = const {
    preMeal: "assets/icons8-waiter.png",
    postMeal: "assets/icons8-meal.png",
    fasting: "assets/icons8-no_food.png",
  }; */
  static const _string = const {
    height: "height",
    blood_glucose: "blood_glucose",
    sleep: "sleep",
    heart_rate: "heart_rate",
    step_count: "step_count",
    weight: "weight",
    distance: "distance",
    energy: "energy",
    water: "water",
  };

  static const _unit = const {
    height: "meter",
    blood_glucose: "mg/dl",
    sleep: "minute",
    heart_rate: "count/min",
    step_count: "count",
    weight: "kg",
    distance: "meter",
    energy: "kcal",
    water: "liter",
  };
  String get unit =>
      _unit[this] ?? (throw StateError('No unit for DataType.$name'));
  String get string =>
      _string[this] ?? (throw StateError('No string for DataType.$name'));
  /* String get icon =>
      _icon[this] ?? (throw StateError('No icon for Status.$name')); */

  static BuiltSet<DataType> get values => _$dataVal;
  static DataType valueOf(String name) => _$dataValueOf(name);
}

/* switch (type) {
      case DataType.HEART_RATE:
        return "heart_rate";
      case DataType.STEP_COUNT:
        return "step_count";
      case DataType.HEIGHT:
        return "height";
      case DataType.WEIGHT:
        return "weight";
      case DataType.DISTANCE:
        return "distance";
      case DataType.ENERGY:
        return "energy";
      case DataType.WATER:
        return "water";
      case DataType.SLEEP:
        return "sleep";
      case DataType.BLOOD_GLUCOSE:
        return "blood_glucose";
    } */
