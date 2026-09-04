class Cliente {
  const Cliente({
    this.idCliente,
    required this.nombreCliente,
    required this.rutCliente,
    required this.correo,
  });

  final int? idCliente;
  final String nombreCliente;
  final String rutCliente;
  final String correo;

  Map<String, Object?> toMap() => {
        'id_cliente': idCliente,
        'nombre_cliente': nombreCliente,
        'rut_cliente': rutCliente,
        'correo': correo,
      };

  factory Cliente.fromMap(Map<String, Object?> mapa) => Cliente(
        idCliente: mapa['id_cliente'] as int?,
        nombreCliente: mapa['nombre_cliente'] as String,
        rutCliente: mapa['rut_cliente'] as String,
        correo: mapa['correo'] as String,
      );
}

class Obra {
  const Obra({
    this.idObra,
    required this.idCliente,
    required this.nombreObra,
    required this.ubicacion,
    required this.estado,
  });

  final int? idObra;
  final int idCliente;
  final String nombreObra;
  final String ubicacion;
  final String estado;

  Map<String, Object?> toMap() => {
        'id_obra': idObra,
        'id_cliente': idCliente,
        'nombre_obra': nombreObra,
        'ubicacion': ubicacion,
        'estado': estado,
      };

  factory Obra.fromMap(Map<String, Object?> mapa) => Obra(
        idObra: mapa['id_obra'] as int?,
        idCliente: mapa['id_cliente'] as int,
        nombreObra: mapa['nombre_obra'] as String,
        ubicacion: mapa['ubicacion'] as String,
        estado: mapa['estado'] as String,
      );
}

class Usuario {
  const Usuario({
    this.idUsuario,
    required this.nombre,
    required this.rut,
    required this.correo,
    required this.password,
    required this.estadoUsuario,
  });

  final int? idUsuario;
  final String nombre;
  final String rut;
  final String correo;
  final String password;
  final String estadoUsuario;

  Map<String, Object?> toMap() => {
        'id_usuario': idUsuario,
        'nombre': nombre,
        'rut': rut,
        'correo': correo,
        'password': password,
        'estado_usuario': estadoUsuario,
      };

  factory Usuario.fromMap(Map<String, Object?> mapa) => Usuario(
        idUsuario: mapa['id_usuario'] as int?,
        nombre: mapa['nombre'] as String,
        rut: mapa['rut'] as String,
        correo: mapa['correo'] as String,
        password: mapa['password'] as String,
        estadoUsuario: mapa['estado_usuario'] as String,
      );
}

class Reporte {
  const Reporte({
    this.idReporte,
    required this.idDimension,
    required this.idUsuario,
    required this.idTipoReporte,
    required this.idEspecialidad,
    required this.idEstadoReporte,
    required this.idObra,
    required this.fechaEvento,
    required this.descripcion,
    required this.origen,
    required this.fechaRegistro,
  });

  final int? idReporte;
  final int idDimension;
  final int idUsuario;
  final int idTipoReporte;
  final int idEspecialidad;
  final int idEstadoReporte;
  final int idObra;
  final DateTime fechaEvento;
  final String descripcion;
  final String origen;
  final DateTime fechaRegistro;

  Map<String, Object?> toMap() => {
        'id_reporte': idReporte,
        'id_dimension': idDimension,
        'id_usuario': idUsuario,
        'id_tipo_reporte': idTipoReporte,
        'id_especialidad': idEspecialidad,
        'id_estado_reporte': idEstadoReporte,
        'id_obra': idObra,
        'fecha_evento': fechaEvento.toIso8601String(),
        'descripcion': descripcion,
        'origen': origen,
        'fecha_registro': fechaRegistro.toIso8601String(),
      };

  factory Reporte.fromMap(Map<String, Object?> mapa) => Reporte(
        idReporte: mapa['id_reporte'] as int?,
        idDimension: mapa['id_dimension'] as int,
        idUsuario: mapa['id_usuario'] as int,
        idTipoReporte: mapa['id_tipo_reporte'] as int,
        idEspecialidad: mapa['id_especialidad'] as int,
        idEstadoReporte: mapa['id_estado_reporte'] as int,
        idObra: mapa['id_obra'] as int,
        fechaEvento: DateTime.parse(mapa['fecha_evento'] as String),
        descripcion: mapa['descripcion'] as String,
        origen: mapa['origen'] as String,
        fechaRegistro: DateTime.parse(mapa['fecha_registro'] as String),
      );
}

class AccionReporte {
  const AccionReporte({
    this.idAccion,
    required this.idReporte,
    required this.idUsuario,
    required this.tipoAccion,
    required this.fechaAccion,
    required this.observacion,
  });

  final int? idAccion;
  final int idReporte;
  final int idUsuario;
  final String tipoAccion;
  final DateTime fechaAccion;
  final String observacion;

  Map<String, Object?> toMap() => {
        'id_accion': idAccion,
        'id_reporte': idReporte,
        'id_usuario': idUsuario,
        'tipo_accion': tipoAccion,
        'fecha_accion': fechaAccion.toIso8601String(),
        'observacion': observacion,
      };
}

class Evidencia {
  const Evidencia({
    this.idEvidencia,
    required this.idReporte,
    required this.rutaLocal,
    required this.fechaRegistro,
  });

  final int? idEvidencia;
  final int idReporte;
  final String rutaLocal;
  final DateTime fechaRegistro;

  Map<String, Object?> toMap() => {
        'id_evidencia': idEvidencia,
        'id_reporte': idReporte,
        'ruta_local': rutaLocal,
        'fecha_registro': fechaRegistro.toIso8601String(),
      };
}
