import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final IconData icon;
  String status; // "todo", "inProgress", "done"
  final String creatorId;
  final List<String> sharedWith;
  final DateTime createdAt;
  DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.icon,
    required this.status,
    required this.creatorId,
    this.sharedWith = const [],
    required this.createdAt,
    this.updatedAt,
  });

  Task copyWith({String? status}) {
    return Task(
      id: id,
      title: title,
      icon: icon,
      status: status ?? this.status,
      creatorId: creatorId,
      sharedWith: sharedWith,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': title,
      'icone': icon.codePoint,
      'status': status,
      'criadorId': creatorId,
      'usuariosCompartilhados': sharedWith,
      'dataCriacao': createdAt,
      'dataAtualizacao': updatedAt,
    };
  }

  // Criar Task a partir de Map do Firestore
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['titulo'] ?? '',
      icon: IconData(
        map['icone'] ?? Icons.check_box_outline_blank.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      status: map['status'] ?? 'todo',
      creatorId: map['criadorId'] ?? '',
      sharedWith: List<String>.from(map['usuariosCompartilhados'] ?? []),
      createdAt: (map['dataCriacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['dataAtualizacao'] as Timestamp?)?.toDate(),
    );
  }
}