import 'package:flutter/material.dart';

import 'pare_report_screen.dart';

class ReportSelectionScreen extends StatefulWidget {
  const ReportSelectionScreen({super.key, required this.usuario});

  final Map<String, Object?> usuario;

  @override
  State<ReportSelectionScreen> createState() => _ReportSelectionScreenState();
}

class _ReportSelectionScreenState extends State<ReportSelectionScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _panel = Color(0xFF15191C);
  static const _borde = Color(0xFF2D3238);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF7A7F85);

  final _zonas = <_ZonaObra>[
    const _ZonaObra(
      nombre: 'Acceso principal',
      sector: 'Portería norte',
      referencia: 'Junto al control de acceso',
      nivel: 'Nivel 1',
    ),
    const _ZonaObra(
      nombre: 'Frente de montaje',
      sector: 'Área de estructuras',
      referencia: 'Andamio azul, lado poniente',
      nivel: 'Nivel 2',
    ),
  ];

  bool get _esJefeDeObra {
    final rol = (widget.usuario['rol'] as String? ?? '').toLowerCase();
    return rol.contains('jefe') || rol.contains('supervisor');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        backgroundColor: _fondo,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: _verde),
          tooltip: 'Volver a inicio',
        ),
        title: const Text(
          'Volver a inicio',
          style: TextStyle(color: _verde, fontSize: 13),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
              children: [
                const Text(
                  'Nuevo Reporte de Terreno',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _esJefeDeObra
                      ? 'Define el contexto del reporte antes de registrarlo.'
                      : 'Selecciona el tipo de hallazgo que deseas ingresar.',
                  style: const TextStyle(color: _gris, fontSize: 13),
                ),
                const SizedBox(height: 18),
                if (_esJefeDeObra) ...[
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                ],
                _buildSectionLabel('ÚNICO TIPO DE REPORTE'),
                const SizedBox(height: 9),
                _buildTarjetaPareButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return InkWell(
      onTap: _mostrarPerfilObra,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF14200F),
          border: Border.all(color: const Color(0xFF456A1A)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.qr_code_2, color: _verde, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perfil de obra',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Obra ampliación Planta Norte · 2 zonas con QR',
                    style: TextStyle(color: _gris, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _verde),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: _gris,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  );

  Widget _buildTarjetaPareButton() {
    final altura = (MediaQuery.sizeOf(context).height * .34).clamp(
      180.0,
      290.0,
    );
    return InkWell(
      onTap: _mostrarOpcionesTarjetaPare,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: altura,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF241F0A),
          border: Border.all(color: const Color(0xFFFFC400), width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.pan_tool_alt_outlined,
              color: Color(0xFFFFC400),
              size: 58,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARJETA PARE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Detén una actividad riesgosa y registra el lugar.',
                    style: TextStyle(color: _gris, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFFFFC400), size: 38),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesTarjetaPare() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: .78,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Cómo deseas iniciar?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Usa el QR de la zona o completa el lugar manualmente.',
                  style: TextStyle(color: _gris, fontSize: 13),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: _actionButton(
                    'CAPTURAR QR',
                    'Completa la zona automáticamente',
                    Icons.qr_code_scanner,
                    _capturarQr,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _actionButton(
                    'REPORTE MANUAL',
                    'Selecciona la zona de la obra',
                    Icons.edit_location_alt_outlined,
                    _reporteManual,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 44),
        label: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(fontSize: 13)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: _verde,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
      ),
    );
  }

  void _capturarQr() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PareReportScreen(
          esQr: true,
          zona: PareZone(
            obra: 'Antofagasta Fase 2',
            nombre: 'Acceso principal',
            sector: 'Portería norte',
            referencia: 'Junto al control de acceso',
          ),
        ),
      ),
    );
  }

  void _reporteManual() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PareReportScreen(
          esQr: false,
          zona: PareZone(
            obra: 'Antofagasta Fase 2',
            nombre: 'Acceso principal',
            sector: 'Portería norte',
            referencia: 'Junto al control de acceso',
          ),
        ),
      ),
    );
  }

  void _mostrarPerfilObra() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: FractionallySizedBox(
            heightFactor: .82,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perfil de obra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Gestiona las zonas y genera los QR para terreno.',
                    style: TextStyle(color: _gris, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: _zonas
                          .map(
                            (zona) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.qr_code_2,
                                color: _verde,
                              ),
                              title: Text(
                                zona.nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '${zona.sector} · ${zona.referencia} · ${zona.nivel}',
                                style: const TextStyle(
                                  color: _gris,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.download_outlined,
                                color: _gris,
                                size: 20,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _mostrarFormularioZona(setModalState),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar zona de obra'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _verde,
                      side: const BorderSide(color: _verde),
                      minimumSize: const Size(double.infinity, 44),
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

  void _mostrarFormularioZona(StateSetter setModalState) {
    final nombreController = TextEditingController();
    final sectorController = TextEditingController();
    final referenciaController = TextEditingController();
    final nivelController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _panel,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 28),
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Text(
          'Nueva zona de obra',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.sizeOf(dialogContext).height * .54,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Completa la ubicación antes de generar el QR.',
                      style: TextStyle(color: _gris, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _zoneField(
                    nombreController,
                    'Nombre de la zona',
                    'Ej. Patio de soldadura',
                  ),
                  _zoneField(
                    sectorController,
                    'Sector o área',
                    'Ej. Estructuras poniente',
                  ),
                  _zoneField(
                    referenciaController,
                    'Referencia visible',
                    'Ej. Junto al container azul',
                  ),
                  _zoneField(nivelController, 'Nivel o piso', 'Ej. Nivel 1'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: _gris)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              setModalState(
                () => _zonas.add(
                  _ZonaObra(
                    nombre: nombreController.text.trim(),
                    sector: sectorController.text.trim(),
                    referencia: referenciaController.text.trim(),
                    nivel: nivelController.text.trim(),
                  ),
                ),
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _verde,
              foregroundColor: Colors.black,
              minimumSize: const Size(150, 46),
            ),
            child: const Text('Guardar zona'),
          ),
        ],
      ),
    );
  }

  Widget _zoneField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: _gris),
          hintStyle: const TextStyle(color: _gris),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _borde),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: _verde),
          ),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Completa este dato' : null,
      ),
    );
  }
}

class _ZonaObra {
  const _ZonaObra({
    required this.nombre,
    required this.sector,
    required this.referencia,
    required this.nivel,
  });

  final String nombre;
  final String sector;
  final String referencia;
  final String nivel;
}
