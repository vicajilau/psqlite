import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField(
      {Key? key,
      required this.hintText,
      required this.inputType,
      required this.editingController,
      this.icon,
      this.labelText,
      this.readOnly,
      this.onTap})
      : super(key: key);
  final String hintText;
  final TextInputType inputType;
  final TextEditingController editingController;
  final Widget? icon;
  final String? labelText;
  final bool? readOnly;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        controller: editingController,
        readOnly: readOnly ?? false,
        onTap: onTap,
        decoration: InputDecoration(
          icon: icon,
          labelText: labelText,
          contentPadding: const EdgeInsets.all(20),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
