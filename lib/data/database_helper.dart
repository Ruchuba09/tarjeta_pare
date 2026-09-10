import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/report.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instancia = DatabaseHelper._();
  static const _nombreBaseDatos = 'tarjeta_pare.db';
  static const _versionBaseDatos = 3;

  Database? _baseDatos;

  Future<Database> get baseDatos async {
    if (_baseDatos != null) return _baseDatos!;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final directorioBaseDatos = kIsWeb ? '' : await getDatabasesPath();
    final ruta = kIsWeb
        ? _nombreBaseDatos
        : join(directorioBaseDatos, _nombreBaseDatos);

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
    await _crearDatosDemoSiEsNecesario(_baseDatos!);
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
        rol: 'jefe_obra',
      );
    }
  }

  Future<void> _crearDatosDemoSiEsNecesario(Database baseDatos) async {
    final reportes = await baseDatos.query('Reporte', columns: ['id_reporte'], limit: 1);
    if (reportes.isNotEmpty) return;

    await baseDatos.transaction((transaccion) async {
      final clienteId = await transaccion.insert('Cliente', {
        'nombre_cliente': 'AVA Montajes S.A.',
        'rut_cliente': '76.543.210-8',
        'correo': 'operaciones@avamontajes.cl',
      });

      final obras = <int>[];
      for (final obra in [
        ['Antofagasta Fase 2', 'Antofagasta', 'activa'],
        ['Planta Concentradora', 'Calama', 'activa'],
        ['Chancador Primario', 'Antofagasta', 'activa'],
        ['Tranque de Relave', 'Sierra Gorda', 'activa'],
        ['Ampliación Taller', 'Mejillones', 'cerrada'],
      ]) {
        obras.add(await transaccion.insert('Obra', {
          'id_cliente': clienteId,
          'nombre_obra': obra[0],
          'ubicacion': obra[1],
          'estado': obra[2],
        }));
      }

      final usuario = await transaccion.query(
        'Usuario',
        columns: ['id_usuario'],
        where: 'rut = ?',
        whereArgs: ['20.155.245-1'],
        limit: 1,
      );
      final usuarioId = usuario.first['id_usuario'] as int;

      for (final obraId in obras) {
        await transaccion.insert('Usuario_Obra', {
          'id_usuario': usuarioId,
          'id_obra': obraId,
        });
      }

      final dimensiones = <int>[];
      for (final dimension in [
        ['Seguridad', 'Control de riesgos operacionales'],
        ['Calidad', 'Inspección y cumplimiento de estándares'],
        ['Medio Ambiente', 'Control de impactos ambientales'],
        ['Salud Ocupacional', 'Condiciones de salud y bienestar'],
      ]) {
        dimensiones.add(await transaccion.insert('Dimension_SGI', {
          'nombre_especialidad': dimension[0],
          'descripcion': dimension[1],
        }));
      }

      final tipos = <int>[];
      for (final tipo in [
        ['Tarjeta Pare', 'Detención preventiva de una actividad', 'alto'],
        ['Observación Preventiva', 'Registro de condición o conducta', 'medio'],
        ['No Conformidad', 'Incumplimiento de requisito SGI', 'alto'],
        ['Reporte Flash', 'Aviso operacional rápido', 'crítico'],
      ]) {
        tipos.add(await transaccion.insert('Tipo_Reporte', {
          'nombre_tipo': tipo[0],
          'descripcion': tipo[1],
          'factor_critico': tipo[2],
          'estado': 'activo',
        }));
      }

      final especialidades = <int>[];
      for (final especialidad in [
        ['Mecánica', 'Equipos y componentes mecánicos'],
        ['Estructuras', 'Andamios, plataformas y soportes'],
        ['Eléctrica', 'Instalaciones y equipos eléctricos'],
        ['Operaciones', 'Procedimientos y continuidad operacional'],
      ]) {
        especialidades.add(await transaccion.insert('Especialidad', {
          'nombre_especialidad': especialidad[0],
          'descripcion': especialidad[1],
        }));
      }

      final estados = <int>[];
      for (final estado in ['Abierto', 'En proceso', 'Cerrado', 'Pendiente']) {
        estados.add(await transaccion.insert('Estado_Reporte', {
          'nombre_estado': estado,
        }));
      }

      final descripciones = [
        'Se detecta condición insegura en área de trabajo.',
        'Inspección preventiva requiere seguimiento del supervisor.',
        'Equipo presenta desgaste visible en componente principal.',
        'Se detiene la actividad hasta controlar el riesgo identificado.',
        'Falta señalización preventiva en acceso de operación.',
        'Personal requiere refuerzo de procedimiento operacional.',
        'Herramienta sin inspección vigente en frente de trabajo.',
        'Orden y aseo deficiente alrededor del equipo.',
      ];
      final ahora = DateTime.now();

      for (var indice = 0; indice < 120; indice++) {
        final fecha = ahora.subtract(Duration(
          days: indice % 90,
          hours: (indice * 3) % 24,
          minutes: (indice * 7) % 60,
        ));
        final reporteId = await transaccion.insert('Reporte', {
          'id_dimension': dimensiones[indice % dimensiones.length],
          'id_usuario': usuarioId,
          'id_tipo_reporte': tipos[indice % tipos.length],
          'id_especialidad': especialidades[indice % especialidades.length],
          'id_estado_reporte': estados[indice % estados.length],
          'id_obra': obras[indice % obras.length],
          'fecha_evento': fecha.toIso8601String(),
          'descripcion': descripciones[indice % descripciones.length],
          'origen': indice.isEven ? 'QR' : 'Manual',
          'fecha_registro': fecha.add(const Duration(minutes: 12)).toIso8601String(),
        });

        if (indice % 3 == 0) {
          await transaccion.insert('Accion_Reporte', {
            'id_reporte': reporteId,
            'id_usuario': usuarioId,
            'tipo_accion': 'Seguimiento',
            'fecha_accion': fecha.add(const Duration(hours: 2)).toIso8601String(),
            'observacion': 'Revisión asignada al supervisor de turno.',
          });
        }
        if (indice % 5 == 0) {
          await transaccion.insert('Evidencia', {
            'id_reporte': reporteId,
            'ruta_local': 'demo/evidencia_$indice.jpg',
            'fecha_registro': fecha.add(const Duration(minutes: 20)).toIso8601String(),
          });
        }
      }
    });
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
        rol VARCHAR(40) NOT NULL DEFAULT 'obrero',
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
          'rol': 'jefe_obra',
          'estado_usuario': 'activo',
        };
      }
      return null;
    }
    final baseDatos = await this.baseDatos;
    final usuarios = await baseDatos.query(
      'Usuario',
      columns: ['id_usuario', 'nombre', 'rut', 'correo', 'rol', 'estado_usuario'],
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
    String rol = 'obrero',
    String estado = 'activo',
  }) async {
    final baseDatos = await this.baseDatos;
    return baseDatos.insert('Usuario', {
      'nombre': nombre,
      'rut': rut.trim(),
      'correo': correo.trim(),
      'password': password,
      'rol': rol,
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
