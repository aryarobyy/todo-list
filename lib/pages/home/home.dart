import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/component/size/size_config.dart';
import 'package:to_do_list/component/widget/button/button1.dart';
import 'package:to_do_list/component/widget/card/note_card.dart';
import 'package:to_do_list/component/util/text.dart';
import 'package:to_do_list/component/widget/card/todo_card.dart';
import 'package:to_do_list/models/index.dart';
import 'package:to_do_list/notifiers/category_notifier.dart';
import 'package:to_do_list/notifiers/note_notifier.dart';
import 'package:to_do_list/notifiers/todo_notifier.dart';
import 'package:to_do_list/pages/home/category_setting.dart';
import 'package:to_do_list/pages/profile/profile.dart';
import 'package:flutter_riverpod/legacy.dart';

final navLoadingProvider = StateProvider<bool>((ref) => false);
final navTitleProvider = StateProvider<String>((ref) => "All");
final loadingNavProvider = StateProvider<String?>((ref) => null);

class Home extends ConsumerStatefulWidget {
  final UserModel userData;
  const Home({super.key, required this.userData});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && widget.userData.id.isNotEmpty) {
        await ref
          .read(categoryNotifierProvider.notifier)
          .categoryByCreator(widget.userData.id);
        await ref
          .watch(todoNotifierProvider.notifier)
          .getTodosByCreator(creatorId: widget.userData.id);
      }
    });
  }

  void _handleNavChange(String newTitle) async {
    final currentTitle = ref.read(navTitleProvider);
    if (newTitle == currentTitle) return;

    ref.read(navTitleProvider.notifier).state = newTitle;
    ref.read(loadingNavProvider.notifier).state = newTitle;

    if (newTitle == "All") {
      await ref
        .read(noteNotifierProvider.notifier)
        .noteByCreator(widget.userData.id);
    } else {}

    ref.read(loadingNavProvider.notifier).state = null;
  }

  Future<void> _createCategory() async {
    final notifier = ref.read(categoryNotifierProvider.notifier);
    try{
      await notifier.addCategory(creatorId: widget.userData.id, title: _categoryController.text);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isNavLoading = ref.watch(navLoadingProvider);
    final noteState = ref.watch(noteNotifierProvider);
    final catState = ref.watch(categoryNotifierProvider);
    final navTitle = ref.watch(navTitleProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: isNavLoading == false && noteState.isLoading ?
      const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)
          )
      ) :
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText(
                          "Welcome back",
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          widget.userData.username,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                              ProfilePage(
                                userData: widget.userData,
                              ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: cs.primary.withOpacity(0.4),
                        backgroundImage: widget.userData.image != null &&
                            widget.userData.image!.isNotEmpty
                            ? NetworkImage(widget.userData.image!)
                            : const AssetImage("assets/bayu.jpg")
                        as ImageProvider,
                        onBackgroundImageError: (_, __) {},
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const NoteCard(
                title: "Bayu Nikah",
                subtitle: "Besok",
              ),
              const SizedBox(height: 15),
              _buildNav(context),
              const SizedBox(height: 15),
              const MyText(
                "Your Activities",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              _buildTodo(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNav(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final navTitle = ref.watch(navTitleProvider);
    final state = ref.watch(categoryNotifierProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navLoadingProvider.notifier).state = state.isLoading;
      }
    });

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyButton1(
            isTapped: navTitle == 'All',
            text: "All",
            onPressed: () => _handleNavChange("All"),
          ),
          const SizedBox(width: 8),

          if (state.categories != null && state.categories!.isNotEmpty)
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.categories!.length,
                itemBuilder: (BuildContext context, int index) {
                  final category = state.categories![index];

                  if (category.title == "All") return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MyButton1(
                      text: category.title,
                      isTapped: navTitle == category.title,
                      onPressed: () => _handleNavChange(category.title),
                    ),
                  );
                },
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 8),

          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CategorySetting(
                    categories: state.categories,
                    userData: widget.userData,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: cs.surface,
              ),
              child: Icon(Icons.settings, color: cs.onSurface, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCat(BuildContext context){
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      content: Container(
        width: 250,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
        ),
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Text("Add your category"),
                  Spacer(),
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.cancel)
                  )
                ],
              ),
              SizedBox(height: 20,),
              TextField(
                controller: _categoryController,
                style: TextStyle(
                  fontSize: 20
                ),
                decoration: InputDecoration(
                  labelText: "Kiriiik"
                ),
              ),
              SizedBox(height: 30,),
              MyButton1(
                text: "Create",
                onPressed: _createCategory
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _buildTodo(BuildContext context){
    final state = ref.watch(todoNotifierProvider);
    final todos = state.todos ?? [];

    return Expanded(
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final TodoModel todo = todos[index];
          return TodoCard(
            todo: todo,
            creatorId: widget.userData.id,
          );
        }
      )
    );
  }
}