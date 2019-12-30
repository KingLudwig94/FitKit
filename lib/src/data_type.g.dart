// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DataType _$hgt = const DataType._('height');
const DataType _$bg = const DataType._('blood_glucose');
const DataType _$sl = const DataType._('sleep');
const DataType _$hr = const DataType._('heart_rate');
const DataType _$sc = const DataType._('step_count');
const DataType _$wgt = const DataType._('weight');
const DataType _$dst = const DataType._('distance');
const DataType _$en = const DataType._('energy');
const DataType _$wat = const DataType._('water');

DataType _$dataValueOf(String name) {
  switch (name) {
    case 'height':
      return _$hgt;
    case 'blood_glucose':
      return _$bg;
    case 'sleep':
      return _$sl;
    case 'heart_rate':
      return _$hr;
    case 'step_count':
      return _$sc;
    case 'weight':
      return _$wgt;
    case 'distance':
      return _$dst;
    case 'energy':
      return _$en;
    case 'water':
      return _$wat;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<DataType> _$dataVal = new BuiltSet<DataType>(const <DataType>[
  _$hgt,
  _$bg,
  _$sl,
  _$hr,
  _$sc,
  _$wgt,
  _$dst,
  _$en,
  _$wat,
]);

Serializer<DataType> _$dataTypeSerializer = new _$DataTypeSerializer();

class _$DataTypeSerializer implements PrimitiveSerializer<DataType> {
  @override
  final Iterable<Type> types = const <Type>[DataType];
  @override
  final String wireName = 'DataType';

  @override
  Object serialize(Serializers serializers, DataType object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  DataType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DataType.valueOf(serialized as String);
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
