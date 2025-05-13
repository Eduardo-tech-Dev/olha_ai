import 'package:flutter/material.dart';

void main() {
  runApp(const TrelloCloneApp());
}

class TrelloCloneApp extends StatelessWidget {
  const TrelloCloneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trello Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF673AB7),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: const Color(0xFF9C27B0),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class Task {
  final String name;
  Color color;
  final IconData icon;

  Task(this.name, this.color, this.icon);
}

class TaskMove {
  final Task task;
  final List<Task> sourceList;

  TaskMove(this.task, this.sourceList);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color primaryColor = const Color(0xFF673AB7);
  final Color backgroundColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color accentColor = const Color(0xFF9C27B0);
  final Color textColor = Colors.white;

  final List<Task> predefinedTasks = [
    Task('Arrumar a cama', const Color(0xFF673AB7), Icons.bed),
    Task('Levar o cão para passear', const Color(0xFF673AB7), Icons.pets),
    Task('Varrer o chão', const Color(0xFF673AB7), Icons.cleaning_services),
    Task('Lavar a louça', const Color(0xFF1B5E20), Icons.local_dining),
    Task('Dobrar a roupa', const Color(0xFF1B5E20), Icons.checkroom),
    Task('Guardar os brinquedos', const Color(0xFF9C27B0), Icons.toys),
  ];

  final List<Task> todoTasks = [];
  final List<Task> inProgressTasks = [];
  final List<Task> doneTasks = [];

  @override
  void initState() {
    super.initState();
    // Adiciona algumas tarefas iniciais
    todoTasks.addAll(predefinedTasks.sublist(0, 3));
    inProgressTasks.addAll(predefinedTasks.sublist(4, 5));
    doneTasks.addAll(predefinedTasks.sublist(3, 4));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor.withOpacity(0.9),
                backgroundColor.withOpacity(0.5),
                backgroundColor.withOpacity(0.2),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarefas Domésticas',
                    style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: primaryColor,
                        radius: 12,
                        child: Text('M', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text('maria@exemplo.com', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12)),
                    ],
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saindo...'), backgroundColor: primaryColor),
                  );
                },
                icon: Icon(Icons.logout, color: textColor.withOpacity(0.7)),
                label: Text('Sair', style: TextStyle(color: textColor.withOpacity(0.7))),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 100, left: 8, right: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskColumn('A FAZER', todoTasks, primaryColor),
            _buildTaskColumn('EM ANDAMENTO', inProgressTasks, accentColor),
            _buildTaskColumn('CONCLUÍDO', doneTasks, const Color(0xFF1B5E20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskColumn(String title, List<Task> tasks, Color headerColor) {
  return Flexible(
    flex: 1,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DragTarget<TaskMove>(
              builder: (context, candidateData, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty ? headerColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: candidateData.isNotEmpty
                        ? Border.all(color: headerColor.withOpacity(0.5), width: 2)
                        : null,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildDraggableTask(tasks[index], tasks, title);
                    },
                  ),
                );
              },
              onWillAccept: (data) => data != null && data.sourceList != tasks,
              onAccept: (taskMove) {
                setState(() {
                  taskMove.sourceList.remove(taskMove.task);
                  if (title == 'A FAZER') {
                    taskMove.task.color = primaryColor;
                  } else if (title == 'EM ANDAMENTO') {
                    taskMove.task.color = accentColor;
                  } else {
                    taskMove.task.color = const Color(0xFF1B5E20);
                  }
                  tasks.add(taskMove.task);
                });
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDraggableTask(Task task, List<Task> sourceList, String columnName) {
  return Draggable<TaskMove>(
    data: TaskMove(task, sourceList),
    feedback: Material(
      color: Colors.transparent,
      child: IntrinsicWidth(
        child: _buildTaskCard(task),
      ),
    ),
    childWhenDragging: Opacity(
      opacity: 0.3,
      child: _buildTaskCard(task),
    ),
    child: _buildTaskCard(task),
  );
}

Widget _buildTaskCard(Task task) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 2,
    color: task.color,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(task.icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.name,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showAddTaskDialog() {
    Task selectedPredefinedTask = predefinedTasks[0];
    String selectedColumn = 'A FAZER';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text('Adicionar Tarefa', style: TextStyle(color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Task>(
                value: selectedPredefinedTask,
                dropdownColor: cardColor,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                ),
                items: predefinedTasks.map((task) {
                  return DropdownMenuItem(
                    value: task,
                    child: Row(
                      children: [
                        Icon(task.icon, color: textColor),
                        const SizedBox(width: 8),
                        Text(task.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedPredefinedTask = value!;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedColumn,
                dropdownColor: cardColor,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                ),
                items: [
                  DropdownMenuItem(value: 'A FAZER', child: Text('A FAZER')),
                  DropdownMenuItem(value: 'EM ANDAMENTO', child: Text('EM ANDAMENTO')),
                  DropdownMenuItem(value: 'CONCLUÍDO', child: Text('CONCLUÍDO')),
                ],
                onChanged: (value) {
                  selectedColumn = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: accentColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text('Adicionar'),
              onPressed: () {
                setState(() {
                  final newTask = Task(
                    selectedPredefinedTask.name,
                    selectedPredefinedTask.color,
                    selectedPredefinedTask.icon,
                  );
                  if (selectedColumn == 'A FAZER') {
                    newTask.color = primaryColor;
                    todoTasks.add(newTask);
                  } else if (selectedColumn == 'EM ANDAMENTO') {
                    newTask.color = accentColor;
                    inProgressTasks.add(newTask);
                  } else {
                    newTask.color = const Color(0xFF1B5E20);
                    doneTasks.add(newTask);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}