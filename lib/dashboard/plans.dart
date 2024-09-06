import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sutlej_club/dashboard/add_plan.dart';
import 'package:sutlej_club/dashboard/member_register.dart';
import 'package:sutlej_club/dashboard/plan_details.dart';

class PlanPage extends StatefulWidget {
  final String phoneNumber;

  const PlanPage({Key? key,required this.phoneNumber}) : super(key: key);

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late List<Plan> plans = [];

  @override
  void initState() {
    super.initState();
    fetchPlans();
    print(widget.phoneNumber);
  }

  void editPlan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlanPage()),
    );
  }

  void deletePlan(BuildContext context) {
    // Show delete confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Plan'),
        content: Text('Are you sure you want to delete this plan?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () async {
              FirebaseFirestore.instance
                  .collection('plans')
                  .doc() // Assuming category.id is the document ID
                  .delete()
                  .then((_) {
                print("Plan deleted successfully");
              }).catchError((error) {
                print("Failed to delete plan: $error");
              });

              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }

  void fetchPlans() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('plans').get();

      List<Plan> fetchedPlans = querySnapshot.docs.map((doc) {
        return Plan(
          id: doc.id,
          planName: doc['planName'] ?? '',
          description: doc['planDescription'] ?? '',
          amountPay: doc['amountPay'] ?? 0,
          amountGet: doc['amountGet'] ?? 0,
          validity: doc['validity'] ?? 0,

          icon: Icons.card_membership,
          color: Colors.blue,
          onPressed: () {
            // Handle onPressed event if needed
          },
          onDelete: () {
            deletePlan(context); // Pass deletePlan function as callback
          },
          onEdit: () {
            editPlan(context); // Pass editPlan function as callback
          },
          onChoosePlan: () {
            print(doc.id);
            // Handle choosing plan
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanDetails(
                  phoneNumber: widget.phoneNumber,
                  id: doc.id,
                ),
              ),
            );
            print('Plan chosen: ${doc['planName']}');
          },
        );
      }).toList();

      setState(() {
        plans = fetchedPlans;
      });
    } catch (error) {
      print('Error fetching plans: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Plans"),
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
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: [
          // Center(
          //   child: Text(
          //     'CHOOSE YOUR PLAN',
          //     style: TextStyle(
          //       fontSize: 18.0,
          //       fontWeight: FontWeight.w500,
          //       color: Color(0xff124076),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 10.0),


          // Display fetched plans as PlanCard widgets
          ...plans.map((plan) => PlanCard(
            icon: plan.icon,
            color: plan.color,
            planName: plan.planName,
            description: plan.description,
            amountPay: plan.amountPay,
            amountGet: plan.amountGet,
            validity: plan.validity,
            onPressed: plan.onPressed,
            onDelete: plan.onDelete,
            onEdit: plan.onEdit,
            onChoosePlan: plan.onChoosePlan,
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPlanPage()),
          );
        },
        child: Icon(Icons.add, color: Color(0xff124076),),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final Color color;
  final String planName;
  final String description;
  final int amountPay;
  final int amountGet;
  final int validity;
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onChoosePlan;

  const PlanCard({
    required this.color,
    required this.planName,
    required this.description,
    required this.amountPay,
    required this.amountGet,
    required this.validity,
    required this.icon,
    required this.onPressed,
    required this.onDelete,
    required this.onEdit,
    required this.onChoosePlan,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade100,
      surfaceTintColor: Colors.grey.shade50,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.grey.shade800,
                        size: 22.0,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        planName,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          color:Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20,),
                        color: Colors.grey.shade800,
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20,),
                        color: Colors.grey.shade800,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 8.0),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Text('\u2022',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600),
                      ),
                      SizedBox(width: 6,),
                      Text(
                        'Pay ',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        amountPay.toString(),
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      Text(
                        ' \u2192 Get ',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        amountGet.toString(),
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 6.0),

              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text('\u2022',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight : FontWeight.bold,
                        color: Colors.grey.shade600
                    ),
                  ),

                  SizedBox(width: 6),

                  Text('Validity : ',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600
                    ),
                  ),

                  Text(validity.toString(),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    ' days',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),

              Text(
                description,
                style: TextStyle(
                  fontSize: 11.0,
                  color : Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 8.0),

              Container(
                width: MediaQuery.of(context).size.width*0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xff124076),
                ),
                child: ElevatedButton(
                  onPressed: onChoosePlan,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose Plan ",
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Set background color to transparent
                    elevation: 0, // Remove shadow
                    textStyle: TextStyle(fontSize: 16.0), // Adjust text style if needed
                  ),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Plan {
  final String id; // New field for storing the ID
  final Color color;
  final String planName;
  final String description;
  final int amountPay;
  final int amountGet;
  final int validity;
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onChoosePlan;

  Plan({
    required this.id, // Updated constructor
    required this.color,
    required this.planName,
    required this.description,
    required this.amountPay,
    required this.amountGet,
    required this.validity,
    required this.icon,
    required this.onPressed,
    required this.onDelete,
    required this.onEdit,
    required this.onChoosePlan,
  });
}
