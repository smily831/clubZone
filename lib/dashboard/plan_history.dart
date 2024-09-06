import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanHistory extends StatefulWidget {
  final String phoneNumber;

  const PlanHistory({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<PlanHistory> createState() => _PlanHistoryState();
}

class _PlanHistoryState extends State<PlanHistory> {
  late List<DocumentSnapshot> historyList = [];

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  void fetchHistory() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('history')
        .where('phoneNumber', isEqualTo: widget.phoneNumber)
        .orderBy('date', descending: true) // Order by date in descending order
        .orderBy('time', descending: true)
        .get();

    setState(() {
      historyList = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Color(0xff124076),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          var history = historyList[index];
          Color tileColor = index % 2 == 0 ? Colors.grey[200]! : Colors.white;
          // Here you can create a widget to display each item in the historyList
          return Container(
            color: tileColor,
            child: ListTile(
              title: Text(history['planName']), // Replace 'fieldName' with your field name
              subtitle: Text('${history['date']} at ${history['time']}'),
              // Add more ListTile properties as needed to display your data
            ),
          );
        },
      ),
    );
  }
}