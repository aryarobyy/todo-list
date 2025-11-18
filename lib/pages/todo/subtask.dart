import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:to_do_list/component/util/loading.dart';
import 'package:to_do_list/component/widget/button/button1.dart';
import 'package:to_do_list/component/widget/button/button2.dart';
import 'package:to_do_list/component/widget/card/subtask_card.dart';
import 'package:to_do_list/notifiers/subtask_notifier.dart';

final _textController = TextEditingController();

class Subtask extends ConsumerStatefulWidget {
  final String creatorId;
  final String todoId;

  const Subtask({
    required this.creatorId,
    required this.todoId,
    super.key
  });

  @override
  ConsumerState createState() => _SubtaskState();
}

class _SubtaskState extends ConsumerState<Subtask> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subTaskNotifierProvider.notifier).getSubTask(
        creatorId: widget.creatorId,
        todoId: widget.todoId
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subTaskNotifierProvider);
    final subtasks = state.subTasks;
    final notifier = ref.read(subTaskNotifierProvider.notifier);

    return state.isLoading
      ? Loading()
      : subtasks == null || subtasks.isEmpty
      ? Column(
        children: [
          Spacer(),
          _buildCard(context),
        ],
      )
    : Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: subtasks.length,
              itemBuilder: (context, index) {
                final subtask = subtasks[index];
                return SubtaskCard(
                  creatorId: widget.creatorId,
                  todoId: widget.todoId,
                  subtaskId: subtask.id,
                );
              },
            ),
          ),
          _buildCard(context)
        ],
      ),
    );
  }

  Widget _buildAddSubtask(BuildContext context) {
    final notifier = ref.watch(subTaskNotifierProvider.notifier);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: SizedBox(
        height: 200,
        child: Center(
          child: _buildCard(context)
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final state = ref.watch(subTaskNotifierProvider);
    final subtask = state.subTask;
    final notifier = ref.read(subTaskNotifierProvider.notifier);

    void addSubtask() async {
      try{
       await notifier.createSubTask(
          creatorId: widget.creatorId,
          text: _textController.text,
          todoId: widget.todoId
        );
      } catch (e) {
        print(e);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _textController,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              hintText: "Masukkan teks di sini...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (value) {

            },
          ),
          const SizedBox(height: 12),
          MyButton1(
            text: "Simpan",
            onPressed: addSubtask
          )
        ],
      ),
    );
  }
}
