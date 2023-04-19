import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ErrorPage extends StatefulWidget {
  final String pageFailed2Load;
  const ErrorPage(this.pageFailed2Load, {super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          // TODO [REEE sunflower image],
          Text("There has been an error loading ${widget.pageFailed2Load}. \n "
              "This is most likely due to a connection error. \n "
              "If this problem continues to persist, please contact us by phone or contact Frank. ")
        ]));
  }
}
