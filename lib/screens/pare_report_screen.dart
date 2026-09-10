import 'package:flutter/material.dart';

class PareReportScreen extends StatefulWidget {
  const PareReportScreen({super.key, required this.zona, required this.esQr});

  final PareZone zona;
  final bool esQr;

  @override
  State<PareReportScreen> createState() => _PareReportScreenState();
}

class _PareReportScreenState extends State<PareReportScreen> {
  static const _fondo = Color(0xFF0B0E0F);
  static const _panel = Color(0xFF15191C);
  static const _borde = Color(0xFF2D3238);
  static const _verde = Color(0xFFA0F700);
  static const _gris = Color(0xFF89919A);

  final _descripcionController = TextEditingController();
  int _normaSeleccionada = 7;

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
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
          tooltip: 'Volver',
        ),
        title: Text(
          widget.esQr ? 'Reporte desde zona QR' : 'Reporte manual',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                _buildField('OBRA / FAENA DESTINO', widget.zona.obra),
                const SizedBox(height: 14),
                _buildField('ZONA ESTABLECIDA', widget.zona.nombre),
                const SizedBox(height: 14),
                _buildField(
                  'SECTOR / REFERENCIA',
                  '${widget.zona.sector} · ${widget.zona.referencia}',
                ),
                const SizedBox(height: 22),
                _buildNormaSelector(),
                const SizedBox(height: 18),
                if (widget.esQr)
                  _buildLockedNotice()
                else
                  _buildImageEvidence(),
                const SizedBox(height: 18),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _guardarReporte,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _verde,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Registrar Tarjeta Pare',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.esQr
                ? 'Datos de la zona escaneada'
                : 'Completa el reporte de terreno',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: widget.esQr
                ? const Color(0xFF243500)
                : const Color(0xFF29240B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            child: Text(
              widget.esQr ? 'QR' : 'MANUAL',
              style: TextStyle(
                color: widget.esQr ? _verde : const Color(0xFFFFC400),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    final field = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: widget.esQr ? const Color(0xFF121517) : _panel,
        border: Border.all(
          color: widget.esQr ? const Color(0xFF242A2F) : _borde,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: widget.esQr ? const Color(0xFFB3BAC0) : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          if (widget.esQr)
            const Icon(Icons.lock_outline, color: _gris, size: 16),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _gris,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 7),
        field,
        if (widget.esQr)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Dato definido por el jefe de proyecto · solo lectura',
              style: TextStyle(color: _gris, fontSize: 10),
            ),
          ),
      ],
    );
  }

  Widget _buildNormaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NORMA A REPORTAR',
          style: TextStyle(
            color: _gris,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 7,
          children: List.generate(10, (index) {
            final norma = index + 1;
            final seleccionada = norma == _normaSeleccionada;
            return ChoiceChip(
              label: Text('$norma'),
              selected: seleccionada,
              onSelected: (_) => setState(() => _normaSeleccionada = norma),
              selectedColor: _verde,
              backgroundColor: _panel,
              disabledColor: seleccionada ? _verde : _panel,
              labelStyle: TextStyle(
                color: seleccionada ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              side: BorderSide(color: seleccionada ? _verde : _panel),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLockedNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF171F0D),
        border: Border.all(color: const Color(0xFF456A1A)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: _verde, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'La información de la zona fue cargada desde el código QR y no puede editarse.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageEvidence() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IMAGEN DEL REPORTE',
          style: TextStyle(
            color: _gris,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 128,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _panel,
            border: Border.all(color: _borde),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined, color: _gris, size: 32),
              const SizedBox(height: 8),
              const Text(
                'Agrega una imagen como evidencia',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.upload_outlined, size: 16),
                label: const Text('Seleccionar imagen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _verde,
                  side: const BorderSide(color: _verde),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descripcionController,
      maxLines: 3,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'OBSERVACIÓN',
        hintText: 'Describe brevemente lo observado',
        labelStyle: const TextStyle(
          color: _gris,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        hintStyle: const TextStyle(color: _gris),
        filled: true,
        fillColor: _panel,
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

  void _seleccionarImagen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Selector de imagen listo para conectar con cámara o galería.',
        ),
      ),
    );
  }

  void _guardarReporte() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarjeta Pare registrada correctamente.')),
    );
  }
}

class PareZone {
  const PareZone({
    required this.obra,
    required this.nombre,
    required this.sector,
    required this.referencia,
  });

  final String obra;
  final String nombre;
  final String sector;
  final String referencia;
}
