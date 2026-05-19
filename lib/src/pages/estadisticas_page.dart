import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('incidentes').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Error al cargar estadísticas'),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            int total = docs.length;
            int reportados = 0;
            int enProceso = 0;
            int resueltos = 0;

            final Map<String, int> porTipo = {};

            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final estado = data['estado'] ?? '';
              final tipo = data['tipo'] ?? 'Sin tipo';

              if (estado == 'Reportado') reportados++;
              if (estado == 'En proceso') enProceso++;
              if (estado == 'Resuelto') resueltos++;

              porTipo[tipo] = (porTipo[tipo] ?? 0) + 1;
            }

            final tiposOrdenados = porTipo.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panel de Estadísticas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0B1B33),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Resumen general de incidentes',
                    style: TextStyle(
                      color: Color(0xff53627A),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: resumenCard(
                          'TOTAL',
                          total.toString(),
                          const Color(0xff0B1B33),
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: resumenCard(
                          'REPORTADOS',
                          reportados.toString(),
                          const Color(0xffff7a1a),
                          const Color(0xfffff4e9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: resumenCard(
                          'EN PROCESO',
                          enProceso.toString(),
                          const Color(0xff1f6fff),
                          const Color(0xffeef5ff),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: resumenCard(
                          'RESUELTOS',
                          resueltos.toString(),
                          const Color(0xff17b45b),
                          const Color(0xffeffff5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTADO DE LOS INCIDENTES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0B1B33),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          height: 220,
                          child: total == 0
                              ? const Center(
                                  child: Text('No hay datos para mostrar'),
                                )
                              : PieChart(
                                  PieChartData(
                                    sectionsSpace: 3,
                                    centerSpaceRadius: 45,
                                    sections: [
                                      PieChartSectionData(
                                        value: reportados.toDouble(),
                                        title: reportados == 0
                                            ? ''
                                            : reportados.toString(),
                                        radius: 55,
                                        color: const Color(0xffff7a1a),
                                        titleStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: enProceso.toDouble(),
                                        title: enProceso == 0
                                            ? ''
                                            : enProceso.toString(),
                                        radius: 55,
                                        color: const Color(0xff1f6fff),
                                        titleStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      PieChartSectionData(
                                        value: resueltos.toDouble(),
                                        title: resueltos == 0
                                            ? ''
                                            : resueltos.toString(),
                                        radius: 55,
                                        color: const Color(0xff17b45b),
                                        titleStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),

                        leyenda(
                          'Reportado',
                          reportados,
                          const Color(0xffff7a1a),
                        ),
                        const SizedBox(height: 10),
                        leyenda(
                          'En proceso',
                          enProceso,
                          const Color(0xff1f6fff),
                        ),
                        const SizedBox(height: 10),
                        leyenda(
                          'Resuelto',
                          resueltos,
                          const Color(0xff17b45b),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INCIDENTES POR TIPO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0B1B33),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (tiposOrdenados.isEmpty)
                          const Text('No hay incidentes registrados')
                        else
                          ...tiposOrdenados.take(6).map((entry) {
                            final porcentaje = total == 0
                                ? 0.0
                                : entry.value / total;

                            return barraTipo(
                              entry.key,
                              porcentaje,
                              entry.value,
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget resumenCard(
    String titulo,
    String valor,
    Color color,
    Color fondo,
  ) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget leyenda(String titulo, int valor, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff0B1B33),
            ),
          ),
        ),
        Text(
          valor.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff0B1B33),
          ),
        ),
      ],
    );
  }

  Widget barraTipo(String tipo, double porcentaje, int cantidad) {
    final porcentajeTexto = (porcentaje * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tipo,
                  style: const TextStyle(
                    color: Color(0xff0B1B33),
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$cantidad  |  $porcentajeTexto%',
                style: const TextStyle(
                  color: Color(0xff0B1B33),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: porcentaje,
              backgroundColor: const Color(0xffEEF0F3),
              color: colorPorTipo(tipo),
            ),
          ),
        ],
      ),
    );
  }

  Color colorPorTipo(String tipo) {
    switch (tipo) {
      case 'Infraestructura':
        return const Color(0xff13294B);
      case 'Baños':
        return const Color(0xff1f6fff);
      case 'Electricidad':
        return const Color(0xffff7a1a);
      case 'Seguridad':
        return const Color(0xffff4b4b);
      case 'Limpieza':
        return const Color(0xff17b45b);
      default:
        return const Color(0xff148A3A);
    }
  }
}