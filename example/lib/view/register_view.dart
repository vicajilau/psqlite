import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../view_model/register_view_model.dart';
import 'components/my_text_button.dart';
import 'components/my_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final viewModel = RegisterViewModel();
  final userIdentifierTypeController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Register Screen'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        MyTextField(
                          hintText: 'Identifier',
                          inputType: TextInputType.text,
                          editingController: userIdentifierTypeController,
                          labelText: 'Identifier',
                        ),
                        MyTextField(
                          hintText: 'Name',
                          inputType: TextInputType.text,
                          editingController: nameController,
                          labelText: 'Name',
                        ),
                        MyTextField(
                          hintText: 'Last Name',
                          inputType: TextInputType.text,
                          editingController: lastNameController,
                          labelText: 'Last Name',
                        ),
                        MyTextField(
                          hintText: 'Age',
                          inputType: TextInputType.number,
                          editingController: ageController,
                          labelText: 'Age',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyTextButton(
                    buttonName: 'REGISTER',
                    onTap: () async => registerButtonWasPressed(
                        userIdentifierTypeController.text.trim().toUpperCase(),
                        nameController.text.trim().toUpperCase(),
                        lastNameController.text.trim().toUpperCase(),
                        ageController.text.trim().toUpperCase()),
                    bgColor: Colors.blue,
                    textColor: Colors.white,
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void registerButtonWasPressed(
      String userID, String name, String lastname, String age) async {
    final navigator = Navigator.of(context);
    EasyLoading.show();
    try {
      final user =
          await viewModel.registerUser(userID, name, lastname, int.parse(age));
      EasyLoading.dismiss();
      navigator.pop(user);
    } catch (error) {
      EasyLoading.dismiss();
      showMessage('ERROR', error.toString(), 'ACCEPT');
    }
  }

  void showMessage(String title, String subtitle, String button) {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(title: Text(title), content: Text(subtitle), actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          child: Text(button),
        )
      ]),
    );
  }
}
