// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state_cubit.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HomeStateCubitCWProxy {
  HomeStateCubit month(String? month);

  HomeStateCubit totalAmount(String? totalAmount);

  HomeStateCubit peak(String? peak);

  HomeStateCubit plain(String? plain);

  HomeStateCubit valley(String? valley);

  HomeStateCubit scannedText(String? scannedText);

  HomeStateCubit isScanning(bool? isScanning);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HomeStateCubit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HomeStateCubit(...).copyWith(id: 12, name: "My name")
  /// ````
  HomeStateCubit call({
    String? month,
    String? totalAmount,
    String? peak,
    String? plain,
    String? valley,
    String? scannedText,
    bool? isScanning,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHomeStateCubit.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHomeStateCubit.copyWith.fieldName(...)`
class _$HomeStateCubitCWProxyImpl implements _$HomeStateCubitCWProxy {
  const _$HomeStateCubitCWProxyImpl(this._value);

  final HomeStateCubit _value;

  @override
  HomeStateCubit month(String? month) => this(month: month);

  @override
  HomeStateCubit totalAmount(String? totalAmount) =>
      this(totalAmount: totalAmount);

  @override
  HomeStateCubit peak(String? peak) => this(peak: peak);

  @override
  HomeStateCubit plain(String? plain) => this(plain: plain);

  @override
  HomeStateCubit valley(String? valley) => this(valley: valley);

  @override
  HomeStateCubit scannedText(String? scannedText) =>
      this(scannedText: scannedText);

  @override
  HomeStateCubit isScanning(bool? isScanning) => this(isScanning: isScanning);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HomeStateCubit(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HomeStateCubit(...).copyWith(id: 12, name: "My name")
  /// ````
  HomeStateCubit call({
    Object? month = const $CopyWithPlaceholder(),
    Object? totalAmount = const $CopyWithPlaceholder(),
    Object? peak = const $CopyWithPlaceholder(),
    Object? plain = const $CopyWithPlaceholder(),
    Object? valley = const $CopyWithPlaceholder(),
    Object? scannedText = const $CopyWithPlaceholder(),
    Object? isScanning = const $CopyWithPlaceholder(),
  }) {
    return HomeStateCubit(
      month: month == const $CopyWithPlaceholder()
          ? _value.month
          // ignore: cast_nullable_to_non_nullable
          : month as String?,
      totalAmount: totalAmount == const $CopyWithPlaceholder()
          ? _value.totalAmount
          // ignore: cast_nullable_to_non_nullable
          : totalAmount as String?,
      peak: peak == const $CopyWithPlaceholder()
          ? _value.peak
          // ignore: cast_nullable_to_non_nullable
          : peak as String?,
      plain: plain == const $CopyWithPlaceholder()
          ? _value.plain
          // ignore: cast_nullable_to_non_nullable
          : plain as String?,
      valley: valley == const $CopyWithPlaceholder()
          ? _value.valley
          // ignore: cast_nullable_to_non_nullable
          : valley as String?,
      scannedText: scannedText == const $CopyWithPlaceholder()
          ? _value.scannedText
          // ignore: cast_nullable_to_non_nullable
          : scannedText as String?,
      isScanning: isScanning == const $CopyWithPlaceholder()
          ? _value.isScanning
          // ignore: cast_nullable_to_non_nullable
          : isScanning as bool?,
    );
  }
}

extension $HomeStateCubitCopyWith on HomeStateCubit {
  /// Returns a callable class that can be used as follows: `instanceOfHomeStateCubit.copyWith(...)` or like so:`instanceOfHomeStateCubit.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HomeStateCubitCWProxy get copyWith => _$HomeStateCubitCWProxyImpl(this);
}
