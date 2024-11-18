String getSegmentKey(String segmentName) {
  // Mapa que relaciona los nombres del segmento con sus claves
  final segmentToKey = {
    "Horas Valle": "valle",
    "Horas Llano": "llano",
    "Horas Punta": "punta",
  };

  return segmentToKey[segmentName] ?? "default";
}
