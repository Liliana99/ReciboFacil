double parseCurrency(String currencyStr) {
  // Eliminar caracteres no numéricos excepto coma y punto.
  String cleanedStr = currencyStr.replaceAll(RegExp(r'[^\d,.-]'), '');

  // Reemplazar coma con punto para que Dart pueda interpretarlo como un número.
  cleanedStr = cleanedStr.replaceAll(',', '.');

  // Convertir a double.
  return double.parse(cleanedStr);
}
