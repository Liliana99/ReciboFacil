import 'package:dio/dio.dart';
import 'package:recibo_facil/src/home/models/precios_api.dart';

class PriceAndHour {
  final double hourPrice;
  final String hourRange;

  PriceAndHour({required this.hourPrice, required this.hourRange});
}

class PreciosRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://flask-precios-backend.onrender.com', // URL del backend
    connectTimeout: Duration(seconds: 60), // Tiempo de espera en ms
    receiveTimeout: Duration(seconds: 60),
  ));

  // Obtener los datos desde el API
  Future<PreciosAPI> fetchPrecios() async {
    try {
      final response = await _dio.get('/api/precios');
      if (response.statusCode == 200) {
        return PreciosAPI.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red: ${e.message}');
    }
  }
}

Map<String, dynamic> obtenerPrecioMasAlto(List<PrecioHora> preciosPorHora) {
  if (preciosPorHora.isEmpty) {
    throw Exception("La lista de precios está vacía.");
  }

  // Encuentra el precio más alto
  final precioMasAlto =
      preciosPorHora.reduce((a, b) => a.precio > b.precio ? a : b);
  final index = preciosPorHora.indexOf(precioMasAlto);

  String rango;

  // Verifica si hay un rango (un precio idéntico antes o después)
  if (index < preciosPorHora.length - 1 &&
      preciosPorHora[index + 1].precio == precioMasAlto.precio) {
    rango = "${preciosPorHora[index].hora} - ${preciosPorHora[index + 1].hora}";
  } else if (index > 0 &&
      preciosPorHora[index - 1].precio == precioMasAlto.precio) {
    rango = "${preciosPorHora[index - 1].hora} - ${preciosPorHora[index].hora}";
  } else {
    rango =
        preciosPorHora[index].hora; // Si no hay rango, devuelve la hora exacta
  }

  return {
    "precio": precioMasAlto.precio,
    "rango": rango,
  };
}

Map<String, dynamic> obtenerPrecioMasBajo(List<PrecioHora> preciosPorHora) {
  if (preciosPorHora.isEmpty) {
    throw Exception("La lista de precios está vacía.");
  }

  // Encuentra el precio más bajo
  final precioMasBajo =
      preciosPorHora.reduce((a, b) => a.precio < b.precio ? a : b);
  final index = preciosPorHora.indexOf(precioMasBajo);

  String rango;

  // Verifica si hay un rango (un precio idéntico antes o después)
  if (index < preciosPorHora.length - 1 &&
      preciosPorHora[index + 1].precio == precioMasBajo.precio) {
    rango = "${preciosPorHora[index].hora} - ${preciosPorHora[index + 1].hora}";
  } else if (index > 0 &&
      preciosPorHora[index - 1].precio == precioMasBajo.precio) {
    rango = "${preciosPorHora[index - 1].hora} - ${preciosPorHora[index].hora}";
  } else {
    rango =
        preciosPorHora[index].hora; // Si no hay rango, devuelve la hora exacta
  }

  return {
    "precio": precioMasBajo.precio,
    "rango": rango,
  };
}
