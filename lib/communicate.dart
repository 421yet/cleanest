import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunshine_cleanest/constants.dart';
import 'package:sunshine_cleanest/send_push_message.dart';

class Communicate extends StatefulWidget {
  final List<Map> sonnims;

  const Communicate(this.sonnims, {super.key});

  @override
  State<Communicate> createState() => _CommunicateState();
}

class _CommunicateState extends State<Communicate> {
  final TextEditingController titleTEC = TextEditingController();
  final TextEditingController bodyTEC = TextEditingController();
  bool titleEnabled = false;
  bool bodyEnabled = false;

  @override
  Widget build(BuildContext context) {
    String titleText = "Message to ${widget.sonnims[0]['name']}";
    int length = widget.sonnims.length;
    if (length > 1) {
      titleText += " & ${widget.sonnims.length - 1} other";
      if (length > 2) titleText += "s";
    }
    titleText += "...";

    return Scaffold(
        appBar: AppBar(
          title: Text(titleText),
          actions: <Widget>[
            DEVICE_TOKEN,
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // TODO Alert Dialog style list of sonnims to whom message being sent? (NO EDIT)
                        Column(children: <Widget>[
                          const Padding(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 8),
                              child: Row(children: <Widget>[
                                Text(
                                  "Notification Title",
                                )
                              ])),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextField(
                                  controller: titleTEC,
                                  onEditingComplete: () {},
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 20),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)))))
                        ]),
                        Column(children: [
                          const Padding(
                              padding: EdgeInsets.only(
                                  left: 8, right: 8, top: 8),
                              child: Row(children: <Widget>[
                                Text(
                                  "Detailed Message",
                                  textAlign: TextAlign.start,
                                )
                              ])),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                controller: bodyTEC,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 20),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                minLines: 7,
                                maxLines: 7,
                              ))
                        ])
                      ]),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(children: [
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: const Text("Irreversible Action"),
                                      content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const Row(children: <Widget>[
                                              Text("Sending notifications is "),
                                              Text("irreversible",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text("!")
                                            ]),
                                            const Text(
                                                "\nPlease confirm the details of this notification once again.\n"),
                                            Row(children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 32),
                                                  child: Text(
                                                    "Title:\n${(titleTEC.text.isEmpty) ? "[ EMPTY! ]" : titleTEC.text}",
                                                    textAlign: TextAlign.left,
                                                  ))
                                            ]),
                                            Row(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 32),
                                                child: Text(
                                                    "Body:\n${(bodyTEC.text.isEmpty) ? "[ EMPTY! ]" : bodyTEC.text}"),
                                              )
                                            ])
                                          ]),
                                      actions: <Widget>[
                                        OutlinedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              String lastErrorMessage = "";
                                              for (Map sonnim
                                                  in widget.sonnims) {
                                                try {
                                                  sendPushMessage(
                                                      sonnim["token"],
                                                      titleTEC.text,
                                                      bodyTEC.text);
                                                } catch (e) {
                                                  lastErrorMessage =
                                                      e.toString();
                                                }
                                              }
                                              // TODO store in database
                                              // TODO tag each notification to each Sonnim?
                                              Navigator.pop(context);
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: (lastErrorMessage
                                                              .isEmpty)
                                                          ? const Text("Yay!",
                                                              style: TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic))
                                                          : const Text("Oops",
                                                              style: TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic)),
                                                      content: (lastErrorMessage
                                                              .isEmpty)
                                                          ? const Text(
                                                              "Selected Sonnims were successfully notified.")
                                                          : Text(
                                                              "Couldn't send notification.\nLast error code: $lastErrorMessage.\nIf this problem continues, consult Frank!"),
                                                      actions: [
                                                        OutlinedButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "OK"))
                                                      ],
                                                    );
                                                  });
                                            },
                                            child:
                                                const Text("Send Notification"))
                                      ]);
                                });
                          },
                          child: const Text("Send"),
                        )),
                      ]))
                ]))));
  }
}
