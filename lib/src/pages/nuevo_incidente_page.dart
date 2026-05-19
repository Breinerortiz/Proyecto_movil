import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class NuevoIncidentePage extends StatefulWidget {
  const NuevoIncidentePage({super.key});

  @override
  State<NuevoIncidentePage> createState() => _NuevoIncidentePageState();
}

class _NuevoIncidentePageState extends State<NuevoIncidentePage> {
  final descripcionCtrl = TextEditingController();
  final ubicacionCtrl = TextEditingController();

  File? imagenSeleccionada;
  final ImagePicker picker = ImagePicker();

  String? tipoSeleccionado;
  bool cargando = false;

  double? latitud;
  double? longitud;

  String? errorTipo;
  String? errorDescripcion;
  String? errorUbicacion;
  String? errorImagen;

  final List<String> tipos = [
    'Infraestructura',
    'Electricidad',
    'Baños',
    'Seguridad',
    'Limpieza',
    'Internet',
    'Mobiliario',
    'Equipos',
  ];

  @override
  void initState() {
    super.initState();

    descripcionCtrl.addListener(() {
      if (errorDescripcion != null) {
        validarDescripcion();
      }
    });

    ubicacionCtrl.addListener(() {
      if (errorUbicacion != null) {
        validarUbicacion();
      }
    });
  }

  @override
  void dispose() {
    descripcionCtrl.dispose();
    ubicacionCtrl.dispose();
    super.dispose();
  }

  bool validarTipo() {
    if (tipoSeleccionado == null || tipoSeleccionado!.trim().isEmpty) {
      errorTipo = 'Selecciona un tipo de incidente';
      return false;
    }

    errorTipo = null;
    return true;
  }

  bool validarDescripcion() {
    final texto = descripcionCtrl.text.trim();

    if (texto.isEmpty) {
      errorDescripcion = 'La descripción es obligatoria';
      setState(() {});
      return false;
    }

    if (texto.length < 10) {
      errorDescripcion = 'Describe un poco mejor el incidente';
      setState(() {});
      return false;
    }

    errorDescripcion = null;
    setState(() {});
    return true;
  }

  bool validarUbicacion() {
    final texto = ubicacionCtrl.text.trim();

    if (texto.isEmpty) {
      errorUbicacion = 'La ubicación es obligatoria';
      setState(() {});
      return false;
    }

    errorUbicacion = null;
    setState(() {});
    return true;
  }

  bool validarImagen() {
    if (imagenSeleccionada == null) {
      errorImagen = 'Debes agregar una foto';
      return false;
    }

    errorImagen = null;
    return true;
  }

