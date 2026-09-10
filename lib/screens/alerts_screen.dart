import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key, required this.usuario});

  final Map<String, Object?> usuario;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _panel = Color(0xFF1B1D22);
  static const _borde = Color(0xFF2D3238);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF9A9DA3);
  static const _rojo = Color(0xFFFF3B45);
  static const _amarillo = Color(0xFFFFC400);

  String _filtro = 'Todas';
  final _alertas = const [
    _Alerta(
      titulo: 'Alerta de Seguridad - Zona 4',
      obra: 'Chancador Primario - Antofagasta',
      descripcion:
          'Pérdida crítica de presión en sistema de lubricación hidráulica de alta presión en Chancador Secundario.',
      estado: 'CRÍTICA',
      antiguedad: 'Hace 2 horas',
      color: _rojo,
      nivel: 'ALTO - CRÍTICO',
    ),
    _Alerta(
      titulo: 'Inspección Vencida - Módulo 3',
      obra: 'Planta Concentradora',
      descripcion:
          'Sistemas de andamios del módulo 3 requieren re-inspección de seguridad para continuar operaciones.',
      estado: 'PENDIENTE',
      antiguedad: 'Hace 5 horas',
      color: _amarillo,
      nivel: 'MEDIO',
    ),
    _Alerta(
      titulo: 'Fuga Contenida - Área 12',
      obra: 'Tranque de Relave',
      descripcion:
          'Fuga menor detectada y contenida exitosamente por el equipo de mantención de turno.',
      estado: 'RESUELTA',
      antiguedad: 'Ayer',
      color: _verde,
      nivel: 'BAJO',
    ),
  ];

  bool get _puedeVerAlertas {
    final rol = (widget.usuario['rol'] as String? ?? '').toLowerCase();
    return rol.contains('jefe') ||
        rol.contains('supervisor') ||
        rol.contains('administrador') ||
        rol.contains('prevencion') ||
        rol.contains('coordinador');
  }

  @override
  Widget build(BuildContext context) {
    if (!_puedeVerAlertas) return _buildSinPermiso();
    final estadoFiltro = <String, String?>{
      'Todas': null,
      'Críticas': 'CRÍTICA',
      'Pendientes': 'PENDIENTE',
      'Resueltas': 'RESUELTA',
    }[_filtro];
    final alertas = estadoFiltro == null
        ? _alertas
        : _alertas.where((alerta) => alerta.estado == estadoFiltro).toList();

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        backgroundColor: _fondo,
        elevation: 0,
        title: const Text(
          'Alertas SGI',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          if (alertas.isEmpty)
            _buildEmptyFilterState()
          else
            ...alertas.map(_buildAlertCard),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Icons.notifications_none, color: _gris, size: 42),
          const SizedBox(height: 14),
          Text(
            'No hay alertas ${_filtro.toLowerCase()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _gris, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Todas', 'Críticas', 'Pendientes', 'Resueltas']
            .map(
              (filtro) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filtro),
                  selected: _filtro == filtro,
                  onSelected: (_) => setState(() => _filtro = filtro),
                  selectedColor: _verde,
                  backgroundColor: _panel,
                  labelStyle: TextStyle(
                    color: _filtro == filtro ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  side: const BorderSide(color: _borde),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAlertCard(_Alerta alerta) {
    return InkWell(
      onTap: () => _mostrarDetalle(alerta),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: _panel,
          border: Border.all(color: _borde),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: alerta.color),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    alerta.estado,
                    style: TextStyle(color: alerta.color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(alerta.antiguedad, style: const TextStyle(color: _gris, fontSize: 11)),
                if (alerta.estado == 'CRÍTICA') ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.circle, color: _rojo, size: 8),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alerta.titulo,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(alerta.obra, style: const TextStyle(color: _verde, fontSize: 13)),
            const SizedBox(height: 7),
            Text(alerta.descripcion, style: const TextStyle(color: _gris, fontSize: 13, height: 1.18)),
          ],
        ),
      ),
    );
  }

  Widget _buildSinPermiso() {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(backgroundColor: _fondo, elevation: 0, title: const Text('Alertas SGI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: _gris, size: 44),
              const SizedBox(height: 16),
              const Text('Acceso restringido', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Tu perfil no tiene permiso para consultar las alertas SGI.', textAlign: TextAlign.center, style: TextStyle(color: _gris, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalle(_Alerta alerta) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _fondo,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(alerta.titulo, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                  _statusBadge(alerta),
                ],
              ),
              const SizedBox(height: 8),
              Text('ID: #ALT-2026-0912', style: const TextStyle(color: _gris, fontSize: 12)),
              const SizedBox(height: 18),
              _detailRow('Obra / Faena', alerta.obra),
              _detailRow('Estado', alerta.estado == 'RESUELTA' ? 'Resuelta' : 'Pendiente de Acción'),
              _detailRow('Nivel de Riesgo', alerta.nivel),
              const SizedBox(height: 18),
              const Text('Descripción del Hallazgo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(alerta.descripcion, style: const TextStyle(color: _gris, fontSize: 13, height: 1.25)),
              const SizedBox(height: 20),
              if (alerta.estado != 'RESUELTA')
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black),
                    child: const Text('Marcar como Resuelta', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(_Alerta alerta) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(border: Border.all(color: alerta.color), borderRadius: BorderRadius.circular(5)),
        child: Text(alerta.estado, style: TextStyle(color: alerta.color, fontSize: 10, fontWeight: FontWeight.bold)),
      );

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: _gris, fontSize: 13)),
            const Spacer(),
            Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
          ],
        ),
      );
}

class _Alerta {
  const _Alerta({required this.titulo, required this.obra, required this.descripcion, required this.estado, required this.antiguedad, required this.color, required this.nivel});

  final String titulo;
  final String obra;
  final String descripcion;
  final String estado;
  final String antiguedad;
  final Color color;
  final String nivel;
}
