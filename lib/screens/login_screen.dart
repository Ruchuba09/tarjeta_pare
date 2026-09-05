import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database_helper.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _rutController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _recordarUsuario = false;
  bool _mostrarPassword = false;
  bool _iniciandoSesion = false;

  static const _fondo = Color(0xFF0B0E0F);
  static const _panel = Color(0xFF15191C);
  static const _borde = Color(0xFF2D3238);
  static const _verde = Color(0xFFA0F700);
  static const _textoSecundario = Color(0xFF7A7F85);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 32, 22, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildBrand(),
                    const SizedBox(height: 38),
                    _buildLoginPanel(),
                    const SizedBox(height: 19),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    const Text(
                      '© 2026 AVA Montajes S.A. • Seguridad Primero',
                      style: TextStyle(color: Color(0xFF586269), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: _verde, width: 2),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Image.network(
            'https://cdn.intrava.cl/v2/logos/isotipo-negro-verde.png',
            width: 88,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Text(
              'AVA',
              style: TextStyle(
                color: _verde,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'MONTAJES S.A.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Modelo Predictivo Integral',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        const Text(
          'Control operacional SGI y gestión activa de riesgos\nen faena minera.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _textoSecundario, fontSize: 13, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildLoginPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 18),
      decoration: BoxDecoration(
        color: _panel,
        border: Border.all(color: _borde),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acceso Personal SGI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 17),
          _buildFieldLabel('RUT USUARIO'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _rutController,
            keyboardType: TextInputType.text,
            inputFormatters: [RutInputFormatter()],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _fieldDecoration('12.345.678-9', Icons.circle),
            validator: (value) {
              final rut = value?.replaceAll(RegExp(r'[^0-9kK]'), '') ?? '';
              if (rut.isEmpty) return 'Ingresa tu RUT';
              if (rut.length < 2) return 'Completa tu RUT';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('CONTRASEÑA SGI'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: !_mostrarPassword,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _fieldDecoration('••••••••', Icons.lock_outline)
                .copyWith(
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _mostrarPassword = !_mostrarPassword),
                    icon: Icon(
                      _mostrarPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: _textoSecundario,
                      size: 19,
                    ),
                    tooltip: _mostrarPassword
                        ? 'Ocultar contraseña'
                        : 'Mostrar contraseña',
                  ),
                ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Ingresa tu contraseña' : null,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: _recordarUsuario,
                  onChanged: (value) =>
                      setState(() => _recordarUsuario = value ?? false),
                  side: const BorderSide(color: _verde),
                  activeColor: _verde,
                  checkColor: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Recordar',
                style: TextStyle(color: _textoSecundario, fontSize: 12),
              ),
              const Spacer(),
              TextButton(
                onPressed: _recuperarClave,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Recuperar Clave',
                  style: TextStyle(color: _verde, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: _textoSecundario,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: .4,
    ),
  );

  InputDecoration _fieldDecoration(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white, fontSize: 14),
        prefixIcon: Icon(icon, color: _textoSecundario, size: 14),
        filled: true,
        fillColor: _fondo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: _borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: _verde),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      );

  Widget _buildLoginButton() => SizedBox(
    width: double.infinity,
    height: 47,
    child: ElevatedButton(
      onPressed: _iniciandoSesion ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: _verde,
        foregroundColor: Colors.black,
        disabledBackgroundColor: _verde.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: _iniciandoSesion
          ? const SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : const Text(
              'Ingresar SGI Móvil',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
    ),
  );

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _iniciandoSesion = true);
    Map<String, Object?>? usuario;
    try {
      usuario = await DatabaseHelper.instancia.autenticarUsuario(
        rut: _rutController.text,
        password: _passwordController.text,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _iniciandoSesion = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la base de datos local'),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _iniciandoSesion = false);
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('RUT o contraseña incorrectos')),
      );
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DashboardScreen(usuario: usuario!)),
    );
  }

  void _recuperarClave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacta al administrador del sistema')),
    );
  }

  @override
  void dispose() {
    _rutController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class RutInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final caracteres = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^0-9K]'),
      '',
    );
    final rut = caracteres.length > 9 ? caracteres.substring(0, 9) : caracteres;

    if (rut.length < 9) {
      return TextEditingValue(
        text: rut,
        selection: TextSelection.collapsed(offset: rut.length),
      );
    }

    final cuerpo = rut.substring(0, rut.length - 1);
    final verificador = rut.substring(rut.length - 1);
    final cuerpoFormateado = cuerpo.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    final textoFormateado = '$cuerpoFormateado-$verificador';

    return TextEditingValue(
      text: textoFormateado,
      selection: TextSelection.collapsed(offset: textoFormateado.length),
    );
  }
}
