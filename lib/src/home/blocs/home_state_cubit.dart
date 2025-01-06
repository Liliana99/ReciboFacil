import 'dart:io';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

part 'home_state_cubit.g.dart';

@CopyWith()
class HomeStateCubit extends Equatable {
  final String? month;
  final String? totalAmount;
  final Decimal? peak;
  final Decimal? plain;
  final Decimal? valley;
  final String? scannedText;
  final String? progressMessage;
  final bool? isScanning;
  final bool? isFromGallery;
  final bool? isFromCamera;
  final String? errorMessage;
  final String? company;
  final String? billNumber;
  final String? cups;
  final String? contract;
  final File? file;

  const HomeStateCubit(
      {this.month,
      this.totalAmount,
      this.peak,
      this.plain,
      this.valley,
      this.scannedText,
      this.isScanning = false,
      this.errorMessage = '',
      this.progressMessage,
      this.isFromGallery = false,
      this.isFromCamera = false,
      this.company,
      this.billNumber,
      this.cups,
      this.contract,
      this.file});

  @override
  List<Object?> get props => [
        month,
        totalAmount,
        peak,
        plain,
        valley,
        scannedText,
        isScanning,
        errorMessage,
        progressMessage,
        isFromGallery,
        isFromCamera,
        company,
        billNumber,
        cups,
        contract,
        file
      ];
}
