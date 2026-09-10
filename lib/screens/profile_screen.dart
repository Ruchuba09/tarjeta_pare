import 'package:flutter/material.dart';

import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.usuario});

  final Map<String, Object?> usuario;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _panel = Color(0xFF1B1D22);
  static const _borde = Color(0xFF2D3238);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF9A9DA3);
  static const _rojo = Color(0xFFFF414B);

  String get _nombre =>
      (widget.usuario['nombre'] as String?)?.trim().isNotEmpty == true
      ? widget.usuario['nombre'] as String
      : 'Usuario SGI';

  String get _rol {
    final rol = (widget.usuario['rol'] as String? ?? 'usuario').replaceAll('_', ' ');
    return rol.isEmpty ? 'Usuario SGI' : _capitalizar(rol);
  }

  String _capitalizar(String value) => value
      .split(' ')
      .map((parte) => parte.isEmpty ? parte : '${parte[0].toUpperCase()}${parte.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        const SizedBox(height: 6),
        const CircleAvatar(
          radius: 38,
          backgroundColor: _verde,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFF624C2D),
            child: Icon(Icons.person, color: Colors.white, size: 48),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(_rol, style: const TextStyle(color: _verde, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        const Center(child: Text('Faena Antofagasta', style: TextStyle(color: _gris, fontSize: 12))),
        const SizedBox(height: 18),
        Row(
          children: [
            _metric('42', 'Reportes'),
            const SizedBox(width: 9),
            _metric('180', 'Días Faena'),
            const SizedBox(width: 9),
            _metric('15', 'Alertas Ok'),
          ],
        ),
        const SizedBox(height: 18),
        _profileAction(Icons.person_outline, 'Datos Personales', _openPersonalData),
        _profileAction(Icons.description_outlined, 'Certificaciones SGI', _showUnavailable),
        _profileAction(Icons.history, 'Historial de Actividad', _showUnavailable),
        _profileAction(Icons.settings_outlined, 'Configuración', _openSettings),
        _profileAction(Icons.help_outline, 'Soporte Técnico', _showUnavailable),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _closeSession,
          child: const Text('Cerrar Sesión', style: TextStyle(color: _rojo, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _metric(String value, String label) => Expanded(
        child: Container(
          height: 56,
          decoration: BoxDecoration(color: _panel, border: Border.all(color: _borde), borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value, style: const TextStyle(color: _verde, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(color: _gris, fontSize: 10)),
            ],
          ),
        ),
      );

  Widget _profileAction(IconData icon, String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: _panel, border: Border.all(color: _borde), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(icon, color: _verde, size: 20),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: _gris, size: 20),
              ],
            ),
          ),
        ),
      );

  void _openPersonalData() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _PersonalDataScreen(usuario: widget.usuario)),
      );

  void _openSettings() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const _SettingsScreen()),
      );

  void _showUnavailable() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta sección estará disponible próximamente.')),
      );

  void _closeSession() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
}

class _PersonalDataScreen extends StatefulWidget {
  const _PersonalDataScreen({required this.usuario});

  final Map<String, Object?> usuario;

  @override
  State<_PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<_PersonalDataScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF9A9DA3);
  late final TextEditingController _nombre;
  late final TextEditingController _rut;
  late final TextEditingController _correo;
  late final TextEditingController _cargo;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.usuario['nombre'] as String? ?? '');
    _rut = TextEditingController(text: widget.usuario['rut'] as String? ?? '');
    _correo = TextEditingController(text: widget.usuario['correo'] as String? ?? '');
    _cargo = TextEditingController(text: widget.usuario['rol'] as String? ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _rut.dispose();
    _correo.dispose();
    _cargo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _fondo,
        appBar: AppBar(
          backgroundColor: _fondo,
          elevation: 0,
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: _verde)),
          title: const Text('Perfil', style: TextStyle(color: _verde, fontSize: 13)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Text('Datos Personales', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _field('NOMBRE COMPLETO', _nombre),
            _field('RUT', _rut),
            _field('CARGO', _cargo),
            _field('EMPRESA', TextEditingController(text: 'AVA Montajes S.A.')),
            _field('OBRA ASIGNADA', TextEditingController(text: 'Antofagasta Fase 2')),
            _field('TELÉFONO', TextEditingController(text: '+56 9 8765 4321')),
            _field('EMAIL CORPORATIVO', _correo),
            const SizedBox(height: 2),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cambios guardados localmente.'))),
                style: ElevatedButton.styleFrom(backgroundColor: _verde, foregroundColor: Colors.black),
                child: const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );

  Widget _field(String label, TextEditingController controller) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _gris, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 5),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF15171B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: Color(0xFF2D3238))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: const BorderSide(color: Color(0xFF2D3238))),
              ),
            ),
          ],
        ),
      );
}

class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen();

  @override
  State<_SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF9A9DA3);
  bool _push = true;
  bool _criticas = true;
  bool _recordatorios = true;
  bool _offline = false;
  bool _sync = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _fondo,
        appBar: AppBar(
          backgroundColor: _fondo,
          elevation: 0,
          leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: _verde)),
          title: const Text('Perfil', style: TextStyle(color: _verde, fontSize: 13)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Text('Configuración', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _setting('Notificaciones Push', _push, (value) => setState(() => _push = value)),
            _setting('Alertas Críticas', _criticas, (value) => setState(() => _criticas = value)),
            _setting('Recordatorio de Reportes', _recordatorios, (value) => setState(() => _recordatorios = value)),
            _setting('Modo Offline', _offline, (value) => setState(() => _offline = value)),
            _setting('Sincronización Automática', _sync, (value) => setState(() => _sync = value)),
            const SizedBox(height: 10),
            const Text('INFORMACIÓN', style: TextStyle(color: _gris, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF1B1D22), border: Border.all(color: const Color(0xFF2D3238)), borderRadius: BorderRadius.circular(9)),
              child: const Column(
                children: [
                  _InfoRow(label: 'Versión de la App', value: 'v2.1.0'),
                  Divider(color: Color(0xFF2D3238), height: 12),
                  _InfoRow(label: 'Última Sincronización', value: '15-May-2026 10:15'),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _setting(String label, bool value, ValueChanged<bool> onChanged) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFF1B1D22), border: Border.all(color: const Color(0xFF2D3238)), borderRadius: BorderRadius.circular(9)),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
            const Spacer(),
            Switch(value: value, onChanged: onChanged, activeColor: _verde, activeTrackColor: _verde.withValues(alpha: .4)),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9A9DA3), fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      );
}
