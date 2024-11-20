import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'home_state_cubit.g.dart';

@CopyWith()
class HomeStateCubit extends Equatable {
  final String? month;
  final String? totalAmount;
  final String? peak;
  final String? plain;
  final String? valley;
  final String? scannedText;
  final bool? isScanning;

  const HomeStateCubit(
      {this.month,
      this.totalAmount,
      this.peak,
      this.plain,
      this.valley,
      this.scannedText,
      this.isScanning = false});

  @override
  List<Object?> get props => [
        month,
        totalAmount,
        peak,
        plain,
        valley,
        scannedText,
        isScanning,
      ];
}
