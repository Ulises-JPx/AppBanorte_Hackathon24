import 'dart:convert';

import 'package:banorte_intelligence/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';

/// @autor Ulises Jaramillo Portilla.

void main() {
  runApp(const MyApp());
}

/// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

/// Pantalla de inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String _correctUsername = 'admin';
  final String _correctPassword = 'admin123';

  /// Función para manejar el inicio de sesión
  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username == _correctUsername && password == _correctPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Usuario o contraseña incorrecta'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFEB0029), // Fondo rojo
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/Banorte.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla del chatbot
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput = TextEditingController();
  ScrollController _scrollController = ScrollController();

  // Usa tu clave de API aquí
  static const apiKey = "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";  // Reemplaza con tu clave de API de OpenAI

  final List<Message> _messages = [];

  /// Función para enviar un mensaje
  Future<void> sendMessage() async {
    final message = _userInput.text;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
    });

    final responseText = await generateResponse(message);

    setState(() {
      _messages.add(Message(isUser: false, message: responseText, date: DateTime.now()));
    });

    _userInput.clear();

    // Desplázate hacia abajo cuando se agregue una nueva respuesta del chatbot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// Función para generar una respuesta del chatbot
  Future<String> generateResponse(String prompt) async {
    final url = Uri.parse('https://api.gemini.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gemini-pro",  // Modelo de OpenAI
        "prompt": prompt,
        "max_tokens": 150,
        "temperature": 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      print('Error: ${response.body}');
      return 'Error generando respuesta';
    }
  }

  /// Función para mostrar el diálogo de nueva conversación
  void _showNewConversationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Iniciar nueva conversación?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
                Navigator.of(context).pop();
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'lib/assets/images/Banorte_Intelligence.png',
            height: 60, // Ajusta el tamaño de la imagen
          ),
        ),
        backgroundColor: Color(0xFFEB0029),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFEB0029),
              ),
              child: Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: Text('Categoría 1'),
              onTap: () {
                // Acción para Categoría 1
              },
            ),
            ListTile(
              title: Text('Categoría 2'),
              onTap: () {
                // Acción para Categoría 2
              },
            ),
            ListTile(
              title: Text('Categoría 3'),
              onTap: () {
                // Acción para Categoría 3
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white, // Color de fondo del contenedor
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 194, 191, 191), // Color de fondo del círculo
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white, // Color del ícono
                    onPressed: _showNewConversationDialog,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white, // Fondo blanco
              child: Stack(
                children: [
                  if (_messages.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/images/Banorte_Intelligence_red.png',
                            width: MediaQuery.of(context).size.width * 0.6, // Ajusta el tamaño de la imagen
                          ),
                          SizedBox(height: 20),
                          DefaultTextStyle(
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.black,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  '¿En qué te puedo ayudar hoy?',
                                  speed: Duration(milliseconds: 100),
                                ),
                              ],
                              isRepeatingAnimation: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController, // Agrega el controlador aquí
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return Messages(
                              isUser: message.isUser,
                              message: message.message,
                              date: DateFormat('HH:mm').format(message.date),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0), // Padding adicional en la parte inferior
                        child: Row(
                          children: [
                            Expanded(
                              flex: 15,
                              child: TextFormField(
                                style: TextStyle(color: Colors.black),
                                controller: _userInput,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Color(0xFF323E48)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Color(0xFF323E48)),
                                  ),
                                  label: Text('Escribe un mensaje...'),
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              padding: EdgeInsets.all(12),
                              iconSize: 30,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Color(0xFF323E48)),
                                foregroundColor: MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all(CircleBorder()),
                                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered)) {
                                      return Color(0xFFDB0026); // Color de hover
                                    }
                                    return null; // Dejar el color por defecto si no está en estado hover
                                  },
                                ),
                              ),
                              onPressed: () {
                                sendMessage();
                              },
                              icon: Icon(Icons.send),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy, color: Colors.white),
            label: 'BI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money, color: Colors.white),
            label: 'Transferencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, color: Colors.white),
            label: 'Mis cuentas',
          ),
        ],
        currentIndex: 0, // Índice del ítem seleccionado
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        backgroundColor: Color(0xFFEB0029),
        onTap: (index) {
          // Acción al seleccionar un ítem
        },
      ),
    );
  }
}

/// Pantalla de perfil
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFEB0029),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text('Vista de Perfil'),
      ),
    );
  }
}