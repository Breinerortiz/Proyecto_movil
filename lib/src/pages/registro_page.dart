import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController claveCtrl = TextEditingController();
  final TextEditingController confirmarClaveCtrl = TextEditingController();

  final ScrollController scrollCtrl = ScrollController();

  bool ocultarClave = true;
  bool ocultarConfirmarClave = true;
  bool cargando = false;

  String? errorNombre;
  String? errorCorreo;
  String? errorClave;
  String? errorConfirmarClave;

  late AnimationController animCtrl;
  late Animation<double> fadeAnim;
  late Animation<Offset> slideAnim;

  @override
  void initState() {
    super.initState();

    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: animCtrl, curve: Curves.easeInOut),
    );

    slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animCtrl, curve: Curves.easeOut),
    );

    animCtrl.forward();

    nombreCtrl.addListener(() {
      if (errorNombre != null) validarNombre();
    });

    correoCtrl.addListener(() {
      if (errorCorreo != null) validarCorreo();
    });

    claveCtrl.addListener(() {
      if (errorClave != null || errorConfirmarClave != null) {
        validarClave();
        validarConfirmarClave();
      }
    });

    confirmarClaveCtrl.addListener(() {
      if (errorConfirmarClave != null) validarConfirmarClave();
    });
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    correoCtrl.dispose();
    claveCtrl.dispose();
    confirmarClaveCtrl.dispose();
    scrollCtrl.dispose();
    animCtrl.dispose();
    super.dispose();
  }

  bool validarNombre() {
    String nombre = nombreCtrl.text.trim();

    if (nombre.isEmpty) {
      errorNombre = 'El nombre es obligatorio';
      return false;
    }

    if (nombre.length < 3) {
      errorNombre = 'Ingresa un nombre válido';
      return false;
    }

    errorNombre = null;
    return true;
  }

  bool validarCorreo() {
    String correo = correoCtrl.text.trim();

    if (correo.isEmpty) {
      errorCorreo = 'El correo es obligatorio';
      return false;
    }

    if (!correo.contains('@') || !correo.contains('.')) {
      errorCorreo = 'Ingresa un correo válido';
      return false;
    }

    errorCorreo = null;
    return true;
  }

  bool validarClave() {
    String clave = claveCtrl.text.trim();

    if (clave.isEmpty) {
      errorClave = 'La contraseña es obligatoria';
      return false;
    }

    if (clave.length < 6) {
      errorClave = 'Debe tener mínimo 6 caracteres';
      return false;
    }

    errorClave = null;
    return true;
  }

  bool validarConfirmarClave() {
    String clave = claveCtrl.text.trim();
    String confirmar = confirmarClaveCtrl.text.trim();

    if (confirmar.isEmpty) {
      errorConfirmarClave = 'Debes confirmar la contraseña';
      return false;
    }

    if (clave != confirmar) {
      errorConfirmarClave = 'Las contraseñas no coinciden';
      return false;
    }

    errorConfirmarClave = null;
    return true;
  }

  bool validarFormulario() {
    bool nombreOk = validarNombre();
    bool correoOk = validarCorreo();
    bool claveOk = validarClave();
    bool confirmarOk = validarConfirmarClave();

    setState(() {});

    return nombreOk && correoOk && claveOk && confirmarOk;
  }

  void mostrarMensaje(String texto, {Color? color}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: color,
      ),
    );
  }

  Future<void> mostrarDialogoRegistroExitoso({
    required String nombre,
  }) async {
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
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff148A3A).withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
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
                  '¡Registro exitoso!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff13294B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff0B1B33),
                  ),
                ),
                const SizedBox(height: 12),
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
                    'Usuario registrado',
                    style: TextStyle(
                      color: Color(0xff148A3A),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'La cuenta fue creada correctamente en el sistema institucional.',
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
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;

                      Navigator.pop(context);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
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
                      'Ir al login',
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

  Future<void> registrarUsuario() async {
    if (cargando) return;
    if (!validarFormulario()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      cargando = true;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoCtrl.text.trim(),
        password: claveCtrl.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({
        'nombre': nombreCtrl.text.trim(),
        'correo': correoCtrl.text.trim(),
        'esAdmin': false,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      String nombre = nombreCtrl.text.trim();

      nombreCtrl.clear();
      correoCtrl.clear();
      claveCtrl.clear();
      confirmarClaveCtrl.clear();

      if (!mounted) return;

      await mostrarDialogoRegistroExitoso(nombre: nombre);
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al registrar';

      if (e.code == 'email-already-in-use') {
        msg = 'Ese correo ya está registrado';
      } else if (e.code == 'invalid-email') {
        msg = 'Correo inválido';
      } else if (e.code == 'weak-password') {
        msg = 'La contraseña debe tener mínimo 6 caracteres';
      } else if (e.code == 'operation-not-allowed') {
        msg = 'Debes activar Email/Password en Firebase';
      } else if (e.code == 'network-request-failed') {
        msg = 'Error de conexión a internet';
      }

      mostrarMensaje(msg);
    } catch (e) {
      mostrarMensaje('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void volverLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void irArriba() {
    scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  InputDecoration estiloInput({
    required String hint,
    required IconData icono,
    Widget? suffixIcon,
    String? errorTexto,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorTexto,
      filled: true,
      fillColor: const Color(0xffF7F7F7),
      prefixIcon: Icon(icono),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
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
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  Widget campoTitulo(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F8),
      floatingActionButton: FloatingActionButton(
        onPressed: irArriba,
        backgroundColor: const Color(0xff148A3A),
        child: const Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: Center(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: const Color(0xff13294B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff148A3A),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Universidad de la Amazonia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff13294B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sistema Institucional de Reporte de Incidentes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xff148A3A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea una cuenta para ingresar al sistema institucional',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 42),
                    Container(
                      padding: const EdgeInsets.all(22),
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
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          campoTitulo('Nombre completo'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: nombreCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: estiloInput(
                              hint: 'Ingresa tu nombre completo',
                              icono: Icons.person_outline,
                              errorTexto: errorNombre,
                            ),
                          ),
                          const SizedBox(height: 20),
                          campoTitulo('Correo institucional'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: correoCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: estiloInput(
                              hint: 'correo@udla.edu.co',
                              icono: Icons.email_outlined,
                              errorTexto: errorCorreo,
                            ),
                          ),
                          const SizedBox(height: 20),
                          campoTitulo('Contraseña'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: claveCtrl,
                            obscureText: ocultarClave,
                            decoration: estiloInput(
                              hint: 'Mínimo 6 caracteres',
                              icono: Icons.lock_outline,
                              errorTexto: errorClave,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  ocultarClave
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    ocultarClave = !ocultarClave;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          campoTitulo('Confirmar contraseña'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: confirmarClaveCtrl,
                            obscureText: ocultarConfirmarClave,
                            decoration: estiloInput(
                              hint: 'Repite tu contraseña',
                              icono: Icons.lock_reset_outlined,
                              errorTexto: errorConfirmarClave,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  ocultarConfirmarClave
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    ocultarConfirmarClave =
                                        !ocultarConfirmarClave;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: cargando ? null : registrarUsuario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff13294B),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: cargando
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: cargando ? null : volverLogin,
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(
                              color: Color(0xff148A3A),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 45),
                    Text(
                      'Universidad de la Amazonia · Versión 1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}