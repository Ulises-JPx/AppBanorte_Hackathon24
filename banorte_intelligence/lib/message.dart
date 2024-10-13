import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// @autor Ulises Jaramillo Portilla.

/// Clase que representa un mensaje
class Message {
  final bool isUser; // Indica si el mensaje es del usuario
  final String message; // Contenido del mensaje
  final DateTime date; // Fecha del mensaje

  Message({required this.isUser, required this.message, required this.date});
}

/// Widget que muestra un mensaje en la interfaz
class Messages extends StatelessWidget {
  final bool isUser; // Indica si el mensaje es del usuario
  final String message; // Contenido del mensaje
  final String date; // Fecha del mensaje en formato de cadena

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: isUser ? Radius.circular(10) : Radius.zero,
          topRight: Radius.circular(10),
          bottomRight: isUser ? Radius.zero : Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: isUser ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}