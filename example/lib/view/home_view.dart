import 'package:example/view/register_view.dart';
import 'package:example/view/user_detail_view.dart';
import 'package:example/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../services/utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeViewModel viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadUsers().then((value) {
      setState(() {
        Utils.printDebug("${viewModel.getUsers().length} users loaded.");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PSQLite'),
        actions: [
          IconButton(
              onPressed: () async {
                await registerUser();
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: viewModel.numberOfFiles(),
        onReorderStart: (int value) => HapticFeedback.mediumImpact(),
        itemBuilder: (context, position) {
          final user = viewModel.getUsers()[position];
          return Dismissible(
            key: Key("${user.hashCode}"),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              EasyLoading.show();
              await viewModel.removeUser(user);
              EasyLoading.dismiss();
              setState(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${user.getName()}'),
                  ),
                );
              });
            },
            background: Container(
              color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            child: Card(
              child: ListTile(
                  leading: Hero(
                      tag: user.getPrimaryKey(),
                      child: Image.asset('assets/images/user-image.png')),
                  title: Text(user.getName()),
                  subtitle: Text(user.getLastName()),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserDetailView(user: user)));
                  }),
            ),
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) {
            newIndex = newIndex - 1;
          }
          setState(() {
            final element = viewModel.removeUserAt(oldIndex);
            viewModel.insertUserAt(newIndex, element);
          });
        },
      ),
    );
  }

  Future<void> registerUser() async {
    Navigator.pop(context, 'add_user_dialog_manual_button');
    final user = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const RegisterView()));
    if (user != null) {
      await viewModel.addUser(user);
      setState(() {
        Utils.printDebug("User added: $user");
      });
    }
  }
}
