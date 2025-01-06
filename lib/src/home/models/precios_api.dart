// Clase para un precio por hora
class PrecioHora {
  final String franja;
  final String hora;
  final double precio;

  PrecioHora({
    required this.franja,
    required this.hora,
    required this.precio,
  });

  // Deserializar JSON
  factory PrecioHora.fromJson(Map<String, dynamic> json) {
    return PrecioHora(
      franja: json['franja'],
      hora: json['hora'],
      precio: json['precio'],
    );
  }
}

// Clase para el resumen de precios
class ResumenPrecios {
  final double precioMaximo;
  final double precioMedio;
  final double precioMinimo;

  ResumenPrecios({
    required this.precioMaximo,
    required this.precioMedio,
    required this.precioMinimo,
  });

  // Deserializar JSON
  factory ResumenPrecios.fromJson(Map<String, dynamic> json) {
    return ResumenPrecios(
      precioMaximo: json['precio_maximo'],
      precioMedio: json['precio_medio'],
      precioMinimo: json['precio_minimo'],
    );
  }
}

// Clase principal que combina todo
class PreciosAPI {
  final List<PrecioHora> preciosPorHora;
  final ResumenPrecios resumenPrecios;

  PreciosAPI({
    required this.preciosPorHora,
    required this.resumenPrecios,
  });

  // Deserializar JSON
  factory PreciosAPI.fromJson(Map<String, dynamic> json) {
    return PreciosAPI(
      preciosPorHora: (json['precios_por_hora'] as List)
          .map((item) => PrecioHora.fromJson(item))
          .toList(),
      resumenPrecios: ResumenPrecios.fromJson(json['resumen_precios']),
    );
  }
}
