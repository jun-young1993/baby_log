import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JoinCodeField extends StatelessWidget {
  List<String> codes;
  List<TextEditingController>? controllers;
  List<FocusNode>? focusNodes;
  Function(String, int)? onChanged;
  Function(String, int)? onSubmitted;
  bool isReadOnly = false;
  JoinCodeField({
    super.key,
    required this.codes,
    this.controllers,
    this.focusNodes,
    this.onChanged,
    this.onSubmitted,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(codes.length, (index) {
        final isSmallScreen = MediaQuery.of(context).size.width < 400;

        return Container(
          width: isSmallScreen ? 32 : 36,
          height: isSmallScreen ? 40 : 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: codes[index].isNotEmpty
                  ? Colors.blue
                  : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
            color: codes[index].isNotEmpty
                ? Colors.blue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
          ),
          child: TextField(
            controller: isReadOnly ? null : controllers?[index],
            focusNode: isReadOnly ? null : focusNodes?[index],
            decoration: isReadOnly
                ? InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 10,
                      horizontal: 4,
                    ),
                    hintText: isReadOnly
                        ? codes[index]
                        : null, // ReadOnly일 때만 코드 표시
                    hintStyle: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // 진한 색상으로 명확하게 표시
                      height: 1.0,
                    ),
                  )
                : InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 10,
                      horizontal: 4,
                    ),
                  ),
            textAlign: TextAlign.center,
            readOnly: isReadOnly,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
            keyboardType: TextInputType.text,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            onChanged: (value) {
              onChanged?.call(value, index);
              if (value.isNotEmpty && index < 5) {
                focusNodes?[index + 1].requestFocus();
              }
            },
            onSubmitted: (value) {
              if (value.isNotEmpty && index < 5) {
                focusNodes?[index + 1].requestFocus();
              }
            },
            onTap: () {
              if (codes[index].isEmpty) {
                controllers?[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: controllers?[index].text.length ?? 0),
                );
              }
            },
          ),
        );
      }),
    );
  }
}
