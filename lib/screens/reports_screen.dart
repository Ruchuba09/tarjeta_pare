import 'package:flutter/material.dart';

import '../data/database_helper.dart';
import '../models/report.dart';
import 'report_selection_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.usuario});

  final Map<String, Object?> usuario;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _panel = Color(0xFF15191C);
  static const _borde = Color(0xFF2D3238);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF7A7F85);
  static const _amarillo = Color(0xFFFFCB00);

  final _busquedaController = TextEditingController();
  String _filtro = 'Todos';
  late Future<List<Reporte>> _reportesFuture;

  @override
  void initState() {
    super.initState();
    _reportesFuture = DatabaseHelper.instancia.obtenerReportes();
    _busquedaController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    setState(() {
      _reportesFuture = DatabaseHelper.instancia.obtenerReportes();
    });
    await _reportesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        backgroundColor: _fondo,
        elevation: 0,
        title: const Text(
          'Mis Reportes SGI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _verde,
          backgroundColor: _panel,
          onRefresh: _recargar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              _buildSearchField(),
              const SizedBox(height: 12),
              _buildFilters(),
              const SizedBox(height: 20),
              FutureBuilder<List<Reporte>>(
                future: _reportesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(
                        child: CircularProgressIndicator(color: _verde),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildMessage(
                      'No se pudieron cargar los reportes.',
                      Icons.cloud_off_outlined,
                    );
                  }

                  final reportes = _filtrar(snapshot.data ?? const []);
                  return reportes.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.sync, color: _verde, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  '${reportes.length} reporte${reportes.length == 1 ? '' : 's'} encontrado${reportes.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    color: _gris,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...reportes.map(_buildReportCard),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearReporte,
        backgroundColor: _verde,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _busquedaController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar por obra, ID o descripción...',
        hintStyle: const TextStyle(color: _gris, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: _gris),
        suffixIcon: _busquedaController.text.isEmpty
            ? null
            : IconButton(
                onPressed: _busquedaController.clear,
                icon: const Icon(Icons.close, color: _gris),
              ),
        filled: true,
        fillColor: _panel,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _verde),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Todos', 'Abiertos', 'En proceso', 'Cerrados']
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
                    color: _filtro == filtro ? Colors.black : _gris,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  side: const BorderSide(color: _borde),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  List<Reporte> _filtrar(List<Reporte> reportes) {
    final texto = _busquedaController.text.trim().toLowerCase();
    return reportes.where((reporte) {
      final coincideTexto = texto.isEmpty ||
          '${reporte.idReporte} ${reporte.descripcion} ${reporte.idObra}'
              .toLowerCase()
              .contains(texto);
      final coincideFiltro = switch (_filtro) {
        'Todos' => true,
        'Abiertos' => reporte.idEstadoReporte == 1,
        'En proceso' => reporte.idEstadoReporte == 2,
        'Cerrados' => reporte.idEstadoReporte == 3,
        _ => true,
      };
      return coincideTexto && coincideFiltro;
    }).toList();
  }

  Widget _buildReportCard(Reporte reporte) {
    final estado = _nombreEstado(reporte.idEstadoReporte);
    final colorEstado = estado == 'Cerrado' ? _verde : _amarillo;
    final fecha = _formatearFecha(reporte.fechaEvento);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: _panel,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: _amarillo),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Tarjeta Pare',
                  style: TextStyle(color: _amarillo, fontSize: 10),
                ),
              ),
              Text(fecha, style: const TextStyle(color: _gris, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '#RPT-${(reporte.idReporte ?? 0).toString().padLeft(4, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reporte.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _gris, fontSize: 12),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF252B30), height: 1),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(Icons.circle, color: colorEstado, size: 8),
              const SizedBox(width: 6),
              Text(
                estado,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              Text(
                'Obra ${reporte.idObra}',
                style: const TextStyle(color: _gris, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return _buildMessage(
      'Todavía no tienes reportes registrados.',
      Icons.description_outlined,
    );
  }

  Widget _buildMessage(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(icon, color: _gris, size: 42),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _gris, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _nombreEstado(int idEstado) => switch (idEstado) {
        1 => 'Abierto',
        2 => 'En proceso',
        3 => 'Cerrado',
        _ => 'Pendiente',
      };

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia-$mes-${fecha.year}';
  }

  void _crearReporte() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportSelectionScreen(usuario: widget.usuario),
        ),
      );
}
