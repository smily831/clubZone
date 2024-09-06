import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sutlej_club/dashboard/bill_page.dart';
import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:sutlej_club/dashboard/profile_page.dart';
import 'package:sutlej_club/globals.dart' as globals;

class SellProduct extends StatefulWidget {
  final String phoneNumber;

  SellProduct({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<SellProduct> createState() => _SellProductState();
}

class _SellProductState extends State<SellProduct> {
  List<String> categories = [];
  List<Map<String, dynamic>> totalproducts = [];
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchProducts();
  }

  void fetchCategories() async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('categories').get();

    List<String> fetchedCategories = [];

    querySnapshot.docs.forEach((doc) {
      String categoryName = doc['categoryName'];
      String categoryID = doc.id;
      fetchedCategories.add('$categoryID: $categoryName');
    });

    setState(() {
      categories = fetchedCategories;
    });
  }

  void fetchProducts() async {
    var querySnapshots =
    await FirebaseFirestore.instance.collectionGroup('products').get();
    List<Map<String, dynamic>> fetchedProducts = [];
    querySnapshots.docs.forEach((doc) {
      fetchedProducts.add(doc.data());
    });
    setState(() {
      totalproducts = fetchedProducts;
      updateProducts();
    });
  }

  void updateProducts() {
    if (_selectedCategory != null) {
      List<Map<String, dynamic>> filteredProducts = totalproducts
          .where((product) => product['CategoryId'] == _selectedCategory)
          .toList();
      setState(() {
        products = filteredProducts;
      });
    } else {
      setState(() {
        products = totalproducts;
      });
    }
  }

