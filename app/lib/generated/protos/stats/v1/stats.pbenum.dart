// This is a generated file - do not edit.
//
// Generated from api/stats/v1/stats.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// StatsRange — aggregation window.
class StatsRange extends $pb.ProtobufEnum {
  /// Unspecified range; used as the zero value.
  static const StatsRange STATS_RANGE_UNSPECIFIED =
      StatsRange._(0, _omitEnumNames ? '' : 'STATS_RANGE_UNSPECIFIED');

  /// Aggregate per day.
  static const StatsRange STATS_RANGE_DAY =
      StatsRange._(1, _omitEnumNames ? '' : 'STATS_RANGE_DAY');

  /// Aggregate per week.
  static const StatsRange STATS_RANGE_WEEK =
      StatsRange._(2, _omitEnumNames ? '' : 'STATS_RANGE_WEEK');

  /// Aggregate per month.
  static const StatsRange STATS_RANGE_MONTH =
      StatsRange._(3, _omitEnumNames ? '' : 'STATS_RANGE_MONTH');

  /// No aggregation — all-time totals.
  static const StatsRange STATS_RANGE_ALL =
      StatsRange._(4, _omitEnumNames ? '' : 'STATS_RANGE_ALL');

  static const $core.List<StatsRange> values = <StatsRange>[
    STATS_RANGE_UNSPECIFIED,
    STATS_RANGE_DAY,
    STATS_RANGE_WEEK,
    STATS_RANGE_MONTH,
    STATS_RANGE_ALL,
  ];

  static final $core.List<StatsRange?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static StatsRange? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StatsRange._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
