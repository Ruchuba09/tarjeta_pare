import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/report.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instancia = DatabaseHelper._();
  static const _nombreBaseDatos = 'tarjeta_pare.db';
  static const _versionBaseDatos = 2;

  Database? _baseDatos;

  Future<Database> get baseDatos async {
    if (_baseDatos != null) return _baseDatos!;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    final ruta = kIsWeb
        ? _nombreBaseDatos
        : join(
            (await getApplicationDocumentsDirectory()).path,
            _nombreBaseDatos,
          );
    _baseDatos = await openDatabase(
      ruta,
      version: _versionBaseDatos,
      onConfigure: (baseDatos) async {
        await baseDatos.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crearBaseDatos,
      onUpgrade: (baseDatos, versionAnterior, versionNueva) async {
        await _eliminarTablas(baseDatos);
        await _crearBaseDatos(baseDatos, versionNueva);
      },
    );
    await _crearUsuarioDemoSiEsNecesario(_baseDatos!);
    return _baseDatos!;
  }

  Future<void> _crearUsuarioDemoSiEsNecesario(Database baseDatos) async {
    final usuarios = await baseDatos.query(
      'Usuario',
      columns: ['id_usuario'],
      limit: 1,
    );
    if (usuarios.isEmpty) {
      await insertarUsuario(
        nombre: 'Carlos Mendoza',
        rut: '20.155.245-1',
        correo: 'carlos.mendoza@avamontajes.cl',
        password: '1234',
      );
    }
  }

  Future<void> _crearBaseDatos(Database baseDatos, int versionEsquema) async {
    await baseDatos.execute('''
      CREATE TABLE Cliente (
        id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_cliente VARCHAR(100) NOT NULL,
        rut_cliente VARCHAR(100) NOT NULL,
        correo VARCHAR(100) NOT NULL
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Obra (
        id_obra INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INTEGER NOT NULL,
        nombre_obra VARCHAR(100) NOT NULL,
        ubicacion VARCHAR(100) NOT NULL,
        estado VARCHAR(100) NOT NULL,
        FOREIGN KEY (id_cliente) REFERENCES Cliente (id_cliente)
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Usuario (
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(100) NOT NULL,
        rut VARCHAR(100) NOT NULL,
        correo VARCHAR(100) NOT NULL,
        password VARCHAR(100) NOT NULL,
        estado_usuario VARCHAR(100) NOT NULL
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Dimension_SGI (
        id_dimension INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_especialidad VARCHAR(100) NOT NULL,
        descripcion VARCHAR(100) NOT NULL
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Tipo_Reporte (
        id_tipo_reporte INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_tipo VARCHAR(100) NOT NULL,
        descripcion VARCHAR(100) NOT NULL,
        factor_critico VARCHAR(100) NOT NULL,
        estado VARCHAR(100) NOT NULL
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Especialidad (
        id_especialidad INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_especialidad VARCHAR(100) NOT NULL,
        descripcion VARCHAR(100) NOT NULL
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Estado_Reporte (
        id_estado_reporte INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_estado VARCHAR(100) NOT NULL
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Reporte (
        id_reporte INTEGER PRIMARY KEY AUTOINCREMENT,
        id_dimension INTEGER NOT NULL,
        id_usuario INTEGER NOT NULL,
        id_tipo_reporte INTEGER NOT NULL,
        id_especialidad INTEGER NOT NULL,
        id_estado_reporte INTEGER NOT NULL,
        id_obra INTEGER NOT NULL,
        fecha_evento VARCHAR(100) NOT NULL,
        descripcion VARCHAR(100) NOT NULL,
        origen VARCHAR(100) NOT NULL,
        fecha_registro DATETIME NOT NULL,
        FOREIGN KEY (id_dimension) REFERENCES Dimension_SGI (id_dimension),
        FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario),
        FOREIGN KEY (id_tipo_reporte) REFERENCES Tipo_Reporte (id_tipo_reporte),
        FOREIGN KEY (id_especialidad) REFERENCES Especialidad (id_especialidad),
        FOREIGN KEY (id_estado_reporte) REFERENCES Estado_Reporte (id_estado_reporte),
        FOREIGN KEY (id_obra) REFERENCES Obra (id_obra)
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Accion_Reporte (
        id_accion INTEGER PRIMARY KEY AUTOINCREMENT,
        id_reporte INTEGER NOT NULL,
        id_usuario INTEGER NOT NULL,
        tipo_accion VARCHAR(100) NOT NULL,
        fecha_accion VARCHAR(100) NOT NULL,
        observacion VARCHAR(100) NOT NULL,
        FOREIGN KEY (id_reporte) REFERENCES Reporte (id_reporte),
        FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario)
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Usuario_Obra (
        id_usuario INTEGER NOT NULL,
        id_obra INTEGER NOT NULL,
        PRIMARY KEY (id_usuario, id_obra),
        FOREIGN KEY (id_usuario) REFERENCES Usuario (id_usuario),
        FOREIGN KEY (id_obra) REFERENCES Obra (id_obra)
      )
    ''');

    // Extensiones del pre-informe para fotografías y trabajo sin conexión.
    await baseDatos.execute('''
      CREATE TABLE Evidencia (
        id_evidencia INTEGER PRIMARY KEY AUTOINCREMENT,
        id_reporte INTEGER NOT NULL,
        ruta_local VARCHAR(255) NOT NULL,
        fecha_registro DATETIME NOT NULL,
        FOREIGN KEY (id_reporte) REFERENCES Reporte (id_reporte)
      )
    ''');
    await baseDatos.execute('''
      CREATE TABLE Cola_Sincronizacion (
        id_cola INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_tabla VARCHAR(100) NOT NULL,
        id_registro INTEGER NOT NULL,
        operacion VARCHAR(100) NOT NULL,
        fecha_registro DATETIME NOT NULL,
        intentos INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _eliminarTablas(Database baseDatos) async {
    for (final nombreTabla in [
      'Cola_Sincronizacion',
      'Evidencia',
      'Usuario_Obra',
      'Accion_Reporte',
      'Reporte',
      'Estado_Reporte',
      'Especialidad',
      'Tipo_Reporte',
      'Dimension_SGI',
      'Usuario',
      'Obra',
      'Cliente',
      'sync_queue',
      'evidences',
      'reports',
      'users',
    ]) {
      await baseDatos.execute('DROP TABLE IF EXISTS $nombreTabla');
    }
  }

  Future<int> insertarReporte(Reporte reporte) async {
    final baseDatos = await this.baseDatos;
    final mapa = reporte.toMap()..remove('id_reporte');
    return baseDatos.insert('Reporte', mapa);
  }

  Future<Map<String, Object?>?> autenticarUsuario({
    required String rut,
    required String password,
  }) async {
    if (kIsWeb) {
      final rutNormalizado = rut
          .replaceAll(RegExp(r'[^0-9Kk]'), '')
          .toUpperCase();
      if (rutNormalizado == '201552451' && password == '1234') {
        return {
          'id_usuario': 1,
          'nombre': 'Carlos Mendoza',
          'rut': '20.155.245-1',
          'correo': 'carlos.mendoza@avamontajes.cl',
          'estado_usuario': 'activo',
        };
      }
      return null;
    }
    final baseDatos = await this.baseDatos;
    final usuarios = await baseDatos.query(
      'Usuario',
      columns: ['id_usuario', 'nombre', 'rut', 'correo', 'estado_usuario'],
      where: 'rut = ? AND password = ? AND estado_usuario = ?',
      whereArgs: [rut.trim(), password, 'activo'],
      limit: 1,
    );

    return usuarios.isEmpty ? null : usuarios.first;
  }

  Future<int> insertarUsuario({
    required String nombre,
    required String rut,
    required String correo,
    required String password,
    String estado = 'activo',
  }) async {
    final baseDatos = await this.baseDatos;
    return baseDatos.insert('Usuario', {
      'nombre': nombre,
      'rut': rut.trim(),
      'correo': correo.trim(),
      'password': password,
      'estado_usuario': estado,
    });
  }

  Future<List<Reporte>> obtenerReportes() async {
    final baseDatos = await this.baseDatos;
    final filas = await baseDatos.query(
      'Reporte',
      orderBy: 'fecha_evento DESC',
    );
    return filas.map(Reporte.fromMap).toList();
  }

  Future<Map<String, Object>> obtenerResumenDashboard() async {
    if (kIsWeb) {
      return {
        'reportesHoy': 0,
        'alertasActivas': 0,
        'evidenciasPendientes': 0,
        'riesgoPromedio': 'N/D',
      };
    }
    final baseDatos = await this.baseDatos;
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final reportesHoy = await baseDatos.rawQuery(
      'SELECT COUNT(*) AS total FROM Reporte WHERE fecha_evento LIKE ?',
      ['$hoy%'],
    );
    final alertasActivas = await baseDatos.rawQuery('''
      SELECT COUNT(*) AS total
      FROM Reporte r
      INNER JOIN Estado_Reporte e ON e.id_estado_reporte = r.id_estado_reporte
      WHERE LOWER(e.nombre_estado) NOT IN ('cerrado', 'completado', 'finalizado')
    ''');
    final evidenciasPendientes = await baseDatos.rawQuery('''
      SELECT COUNT(*) AS total
      FROM Cola_Sincronizacion
      WHERE nombre_tabla = 'Evidencia' AND operacion IN ('insertar', 'crear', 'actualizar')
    ''');

    return {
      'reportesHoy': Sqflite.firstIntValue(reportesHoy) ?? 0,
      'alertasActivas': Sqflite.firstIntValue(alertasActivas) ?? 0,
      'evidenciasPendientes': Sqflite.firstIntValue(evidenciasPendientes) ?? 0,
      'riesgoPromedio': 'N/D',
    };
  }

  Future<int> insertarEvidencia(Evidencia evidencia) async {
    final baseDatos = await this.baseDatos;
    final mapa = evidencia.toMap()..remove('id_evidencia');
    return baseDatos.insert('Evidencia', mapa);
  }

  Future<void> cerrar() async {
    await _baseDatos?.close();
    _baseDatos = null;
  }
}
