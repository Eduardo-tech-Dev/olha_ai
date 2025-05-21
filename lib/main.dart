import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Inicialização do app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quadro de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF8A7CFF),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF121212),
          primary: const Color(0xFF8A7CFF),
          secondary: const Color(0xFF4CD964),
          background: const Color(0xFF121212),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Tela de Splash para verificar autenticação
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quadro de Tarefas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Função para realizar login
  // Versão corrigida da função _login

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Primeiro fazer o login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Navegar para a tela inicial se o login foi bem-sucedido
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = switch (e.code) {
            'user-not-found' => 'Usuário não encontrado',
            'wrong-password' => 'Senha incorreta',
            'invalid-email' => 'Email inválido',
            _ => e.message ?? 'Erro ao fazer login',
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro inesperado: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Bem-vindo',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Faça login para acessar suas tarefas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo de email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Mensagem de erro
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Botão de login
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Entrar',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                  const SizedBox(height: 16),

                  // Link para registro
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Não tem uma conta? Registre-se'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Tela de Registro
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Função para registrar usuário
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Criar usuário
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Salvar informações adicionais do usuário
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set({
            'nome': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'dataCriacao': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      // Navegar para a tela inicial
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = switch (e.code) {
            'weak-password' => 'A senha é muito fraca',
            'email-already-in-use' => 'Este email já está em uso',
            'invalid-email' => 'Email inválido',
            _ => e.message ?? 'Erro ao registrar',
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro inesperado: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Crie sua conta',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo de nome
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Mensagem de erro
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Botão de registro
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Registrar',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Tela inicial com lista de quadros
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Função para sair
  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  // Função para criar novo quadro
  Future<void> _createBoard() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String boardTitle = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Novo Quadro'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Digite o nome do quadro'),
            onChanged: (value) {
              boardTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // fecha o dialog sem criar
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (boardTitle.trim().isEmpty) return; // não fecha se vazio
                Navigator.of(context).pop(boardTitle);
              },
              child: Text('Criar'),
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
          // Usuário não está logado, redirecionar para login
          return const LoginScreen();
        }

        // Usuário está logado, agora mostrar os quadros
        return Scaffold(
          appBar: AppBar(
            title: const Text('Meus Quadros'),
            actions: [
              IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
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
                            builder:
                                (_) =>
                                    TaskBoardScreen(boardId: boardData['id']),
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

// Modelo de Tarefa
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

// Tela do Quadro de Tarefas
class TaskBoardScreen extends StatefulWidget {
  final String boardId;

  const TaskBoardScreen({Key? key, required this.boardId}) : super(key: key);

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

  // Carregar dados do quadro e tarefas
  Future<void> _loadBoardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Configurar listener para tarefas
      _firestore
          .collection('tarefas')
          .where('quadroId', isEqualTo: widget.boardId)
          .snapshots()
          .listen((snapshot) {
            final tasks =
                snapshot.docs.map((doc) {
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    }
  }

  // Atualizar status de uma tarefa
  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _firestore.collection('tarefas').doc(taskId).update({
        'status': newStatus,
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar tarefa: $e')));
      }
    }
  }

  // Filtrar tarefas por status
  List<Task> _getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Mostrar diálogo para adicionar tarefa
  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    IconData selectedIcon = Icons.check_box_outline_blank;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
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
                        _buildIconOption(Icons.delete_outline, selectedIcon, (
                          icon,
                        ) {
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
                    ),
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Widget para opção de ícone
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
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
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

  // Adicionar nova tarefa
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao adicionar tarefa: $e')));
      }
    }
  }

  // Mostrar diálogo para compartilhar quadro
  Future<void> _showShareBoardDialog() async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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

  // Compartilhar quadro com outro usuário
  Future<void> _shareBoard(String email) async {
    try {
      // Buscar usuário pelo email
      final userQuery =
          await _firestore
              .collection('usuarios')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userQuery.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuário não encontrado')));
        return;
      }

      final userId = userQuery.docs.first.id;

      // Atualizar quadro com novo usuário compartilhado
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho personalizado
            _buildCustomAppBar(),

            // Conteúdo principal - Colunas de tarefas
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Coluna "A Fazer"
                      Expanded(
                        child: TaskColumn(
                          title: 'A Fazer',
                          tasks: _getTasksByStatus('todo'),
                          onAccept:
                              (taskId) => _updateTaskStatus(taskId, 'todo'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Coluna "Em Progresso"
                      Expanded(
                        child: TaskColumn(
                          title: 'Em Progresso',
                          tasks: _getTasksByStatus('inProgress'),
                          onAccept:
                              (taskId) =>
                                  _updateTaskStatus(taskId, 'inProgress'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Coluna "Feito"
                      Expanded(
                        child: TaskColumn(
                          title: 'Feito',
                          tasks: _getTasksByStatus('done'),
                          onAccept:
                              (taskId) => _updateTaskStatus(taskId, 'done'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Barra de navegação inferior
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

  // Widget para o cabeçalho personalizado
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
          // Avatar do usuário
          StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore
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

                  // Nome do usuário
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

          // Botão de compartilhar
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareBoardDialog,
            tooltip: 'Compartilhar quadro',
          ),

          // Botão de sair
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

  // Widget para a barra de navegação inferior
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
          IconButton(icon: const Icon(Icons.menu, size: 28), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.message, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// Widget para representar uma coluna de tarefas
class TaskColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Function(String) onAccept;

  const TaskColumn({
    Key? key,
    required this.title,
    required this.tasks,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DragTarget<String>(
        builder: (context, candidateData, rejectedData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                child:
                    tasks.isEmpty
                        ? Center(
                          child: Text(
                            'Nenhuma tarefa',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return TaskCard(task: tasks[index]);
                          },
                        ),
              ),
            ],
          );
        },
        onAcceptWithDetails: (details) => onAccept(details.data),
      ),
    );
  }
}

// Widget para representar um cartão de tarefa
class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definir cor do ícone com base no status
    Color iconColor;
    switch (task.status) {
      case 'todo':
        iconColor = const Color(0xFF8A7CFF);
        break;
      case 'inProgress':
        iconColor = const Color(0xFF8A7CFF);
        break;
      case 'done':
        iconColor = const Color(0xFF4CD964);
        break;
      default:
        iconColor = Colors.grey;
    }

    return Draggable<String>(
      // Dados que serão passados quando o item for arrastado
      data: task.id,

      // O que é exibido enquanto arrasta
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 230,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(task.icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // O que aparece no lugar original durante o arrasto
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(task.icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // O widget real
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(task.icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (task.sharedWith.isNotEmpty)
              const Icon(Icons.people, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
