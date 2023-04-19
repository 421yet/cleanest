import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sunshine_cleanest/communicate.dart';

class NotifySelect extends StatefulWidget {
  const NotifySelect({super.key});
  // static late Map<String, Map> _sonnims;
  // static late List _sonnimsUID;

  Future<Map> _getSonnims() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Sonnims');
    DatabaseEvent event = await ref.once(DatabaseEventType.value);
    Map sonnimsTemp = event.snapshot.value as Map;
    return sonnimsTemp;
  }

  @override
  State<NotifySelect> createState() => _NotifySelectState();
}

class _NotifySelectState extends State<NotifySelect> {
  // List<String> sonnimNames = [];
  Map<String, bool> sonnimChecks = {};
  Map searchResults = {};

  TextEditingController tec = TextEditingController();
  bool isRedundant = false;

  void filterSearchResults(String query, Map sonnims) {
    if (query.isNotEmpty) {
      Map<String, Map> tempResults = {};
      for (String sonnimUID in sonnims.keys) {
        Map sonnim = sonnims[sonnimUID]!;
        if ((sonnim['name'] as String)
            .toLowerCase()
            .contains(query.toLowerCase())) {
          tempResults.putIfAbsent(sonnimUID, () => sonnim);
        }
      }
      setState(() {
        searchResults.clear();
        searchResults.addAll(tempResults);
      });
      return;
    } else {
      setState(() {
        searchResults.clear();
        searchResults.addAll(sonnims);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: widget._getSonnims(),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          Map sonnims = snapshot.data!; // should be fine per ^
          if (!isRedundant) {
            for (String sonnimUID in sonnims.keys) {
              sonnimChecks[sonnimUID] = false;
            }
            searchResults.clear();
            searchResults.addAll(sonnims);
            isRedundant = true;
          }
          // if(kDebugMode) print(sonnimsUID);
          return Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (query) {
                        filterSearchResults(query, sonnims);
                      },
                      controller:
                          tec, // TODO I think this throws an exception when the Android "Swype" is used (1 time)
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: OutlinedButton(
                              onPressed: (sonnimChecks.values
                                      .any((checked) => !checked))
                                  ? () {
                                      setState(() {
                                        sonnimChecks
                                            .updateAll((key, value) => true);
                                      });
                                    }
                                  : null,
                              child: const Text("Select All"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  sonnimChecks
                                      .updateAll((key, value) => !value);
                                });
                              },
                              child: const Text("Invert"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: OutlinedButton(
                                onPressed: (sonnimChecks.values
                                        .any((checked) => checked))
                                    ? () {
                                        setState(() {
                                          sonnimChecks
                                              .updateAll((key, value) => false);
                                        });
                                      }
                                    : null,
                                child: const Text("Deselect All")),
                          ),
                        )
                      ],
                    ),
                  ),
                  // TODO: advanced filters (select days, neighborhood?)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                            color: Colors.black.withAlpha(32),
                            indent: 10,
                            endIndent: 50,
                            height: 0),
                        itemBuilder: (context, index) {
                          String thisSonnimUID =
                              searchResults.keys.toList()[index];
                          String thisSonnimName =
                              searchResults[thisSonnimUID]!['name'];
                          return Row(
                            children: <Widget>[
                              Checkbox(
                                  value: sonnimChecks[thisSonnimUID],
                                  onChanged: (value) {
                                    setState(() {
                                      sonnimChecks[thisSonnimUID] = value!;
                                    });
                                  }),
                              Text(thisSonnimName,
                                  style: const TextStyle(fontSize: 15))
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton(
                          onPressed: (sonnimChecks.values
                                  .toList()
                                  .contains(true))
                              ? () {
                                  List<Map> selectedSonnims = [];
                                  sonnimChecks
                                      .forEach((String sonnimUID, checked) {
                                    if (checked) {
                                      selectedSonnims.add(sonnims[sonnimUID]);
                                    }
                                  });
                                  Navigator.push<void>(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Communicate(selectedSonnims)));
                                }
                              : null,
                          child: const Text("Notify Selected"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: const Text("sum ting wong"),
          );
        } else {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                // color: Colors.transparent,
              ),
            ),
          );
        }
      },
    );
  }
}
