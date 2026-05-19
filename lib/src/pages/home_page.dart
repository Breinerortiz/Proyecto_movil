import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'reportes_page.dart';
import 'nuevo_incidente_page.dart';
import 'estadisticas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaActual = 0;
  bool esAdmin = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is bool) {
      esAdmin = args;
    }
  }

  Future<void> cerrarSesion() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xff13294B),
              ),
              SizedBox(width: 8),
              Text('Cerrar sesión'),
            ],
          ),
          content: const Text(
            '¿Seguro que deseas salir del sistema?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff13294B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (salir == true) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  String getTituloPagina() {
    if (paginaActual == 0) {
      return 'Inicio';
    } else if (paginaActual == 1) {
      return 'Nuevo incidente';
    } else {
      return 'Estadísticas';
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      ReportesPage(esAdmin: esAdmin),
      const NuevoIncidentePage(),
      const EstadisticasPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xff13294B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          getTituloPagina(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: paginas[paginaActual],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: paginaActual,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xff148A3A),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          onTap: (index) async {
            if (index == 3) {
              await cerrarSesion();
              return;
            }

            setState(() {
              paginaActual = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Reportar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout_outlined),
              activeIcon: Icon(Icons.logout),
              label: 'Salir',
            ),
          ],
        ),
      ),
    );
  }
}