import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detalle_reporte_page.dart';

class ReportesPage extends StatefulWidget {
  final bool esAdmin;

  const ReportesPage({
    super.key,
    this.esAdmin = false,
  });

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  String filtroActual = 'Todos';

  Stream<QuerySnapshot<Map<String, dynamic>>> obtenerReportes() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('incidentes');

    if (filtroActual != 'Todos') {
      query = query.where('estado', isEqualTo: filtroActual);
    }

    return query.orderBy('fechaCreacion', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF4F6F8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff13294B),
                  Color(0xff148A3A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reportes registrados',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Consulta, revisa y administra los incidentes reportados',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                filtro('Todos'),
                const SizedBox(width: 10),
                filtro('Reportado'),
                const SizedBox(width: 10),
                filtro('En proceso'),
                const SizedBox(width: 10),
                filtro('Resuelto'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: obtenerReportes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff148A3A),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'Error al cargar los reportes\n\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xff0B1B33),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
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
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No hay reportes para este filtro',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff13294B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();

                    final tipo = data['tipo']?.toString() ?? '';
                    final descripcion = data['descripcion']?.toString() ?? '';
                    final estado = data['estado']?.toString() ?? '';
                    final imagenURL = data['imagenURL']?.toString() ?? '';
                    final fechaCreacion = data['fechaCreacion'];

                    String fechaTexto = '';

                    if (fechaCreacion is Timestamp) {
                      final fecha = fechaCreacion.toDate();
                      fechaTexto =
                          '${fecha.day.toString().padLeft(2, '0')}/'
                          '${fecha.month.toString().padLeft(2, '0')}/'
                          '${fecha.year} '
                          '${fecha.hour.toString().padLeft(2, '0')}:'
                          '${fecha.minute.toString().padLeft(2, '0')}';
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetalleReportePage(
                              docId: docs[index].id,
                              data: data,
                              esAdmin: widget.esAdmin,
                            ),
                          ),
                        );
                      },
                      child: ReporteCard(
                        tipo: tipo,
                        descripcion: descripcion,
                        fecha: fechaTexto,
                        estado: estado,
                        colorEstado: getColorEstado(estado),
                        colorLinea: getColorEstado(estado),
                        icono: getIcono(tipo),
                        imagenURL: imagenURL,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget filtro(String texto) {
    final activo = filtroActual == texto;

    return GestureDetector(
      onTap: () {
        setState(() {
          filtroActual = texto;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? const Color(0xff13294B) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: activo ? const Color(0xff13294B) : Colors.grey.shade300,
          ),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: const Color(0xff13294B).withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: activo ? Colors.white : const Color(0xff13294B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

Color getColorEstado(String estado) {
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

IconData getIcono(String tipo) {
  switch (tipo) {
    case 'Electricidad':
      return Icons.electric_bolt_outlined;
    case 'Baños':
      return Icons.water_drop_outlined;
    case 'Seguridad':
      return Icons.security_outlined;
    case 'Infraestructura':
      return Icons.apartment_outlined;
    default:
      return Icons.report_problem_outlined;
  }
}

class ReporteCard extends StatelessWidget {
  final String tipo;
  final String descripcion;
  final String fecha;
  final String estado;
  final Color colorEstado;
  final Color colorLinea;
  final IconData icono;
  final String imagenURL;

  const ReporteCard({
    super.key,
    required this.tipo,
    required this.descripcion,
    required this.fecha,
    required this.estado,
    required this.colorEstado,
    required this.colorLinea,
    required this.icono,
    required this.imagenURL,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 92,
            decoration: BoxDecoration(
              color: colorLinea,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xffEEF3F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: imagenURL.isEmpty
                ? Icon(
                    icono,
                    color: const Color(0xff148A3A),
                    size: 34,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      imagenURL,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          icono,
                          color: const Color(0xff148A3A),
                          size: 34,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tipo.isEmpty ? 'Sin tipo' : tipo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0B1B33),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorEstado.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        estado.isEmpty ? 'Sin estado' : estado,
                        style: TextStyle(
                          color: colorEstado,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  descripcion.isEmpty ? 'Sin descripción' : descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff53627A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 15,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        fecha.isEmpty ? 'Sin fecha' : fecha,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}