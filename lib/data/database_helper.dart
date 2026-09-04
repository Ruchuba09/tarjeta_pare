import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/report.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instancia = DatabaseHelper._();
  static const _nombreBaseDatos = 'tarjeta_pare.db';
  static const _versionBaseDatos = 2;

  Database? _baseDatos;

  Future<Database> get baseDatos async {
    if (_baseDatos != null) return _baseDatos!;
    final directorio = await getApplicationDocumentsDirectory();
    final ruta = join(directorio.path, _nombreBaseDatos);
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
    return _baseDatos!;
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

  Future<List<Reporte>> obtenerReportes() async {
    final baseDatos = await this.baseDatos;
    final filas = await baseDatos.query('Reporte', orderBy: 'fecha_evento DESC');
    return filas.map(Reporte.fromMap).toList();
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
