import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../widgets/task_column.dart';
import 'home_screen.dart';

class TaskBoardScreen extends StatefulWidget {
  final String boardId;

  const TaskBoardScreen({super.key, required this.boardId});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBoardData();
  }

  Future<void> _loadBoardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _firestore
          .collection('tarefas')
          .where('quadroId', isEqualTo: widget.boardId)
          .snapshots()
          .listen((snapshot) {
        final tasks = snapshot.docs.map((doc) {
          final data = doc.data();
          return Task.fromMap(data);
        }).toList();

        if (mounted) {
          setState(() {
            _tasks = tasks;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _deleteBoard() async {
    await FirebaseFirestore.instance
        .collection('quadros')
        .doc(widget.boardId)
        .delete();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _firestore.collection('tarefas').doc(taskId).update({
        'status': newStatus,
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar tarefa: $e')),
        );
      }
    }
  }

  List<Task> _getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    IconData selectedIcon = Icons.check_box_outline_blank;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nova Tarefa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título da tarefa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Selecione um ícone:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildIconOption(
                      Icons.checklist_rounded,
                      selectedIcon,
                      (icon) {
                        setState(() => selectedIcon = icon);
                      },
                    ),
                    _buildIconOption(Icons.layers, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.delete_outline, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(
                      Icons.cleaning_services,
                      selectedIcon,
                      (icon) {
                        setState(() => selectedIcon = icon);
                      },
                    ),
                    _buildIconOption(
                      Icons.check_circle_outline,
                      selectedIcon,
                      (icon) {
                        setState(() => selectedIcon = icon);
                      },
                    ),
                    _buildIconOption(Icons.bed, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.school, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.work_outline, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(Icons.pets, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(
                      Icons.shopping_cart_outlined,
                      selectedIcon,
                      (icon) {
                        setState(() => selectedIcon = icon);
                      },
                    ),
                    _buildIconOption(Icons.book, selectedIcon, (icon) {
                      setState(() => selectedIcon = icon);
                    }),
                    _buildIconOption(
                      Icons.lightbulb_outline,
                      selectedIcon,
                      (icon) {
                        setState(() => selectedIcon = icon);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isNotEmpty) {
                    _addTask(titleController.text.trim(), selectedIcon);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIconOption(
    IconData icon,
    IconData selectedIcon,
    Function(IconData) onSelect,
  ) {
    final isSelected = icon == selectedIcon;

    return GestureDetector(
      onTap: () => onSelect(icon),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _addTask(String title, IconData icon) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final taskId = const Uuid().v4();
    final task = Task(
      id: taskId,
      title: title,
      icon: icon,
      status: 'todo',
      creatorId: user.uid,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection('tarefas').doc(taskId).set({
        ...task.toMap(),
        'quadroId': widget.boardId,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar tarefa: $e')),
        );
      }
    }
  }

  Future<void> _showShareBoardDialog() async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartilhar Quadro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email do usuário',
                border: OutlineInputBorder(),
                hintText: 'exemplo@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const Text(
              'O usuário receberá acesso para visualizar e editar este quadro.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.trim().isNotEmpty) {
                _shareBoard(emailController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareBoard(String email) async {
    try {
      final userQuery = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado')),
        );
        return;
      }

      final userId = userQuery.docs.first.id;

      await _firestore.collection('quadros').doc(widget.boardId).update({
        'usuariosCompartilhados': FieldValue.arrayUnion([userId]),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quadro compartilhado com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao compartilhar quadro: $e')),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Quadro'),
        content: const Text('Tem certeza que deseja excluir este quadro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBoard();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 250,
                          child: TaskColumn(
                            title: 'A Fazer',
                            tasks: _getTasksByStatus('todo'),
                            onAccept: (taskId) => _updateTaskStatus(taskId, 'todo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 250,
                          child: TaskColumn(
                            title: 'Em Progresso',
                            tasks: _getTasksByStatus('inProgress'),
                            onAccept: (taskId) => _updateTaskStatus(taskId, 'inProgress'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 250,
                          child: TaskColumn(
                            title: 'Feito',
                            tasks: _getTasksByStatus('done'),
                            onAccept: (taskId) => _updateTaskStatus(taskId, 'done'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('usuarios')
                .doc(_auth.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final userName = userData?['nome'] ?? 'Usuário';

              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF8A7CFF).withOpacity(0.3),
                    radius: 20,
                    child: const Icon(Icons.person, color: Color(0xFF8A7CFF)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareBoardDialog,
            tooltip: 'Compartilhar quadro',
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Color(0xFF8A7CFF), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home, size: 28),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 28, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
    );
  }
}