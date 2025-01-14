int calculateDaysBetween(String startDateStr, String endDateStr) {
  // Convertir las fechas de formato DD/MM/YYYY a YYYY-MM-DD.
  DateTime parseDate(String dateStr) {
    List<String> parts = dateStr.split('/');
    if (parts.length != 3) {
      throw FormatException('Invalid date format', dateStr);
    }
    return DateTime(
        int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  // Parsear las fechas usando el método convertido.
  DateTime startDate = parseDate(startDateStr.trim());
  DateTime endDate = parseDate(endDateStr.trim());

  // Asegurarse de que las fechas no incluyan tiempo para cálculos precisos.
  DateTime start = DateTime(startDate.year, startDate.month, startDate.day);
  DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

  // Restar las fechas y calcular la diferencia en días.
  return end.difference(start).inDays;
}
