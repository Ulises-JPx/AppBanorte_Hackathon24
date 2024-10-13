import 'dart:convert';

import 'package:banorte_intelligence/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(const MyApp());
}

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
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput = TextEditingController();
  ScrollController _scrollController = ScrollController();

  // Use your OpenAI API key here
  static const apiKey = "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";  // Replace with your actual OpenAI API key

  final List<Message> _messages = [];

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

  Future<String> generateResponse(String prompt) async {
    final url = Uri.parse('https://api.gemini.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gemini-pro",  // OpenAI model
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
      return 'Error generating response';
    }
  }

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
                                  label: Text('Enter Your Message'),
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
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, color: Colors.white),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school, color: Colors.white),
            label: 'School',
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