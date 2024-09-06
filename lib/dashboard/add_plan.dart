import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPlanPage extends StatefulWidget {
  final DocumentSnapshot? planData;
  final String? planId; // Make categoryData nullable

  const AddPlanPage({Key? key, this.planData, this.planId})
      : super(key: key);

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  bool showLoader = false;

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController payController;
  late TextEditingController getController;
  late TextEditingController validityController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: widget.planData != null ? widget.planData!['planName'] : '');
    descriptionController = TextEditingController(
        text: widget.planData != null
            ? widget.planData!['planDescription']
            : '');
    payController = TextEditingController(
        text: widget.planData != null
            ? widget.planData!['amountPay'].toString()
            : '');
    getController = TextEditingController(
        text: widget.planData != null
            ? widget.planData!['amountGet'].toString()
            : '');
    validityController = TextEditingController(
        text: widget.planData != null
            ? widget.planData!['validity'].toString()
            : '');
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    payController.dispose();
    getController.dispose();
    validityController.dispose();
    super.dispose();
  }

  // Modify this function to update an existing category
  void updatePlan() async {
    try {
      setState(() {
        showLoader = true;
      });

      final planRef = FirebaseFirestore.instance
          .collection("plans")
          .doc(widget.planData!.id);

      await planRef.update({
        "planName": nameController.text.trim(),
        "planDescription": descriptionController.text.trim(),
        "amountPay": int.parse(payController.text.trim()),
        "amountGet": int.parse(getController.text.trim()),
        "validity": int.parse(validityController.text.trim()),
      });

      setState(() {
        showLoader = false;
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error updating plans: $e");
      setState(() {
        showLoader = false;
      });
    }
  }

  // Modify this function to add a new category
  void addplan() async {
    try {
      setState(() {
        showLoader = true; // Show loader when adding category
      });

      var planRef = await FirebaseFirestore.instance.collection("plans").add(
        {
          "planName": nameController.text.trim(),
          "planDescription": descriptionController.text.trim(),
          "amountPay": int.parse(payController.text.trim()),
          "amountGet": int.parse(getController.text.trim()),
          "validity": int.parse(validityController.text.trim()),
        },
      );
      String planId = planRef.id;
      await planRef.update({"id": planId});

      setState(() {
        showLoader = false;
      });

      Navigator.pop(context);
      setState(() {
        showLoader = false; // Hide loader after category is added
      });
    } catch (e) {
      print("Error adding plans: $e");
      setState(() {
        showLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Plans"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: showLoader
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      )
          : SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 650) {
              return Center(
                child: Container(
                  width: 950,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter plan name',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500,
                        ),
                        controller: nameController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 171, 45),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: "Plan Name",
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 193, 189, 189),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Enter Plan Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500,
                        ),
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 20, 171, 45),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: 'Plan Description',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 193, 189, 189),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Color.fromARGB(255, 20, 171, 45),
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 18),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () {
                            widget.planData != null
                                ? updatePlan()
                                : addplan();
                          },
                          child: widget.planData != null
                              ? const Text("Update Plan")
                              : const Text("Add Plan"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.0),
                      Text(
                        'Enter Plan Name',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: nameController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Plan Name",
                          // Hint text
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.75)),
                          // Opacity for hint text
                          border: InputBorder.none,
                          // Remove border
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Enter Plan Description',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Plan Description",
                          // Hint text
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.75)),
                          // Opacity for hint text
                          border: InputBorder.none,
                          // Remove border
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Amount Pay',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: payController,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Amount Pay",
                          // Hint text
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.75)),
                          // Opacity for hint text
                          border: InputBorder.none,
                          // Remove border
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Amount Get',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: getController,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Amount Get",
                          // Hint text
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.75)),
                          // Opacity for hint text
                          border: InputBorder.none,
                          // Remove border
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Validity',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: validityController,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Validity in days",
                          // Hint text
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.75)),
                          // Opacity for hint text
                          border: InputBorder.none,
                          // Remove border
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 18, vertical: 18),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onPressed: () {
                            widget.planData != null
                                ? updatePlan()
                                : addplan();
                          },
                          child: widget.planData != null
                              ? const Text("Update Plan")
                              : const Text("Add Plan"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}