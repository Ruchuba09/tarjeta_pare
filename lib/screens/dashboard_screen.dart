import 'package:flutter/material.dart';

import '../data/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.usuario});

  final Map<String, Object?> usuario;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _panel = Color(0xFF15191C);
  static const _borde = Color(0xFF2D3238);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF7A7F85);
  static const _rojo = Color(0xFFF80000);
  static const _amarillo = Color(0xFFFFCB00);

  Map<String, Object>? _resumen;
  bool _cargando = true;
  int _indiceSeleccionado = 0;

  String get _nombreUsuario =>
      (widget.usuario['nombre'] as String?)?.trim().isNotEmpty == true
      ? widget.usuario['nombre'] as String
      : 'Usuario SGI';

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    try {
      final resumen = await DatabaseHelper.instancia.obtenerResumenDashboard();
      if (mounted) setState(() => _resumen = resumen);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: _verde,
                    backgroundColor: _panel,
                    onRefresh: _cargarResumen,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(23, 26, 23, 24),
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 27),
                        _buildNewReportButton(),
                        const SizedBox(height: 19),
                        _buildQuickActions(),
                        const SizedBox(height: 21),
                        _buildSummary(),
                        const SizedBox(height: 19),
                        _buildSyncStatus(),
                      ],
                    ),
                  ),
                ),
                _buildNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final partes = _nombreUsuario.split(RegExp(r'\s+'));
    final nombreCorto = partes.length > 1
        ? '${partes.first} ${partes[1]}'
        : partes.first;
    final iniciales = partes
        .take(2)
        .map((parte) => parte.substring(0, 1).toUpperCase())
        .join();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buenas tardes,',
                style: TextStyle(color: _gris, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                nombreCorto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Analista SGI • Faena Antofagasta',
                style: TextStyle(color: _verde, fontSize: 12),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: _panel,
          child: Text(
            iniciales,
            style: const TextStyle(color: _verde, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildNewReportButton() {
    return SizedBox(
      height: 109,
      child: ElevatedButton(
        onPressed: _crearReporte,
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.fromLTRB(18, 0, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NUEVO REPORTE DE TERRENO',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Reporta de forma inmediata incidentes, Tarjetas Pare, observaciones preventivas o no conformidades.',
                    style: TextStyle(fontSize: 12, height: 1.25),
                  ),
                ],
              ),
            ),
            Container(
              width: 31,
              height: 31,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final evidencias = _resumen?['evidenciasPendientes'] ?? 0;
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            Icons.description_outlined,
            'Mis Reportes',
            'Ver historial y estados',
            _verde,
            _verReportes,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            Icons.camera_alt_outlined,
            'Evidencias',
            _cargando ? 'Cargando...' : '$evidencias pendientes por enviar',
            _amarillo,
            _verEvidencias,
          ),
        ),
      ],
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 91,
        padding: const EdgeInsets.fromLTRB(13, 12, 10, 10),
        decoration: BoxDecoration(
          color: _panel,
          border: Border.all(color: _borde),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 21),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: _gris, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final reportes = _resumen?['reportesHoy'] ?? 0;
    final alertas = _resumen?['alertasActivas'] ?? 0;
    final riesgo = _resumen?['riesgoPromedio'] ?? 'N/D';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RESUMEN OPERACIONAL',
          style: TextStyle(
            color: _gris,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metric(
                'REPORTES HOY',
                _cargando ? '...' : '$reportes',
                Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                'ALERTAS ACTIVAS',
                _cargando ? '...' : '$alertas',
                _rojo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metric(
                'RIESGO PROM.',
                _cargando ? '...' : '$riesgo',
                _amarillo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metric(String label, String value, Color valueColor) {
    return Container(
      height: 61,
      padding: const EdgeInsets.fromLTRB(11, 10, 8, 7),
      decoration: BoxDecoration(
        color: const Color(0xFF191E22),
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _gris, fontSize: 9)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF111811),
        border: Border.all(color: const Color(0xFF385D16)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Row(
        children: [
          Icon(Icons.circle, color: _verde, size: 7),
          SizedBox(width: 10),
          Text(
            'Dispositivo sincronizado con SQLite',
            style: TextStyle(color: _gris, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    const labels = ['Inicio', 'Reportes', 'Alertas', 'Perfil'];
    const icons = [
      Icons.home_outlined,
      Icons.description_outlined,
      Icons.notifications_none,
      Icons.person_outline,
    ];
    return Container(
      height: 69,
      decoration: const BoxDecoration(
        color: Color(0xFF12171A),
        border: Border(top: BorderSide(color: _borde)),
      ),
      child: Row(
        children: List.generate(
          labels.length,
          (index) => Expanded(
            child: InkWell(
              onTap: () => setState(() => _indiceSeleccionado = index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    color: _indiceSeleccionado == index ? _verde : _gris,
                    size: 21,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: _indiceSeleccionado == index ? _verde : _gris,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _crearReporte() => _mostrarMensaje(
    'El formulario de reportes se conectará a SQLite en el siguiente módulo.',
  );
  void _verReportes() =>
      _mostrarMensaje('Los reportes se cargarán desde SQLite.');
  void _verEvidencias() =>
      _mostrarMensaje('Las evidencias se cargarán desde SQLite.');
  void _mostrarMensaje(String mensaje) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
}
