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
  final bool? isFromPdf;
  final bool? isFromCamera;
  final String? errorMessage;
  final String? company;
  final String? billNumber;
  final String? cups;
  final String? contract;
  final File? file;
  final int? pageNumber;
  final bool? isImageVisible;
  final bool? isLoading;
  final bool? isComplete;
  final String? isError;
  final String? valleyString;
  final String? peakString;
  final String? contractType;
  final String? qrcode;
  final bool? hasNavigated;

  const HomeStateCubit({
    this.month,
    this.totalAmount,
    this.peak,
    this.plain,
    this.valley,
    this.scannedText,
    this.isScanning = false,
    this.errorMessage = '',
    this.progressMessage,
    this.isFromPdf = false,
    this.isFromCamera = false,
    this.company,
    this.billNumber,
    this.cups,
    this.contract,
    this.file,
    this.pageNumber,
    this.isImageVisible = false,
    this.isLoading = false,
    this.isComplete = false,
    this.isError = '',
    this.valleyString,
    this.peakString,
    this.contractType,
    this.qrcode,
    this.hasNavigated = false,
  });

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
        isFromPdf,
        isFromCamera,
        company,
        billNumber,
        cups,
        contract,
        file,
        pageNumber,
        isImageVisible,
        isLoading,
        isComplete,
        isError,
        valleyString,
        peakString,
        contractType,
        qrcode,
        hasNavigated,
      ];
}
