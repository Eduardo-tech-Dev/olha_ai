import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_card.dart';

class TaskColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Function(String) onAccept;

  const TaskColumn({
    super.key,
    required this.title,
    required this.tasks,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDraggingOver
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDraggingOver
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                  : Colors.grey.withOpacity(0.1),
              width: isDraggingOver ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhuma tarefa',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
          ),
        );
      },
    );
  }
}