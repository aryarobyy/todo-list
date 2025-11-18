import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:to_do_list/notifiers/subtask_notifier.dart';

final checkedProvider = StateProvider<bool>((ref) => false);

class SubtaskCard extends ConsumerStatefulWidget {
  final String creatorId;
  final String todoId;
  final String subtaskId;

  const SubtaskCard({
    super.key,
    required this.creatorId,
    required this.todoId,
    required this.subtaskId,
  });

  @override
  ConsumerState<SubtaskCard> createState() => _SubtaskCardState();
}

class _SubtaskCardState extends ConsumerState<SubtaskCard> {
  @override
  void initState() {
    Future.microtask(() {
      ref.read(subTaskNotifierProvider.notifier).getSubTaskById(
        creatorId: widget.creatorId,
        todoId: widget.todoId,
        subtaskId: widget.subtaskId,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isChecked = ref.watch(checkedProvider);
    final state = ref.watch(subTaskNotifierProvider);
    final subtask = state.subTask;

    if (subtask == null){
      return SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (value) {
              ref.read(checkedProvider.notifier).state = value!;
            },
          ),
          Expanded(
            child: Text(
              subtask.text,
              style: TextStyle(
                fontSize: 16,
                decoration:
                isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                color: isChecked ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