  bool validarFormulario() {
    final tipoOk = validarTipo();
    final descripcionOk = validarDescripcion();
    final ubicacionOk = validarUbicacion();
    final imagenOk = validarImagen();

    setState(() {});

    return tipoOk && descripcionOk && ubicacionOk && imagenOk;
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        imagenSeleccionada = File(pickedFile.path);
        errorImagen = null;
      });
    }
  }

  Future<void> mostrarOpcionesImagen() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Seleccionar imagen',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Escoge una opción para agregar evidencia'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xff13294B),
                  ),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    await seleccionarImagen(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xff148A3A),
                  ),
                  title: const Text('Elegir de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    await seleccionarImagen(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> verImagenCompleta() async {
    if (imagenSeleccionada == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VistaPreviaImagenLocal(
          imagen: imagenSeleccionada!,
        ),
      ),
    );
  }

  Future<void> usarUbicacionActual() async {
    try {
      bool servicioActivo = await Geolocator.isLocationServiceEnabled();
      if (!servicioActivo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activa el GPS del dispositivo'),
          ),
        );
        return;
      }

      LocationPermission permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes aceptar el permiso de ubicación'),
          ),
        );
        return;
      }

      if (permiso == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El permiso fue bloqueado permanentemente'),
          ),
        );
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitud = pos.latitude;
      longitud = pos.longitude;

      try {
        final lugares = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );

        if (lugares.isNotEmpty) {
          final lugar = lugares.first;
          final texto =
              '${lugar.street ?? ''} ${lugar.subLocality ?? ''} ${lugar.locality ?? ''}'
                  .trim();

          setState(() {
            ubicacionCtrl.text = texto.isEmpty
                ? 'Lat: ${pos.latitude}, Lng: ${pos.longitude}'
                : texto;
            errorUbicacion = null;
          });
        } else {
          setState(() {
            ubicacionCtrl.text = 'Lat: ${pos.latitude}, Lng: ${pos.longitude}';
            errorUbicacion = null;
          });
        }
      } catch (_) {
        setState(() {
          ubicacionCtrl.text = 'Lat: ${pos.latitude}, Lng: ${pos.longitude}';
          errorUbicacion = null;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación obtenida correctamente'),
          backgroundColor: Color(0xff13294B),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener ubicación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> confirmarEnvio() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff13294B),
                        Color(0xff148A3A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Confirmar envío',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff13294B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Revisa la información antes de registrar el incidente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 18),
                resumenItem('Tipo', tipoSeleccionado ?? 'Sin tipo'),
                const SizedBox(height: 10),
                resumenItem(
                  'Descripción',
                  descripcionCtrl.text.trim(),
                ),
                const SizedBox(height: 10),
                resumenItem(
                  'Ubicación',
                  ubicacionCtrl.text.trim(),
                ),
                const SizedBox(height: 10),
                resumenItem(
                  'Imagen',
                  imagenSeleccionada != null ? 'Adjuntada correctamente' : 'No adjuntada',
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff13294B),
                          side: const BorderSide(color: Color(0xff13294B)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff13294B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text(
                          'Sí, enviar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return confirmar == true;
  }

  Widget resumenItem(String titulo, String valor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xff53627A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor.isEmpty ? 'Sin información' : valor,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xff0B1B33),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> mostrarDialogoExito() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff148A3A),
                        Color(0xff13294B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '¡Reporte enviado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff13294B),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffEFFFF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xffB8F0CE),
                    ),
                  ),
                  child: const Text(
                    'Estado inicial: Reportado',
                    style: TextStyle(
                      color: Color(0xff148A3A),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Tu incidente fue registrado correctamente en el sistema institucional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff13294B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> enviarReporte() async {
    FocusScope.of(context).unfocus();

    if (!validarFormulario()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos marcados'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmado = await confirmarEnvio();
    if (!confirmado) return;

    setState(() {
      cargando = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';

      final nombreImagen =
          '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = FirebaseStorage.instance
          .ref()
          .child('incidentes')
          .child(nombreImagen);

      await ref.putFile(imagenSeleccionada!);

      final imagenURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('incidentes').add({
        'tipo': tipoSeleccionado,
        'descripcion': descripcionCtrl.text.trim(),
        'estado': 'Reportado',
        'ubicacionTexto': ubicacionCtrl.text.trim(),
        'latitud': latitud,
        'longitud': longitud,
        'imagenURL': imagenURL,
        'usuarioId': uid,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      descripcionCtrl.clear();
      ubicacionCtrl.clear();

      setState(() {
        tipoSeleccionado = null;
        imagenSeleccionada = null;
        latitud = null;
        longitud = null;
        errorTipo = null;
        errorDescripcion = null;
        errorUbicacion = null;
        errorImagen = null;
      });

      if (!mounted) return;

      await mostrarDialogoExito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Widget tituloCampo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xff13294B),
        fontSize: 15,
      ),
    );
  }

  Widget textoError(String? texto) {
    if (texto == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffF4F6F8),
      child: SingleChildScrollView(
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
                      Icons.add_alert_outlined,
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
                          'Nuevo incidente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Reporta una novedad para ayudar a mejorar el campus',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
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
                    tituloCampo('Tipo de incidente *'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tipoSeleccionado,
                      decoration: inputDecoration(
                        'Selecciona el tipo',
                        errorTexto: errorTipo,
                      ),
                      items: tipos.map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: cargando
                          ? null
                          : (value) {
                              setState(() {
                                tipoSeleccionado = value;
                                errorTipo = null;
                              });
                            },
                    ),
                    const SizedBox(height: 18),
                    tituloCampo('Descripción detallada *'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descripcionCtrl,
                      enabled: !cargando,
                      maxLines: 4,
                      decoration: inputDecoration(
                        'Describe el incidente encontrado',
                        errorTexto: errorDescripcion,
                      ),
                    ),
                    const SizedBox(height: 18),
                    tituloCampo('Evidencia fotográfica *'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: cargando
                          ? null
                          : () {
                              if (imagenSeleccionada == null) {
                                mostrarOpcionesImagen();
                              } else {
                                verImagenCompleta();
                              }
                            },
                      child: Container(
                        width: double.infinity,
                        height: 190,
                        decoration: BoxDecoration(
                          color: const Color(0xffF7FBF8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: errorImagen != null
                                ? Colors.red
                                : const Color(0xffB8F0CE),
                            width: 1.4,
                          ),
                        ),
                        child: imagenSeleccionada == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Color(0xff148A3A),
                                    size: 40,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Toca para tomar o elegir una foto',
                                    style: TextStyle(
                                      color: Color(0xff148A3A),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Agrega evidencia visual del incidente',
                                    style: TextStyle(
                                      color: Color(0xff53627A),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      imagenSeleccionada!,
                                      width: double.infinity,
                                      height: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.60),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.visibility,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed:
                                                cargando ? null : verImagenCompleta,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.60),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: cargando
                                                ? null
                                                : mostrarOpcionesImagen,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.red.withOpacity(0.85),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: cargando
                                                ? null
                                                : () {
                                                    setState(() {
                                                      imagenSeleccionada = null;
                                                      errorImagen =
                                                          'Debes agregar una foto';
                                                    });
                                                  },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    textoError(errorImagen),
                    const SizedBox(height: 18),
                    tituloCampo('Ubicación exacta *'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ubicacionCtrl,
                      enabled: !cargando,
                      decoration: inputDecoration(
                        'Ej: Bloque Administrativo, Escaleras',
                        icono: Icons.location_on_outlined,
                        errorTexto: errorUbicacion,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: cargando ? null : usarUbicacionActual,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Usar mi ubicación actual'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff13294B),
                          side: const BorderSide(
                            color: Color(0xff13294B),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    if (latitud != null && longitud != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF8FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          'Coordenadas detectadas: $latitud, $longitud',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff53627A),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: cargando ? null : enviarReporte,
                        icon: cargando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          cargando ? 'Enviando...' : 'Enviar reporte',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff13294B),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
    String hint, {
    IconData? icono,
    String? errorTexto,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorTexto,
      prefixIcon: icono != null ? Icon(icono) : null,
      filled: true,
      fillColor: const Color(0xffF7F7F7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xff148A3A),
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.4,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.8,
        ),
      ),
    );
  }
}

class VistaPreviaImagenLocal extends StatelessWidget {
  final File imagen;

  const VistaPreviaImagenLocal({
    super.key,
    required this.imagen,
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
              child: Image.file(imagen),
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
                      'Vista previa',
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