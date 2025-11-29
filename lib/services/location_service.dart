import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<bool> verificarPermisos() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return false;
    }

    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return false;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> obtenerUbicacionActual() async {
    try {
      bool tienePermiso = await verificarPermisos();
      if (!tienePermiso) {
        return null;
      }

      Position posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return posicion;
    } catch (e) {
      return null;
    }
  }

  Future<String> obtenerDireccion(double latitud, double longitud) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitud,
        longitud,
      );

      if (placemarks.isNotEmpty) {
        Placemark lugar = placemarks.first;
        String direccion = '';

        if (lugar.street != null && lugar.street!.isNotEmpty) {
          direccion += lugar.street!;
        }
        if (lugar.subLocality != null && lugar.subLocality!.isNotEmpty) {
          direccion += ', ${lugar.subLocality}';
        }
        if (lugar.locality != null && lugar.locality!.isNotEmpty) {
          direccion += ', ${lugar.locality}';
        }

        return direccion.isNotEmpty ? direccion : 'Ubicación desconocida';
      }

      return 'Ubicación desconocida';
    } catch (e) {
      return 'Lat: $latitud, Lng: $longitud';
    }
  }
}