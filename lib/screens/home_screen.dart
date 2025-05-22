import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'login_screen.dart';
import 'task_board_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _createBoard() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String boardTitle = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Quadro'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Digite o nome do quadro'),
            onChanged: (value) {
              boardTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (boardTitle.trim().isEmpty) return;
                Navigator.of(context).pop(boardTitle);
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );

    if (boardTitle.trim().isEmpty) return;

    final boardId = const Uuid().v4();
    await _firestore.collection('quadros').doc(boardId).set({
      'id': boardId,
      'titulo': boardTitle.trim(),
      'criadorId': user.uid,
      'usuariosCompartilhados': [],
      'dataCriacao': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskBoardScreen(boardId: boardId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meus Quadros'),
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('quadros')
                .where('criadorId', isEqualTo: user.uid)
                .orderBy('dataCriacao', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }

              final boards = snapshot.data?.docs ?? [];

              if (boards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.dashboard_customize,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum quadro encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createBoard,
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Quadro'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: boards.length,
                itemBuilder: (context, index) {
                  final board = boards[index];
                  final boardData = board.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(boardData['titulo'] ?? 'Sem título'),
                      leading: const Icon(Icons.dashboard),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskBoardScreen(boardId: boardData['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _createBoard,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}