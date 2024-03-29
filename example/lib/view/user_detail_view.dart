import 'package:flutter/material.dart';

import '../model/user.dart';

class UserDetailView extends StatefulWidget {
  final User user;

  const UserDetailView({super.key, required this.user});

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.user.getPrimaryKey()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Hero(
              tag: widget.user.getPrimaryKey(),
              child: Image.asset('assets/images/user-image.png')),
        ),
      ),
    );
  }
}
