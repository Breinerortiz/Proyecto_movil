import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalleReportePage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final bool esAdmin;

  const DetalleReportePage({
    super.key,
    required this.docId,
    required this.data,
    required this.esAdmin,
  });

  void mostrarImagenCompleta(BuildContext context, String imagenURL) {
    if (imagenURL.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VistaImagenPage(imagenURL: imagenURL),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('incidentes')
          .doc(docId)
          .snapshots(),
      builder: (context, snapshot) {
        final datos = snapshot.hasData && snapshot.data!.exists
            ? snapshot.data!.data() as Map<String, dynamic>
            : data;

        final tipo = datos['tipo']?.toString() ?? '';
        final descripcion = datos['descripcion']?.toString() ?? '';
        final estado = datos['estado']?.toString() ?? '';
        final ubicacion = datos['ubicacionTexto']?.toString() ?? '';
        final imagenURL = datos['imagenURL']?.toString() ?? '';
        final fechaCreacion = datos['fechaCreacion'];

        String fechaTexto = 'Sin fecha';
        if (fechaCreacion is Timestamp) {
          final fecha = fechaCreacion.toDate();
          fechaTexto =
              '${fecha.day.toString().padLeft(2, '0')}/'
              '${fecha.month.toString().padLeft(2, '0')}/'
              '${fecha.year}  '
              '${fecha.hour.toString().padLeft(2, '0')}:'
              '${fecha.minute.toString().padLeft(2, '0')}';
        }

        return Scaffold(
          backgroundColor: const Color(0xffF4F6F8),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => mostrarImagenCompleta(context, imagenURL),
                        child: SizedBox(
                          height: 290,
                          width: double.infinity,
                          child: imagenURL.isEmpty
                              ? Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xff13294B),
                                        Color(0xff148A3A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 75,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Hero(
                                  tag: imagenURL,
                                  child: Image.network(
                                    imagenURL,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xff13294B),
                                              Color(0xff148A3A),
                                            ],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 70,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        height: 290,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.10),
                              Colors.black.withOpacity(0.52),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: const Color(0xff13294B),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      if (imagenURL.isNotEmpty)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.zoom_out_map),
                              color: const Color(0xff13294B),
                              onPressed: () =>
                                  mostrarImagenCompleta(context, imagenURL),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 22,
                        right: 22,
                        bottom: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff148A3A),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                tipo.isEmpty ? 'SIN TIPO' : tipo.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Detalle del reporte',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Consulta toda la información del incidente reportado',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Estado actual',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff13294B),
                                      ),
                                    ),
                                  ),
                                  estadoChip(estado),
                                ],
                              ),
                              const SizedBox(height: 18),
                              infoCard(
                                Icons.location_on_outlined,
                                'Ubicación',
                                ubicacion,
                              ),
                              const SizedBox(height: 14),
                              infoCard(
                                Icons.calendar_month_outlined,
                                'Fecha de reporte',
                                fechaTexto,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Descripción reportada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff13294B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            descripcion.isEmpty ? 'Sin descripción' : descripcion,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: Color(0xff53627A),
                            ),
                          ),
                        ),
                        if (esAdmin) ...[
                          const SizedBox(height: 22),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xffF3FFF7),
                                  Color(0xffE8F7EF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xffB8F0CE),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings_outlined,
                                      color: Color(0xff148A3A),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Panel administrador',
                                      style: TextStyle(
                                        color: Color(0xff148A3A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Actualiza el estado de esta incidencia según el avance del proceso.',
                                  style: TextStyle(
                                    color: Color(0xff53627A),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                if (estado == 'Resuelto') ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE8F7EF),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xffB8F0CE),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.lock_outline,
                                          color: Color(0xff148A3A),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Este reporte ya fue resuelto y su estado quedó bloqueado.',
                                            style: TextStyle(
                                              color: Color(0xff148A3A),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 18),
                                estadoBoton(context, 'Reportado', estado),
                                const SizedBox(height: 10),
                                estadoBoton(context, 'En proceso', estado),
                                const SizedBox(height: 10),
                                estadoBoton(context, 'Resuelto', estado),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget estadoBoton(
    BuildContext context,
    String nuevoEstado,
    String estadoActual,
  ) {
    final bool bloqueado = estadoActual == 'Resuelto';
    final bool esMismoEstado = estadoActual == nuevoEstado;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: bloqueado || esMismoEstado
            ? null
            : () async {
                try {
                  final ref = FirebaseFirestore.instance
                      .collection('incidentes')
                      .doc(docId);

                  final doc = await ref.get();

                  if (!doc.exists) return;

                  final dataActual = doc.data() as Map<String, dynamic>;
                  final estadoFirestore =
                      dataActual['estado']?.toString() ?? '';

                  if (estadoFirestore == 'Resuelto') {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Este reporte ya fue resuelto y no se puede modificar',
                        ),
                        backgroundColor: Color(0xff13294B),
                      ),
                    );
                    return;
                  }

                  await ref.update({'estado': nuevoEstado});

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Estado actualizado a $nuevoEstado'),
                      backgroundColor: const Color(0xff13294B),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
        icon: Icon(
          esMismoEstado
              ? Icons.check_circle
              : bloqueado
                  ? Icons.lock
                  : Icons.sync_alt_rounded,
        ),
        label: Text(
          bloqueado && !esMismoEstado
              ? '$nuevoEstado (bloqueado)'
              : nuevoEstado,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              bloqueado ? Colors.grey.shade400 : colorEstado(nuevoEstado),
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget estadoChip(String estado) {
    final color = colorEstado(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Text(
        estado.isEmpty ? 'Sin estado' : estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget infoCard(IconData icono, String titulo, String valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffEFFFF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: const Color(0xff148A3A),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff53627A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  valor.isEmpty ? 'Sin información' : valor,
                  style: const TextStyle(
                    color: Color(0xff0B1B33),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'Reportado':
        return const Color(0xffff7a1a);
      case 'En proceso':
        return const Color(0xff1f6fff);
      case 'Resuelto':
        return const Color(0xff17b45b);
      default:
        return Colors.grey;
    }
  }
}

class VistaImagenPage extends StatelessWidget {
  final String imagenURL;

  const VistaImagenPage({
    super.key,
    required this.imagenURL,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Hero(
                tag: imagenURL,
                child: Image.network(
                  imagenURL,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 80,
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Imagen completa',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}