  Widget buildCategorySlider() {
    return categories.isEmpty
        ? Center(
      child: CircularProgressIndicator(
        color: Colors.blue,
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            ' Select Category:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        SizedBox(height: 5),
        Container(
          height: 30,
          
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              // Check if the current category is selected
              bool isSelected =
                  _selectedCategory == categories[index].split(':')[0];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (isSelected) {
                          return Colors.blue.shade100; // Change color to blue if selected
                        }
                        return Colors.white; // Default color
                      },
                    ),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Color(0xff124076)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Color(0xff124076)), // Blue border
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      // Update selected category
                      _selectedCategory = isSelected
                          ? null
                          : categories[index].split(':')[0];
                      updateProducts();
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            categories[index].split(':')[1],
                            style: TextStyle(
                              fontSize: 15.0,
                              color: isSelected ? Color(0xff124076) : Color(0xff124076),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected) // Show the icon if category is selected
                        Row(
                          children: [
                            SizedBox(width: 5,),
                            Icon(Icons.clear, size: 15,color: Color(0xff124076) ,),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  String? _selectedCategory;

  Widget buildProductCards() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 0.0,
          mainAxisSpacing: 0.0,
          childAspectRatio: 2.0,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onProductAdded: (productId, quantity) {
              updateProductList(productId, quantity);
            },
            updateTotalQuantity: (quantity) {
              setState(() {
                globals.totalQuantity += quantity;
              });
            },
          );
        },
      ),
    );
  }

  void onProductAdded(String productId, int quantity) {
    setState(() {
      if (quantity == 0) {
        globals.productList.removeWhere((item) => item['productId'] == productId);
      } else {
        bool found = false;
        for (int i = 0; i < globals.productList.length; i++) {
          if (globals.productList[i]['productId'] == productId) {
            globals.productList[i]['quantity'] = quantity;
            found = true;
            break;
          }
        }
        if (!found) {
          globals.productList.add({
            'productId': productId,
            'quantity': quantity,
          });
        }
      }
    });
  }


  void updateProductList(String productId, int quantity) {
    setState(() {
      if (quantity == 0) {
        globals.productList.removeWhere((item) => item['productId'] == productId);
      } else {
        bool found = false;
        for (int i = 0; i < globals.productList.length; i++) {
          if (globals.productList[i]['productId'] == productId) {
            globals.productList[i]['quantity'] = quantity;
            found = true;
            break;
          }
        }
        if (!found) {
          globals.productList.add({
            'productId': productId,
            'quantity': quantity,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showBottomSheet = globals.productList.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage(phoneNumber: widget.phoneNumber)));
        globals.productList=[];
        globals.totalQuantity=0;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Sell Product",style: TextStyle(color: Colors.white, fontSize: 18),),
          backgroundColor:Color(0xff124076),
          centerTitle: true,
          leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage(phoneNumber: widget.phoneNumber)));
              globals.productList=[];
              globals.totalQuantity=0;
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCategorySlider(),
              SizedBox(height: 20.0),
              buildProductCards(),
              SizedBox(height: 20,),
            ],
          ),
        ),
        bottomSheet: showBottomSheet
            ? Container(
          height: 80, // Adjust the height as needed
          width: MediaQuery.of(context).size.width,
          color: Color(0xff124076),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  print(globals.productList);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillPage(

                        phoneNumber: widget.phoneNumber,
                      ),
                    ),
                  ).then((updatedProductList) {
                    if (updatedProductList != null) {
                      setState(() {
                        globals.productList = updatedProductList;
                        // Update any other necessary state variables
                      });
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      globals.totalQuantity.toString(),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' items added',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5,),
                    Icon(
                      Icons.arrow_circle_right,
                      color: Colors.white,

                    )
                  ],
                ),
              ),

            ],
          ),
        )
            : null,
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  final Function(String productId, int quantity) onProductAdded;
  final Function(int) updateTotalQuantity;

  const ProductCard({
    Key? key,
    required this.product,

    required this.onProductAdded,
    required this.updateTotalQuantity,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late int counter;
  bool showFullDescription = false;

  @override
  void initState() {
    super.initState();
    initializeCounter();
  }

  void initializeCounter() {
    var productInList = globals.productList.firstWhere(
          (item) => item['productId'] == widget.product['id'],
      orElse: () => {'quantity': 0}, // Return a map with 'quantity' initialized to 0
    );

    setState(() {
      counter = productInList['quantity']; // Set counter to the quantity from the map
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['productName'],
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      '₹ ${widget.product['Price']}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text.rich(
                      TextSpan(
                        text: showFullDescription
                            ? widget.product['productDescription'] // Show full description
                            : widget.product['productDescription']
                            .split(' ')
                            .take(5)
                            .join(' ') + '...', // Show abbreviated description
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                        children: [
                          if (!showFullDescription) // Show "Read More" button if full description is not shown
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    showFullDescription = true; // Toggle showFullDescription
                                  });
                                },
                                child: Text(
                                  'Read More',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10.0),

              Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.product['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: 120,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              counter++;
                              widget.updateTotalQuantity(1);
                            });
                            widget.onProductAdded(widget.product['id'], counter);
                          },
                          child: counter == 0
                              ? Text('Add',style: TextStyle(color: Color(0xff124076)),)
                              : SizedBox(
                            child: Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.remove, size: 16,color: Color(0xff124076),),
                                    onPressed: () {
                                      setState(() {
                                        counter = counter > 0 ? counter - 1 : 0;
                                        widget.updateTotalQuantity(-1);
                                        print(globals.productList);
                                      });
                                      widget.onProductAdded(widget.product['id'], counter);
                                    },
                                  ),
                                ),
                                Text(
                                  '$counter',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(Icons.add, size: 16,color: Color(0xff124076),),
                                    onPressed: () {
                                      setState(() {
                                        counter++;
                                        widget.updateTotalQuantity(1);
                                        print(globals.productList);
                                      });
                                      widget.onProductAdded(widget.product['id'], counter);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Color(0xff124076)),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blue.shade50;
                                }
                                return Colors.blue.shade50;
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey.withOpacity(0.3),
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}