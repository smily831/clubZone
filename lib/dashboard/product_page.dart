import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../globals.dart' as globals;
import '../global/common/toast.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData; // Make categoryData nullable
  final String? categoryId;
  final String? productId;

  const ProductPage(
      {Key? key,
        this.productData,
        this.categoryId,
        this.productId})
      : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? _selectedCategory; // Change to nullable type
  QuerySnapshot? categoriesSnapshot;
  String? imagePath;
  String filename = '';
  String? imageUrl;
  File? _selectedImage;


  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  bool showLoader = false;
  bool categorySelected = false;
  String? selectedCategoryName;
  bool clicked = false;


  void addProduct() async {
    if (_codeController.text.isEmpty) {
      showToast(message: "Enter Category Name");
    } else if (_descriptionController.text.isEmpty) {
      showToast(message: "Enter Category Description");
    } else if (imageUrl == null) {
      showToast(message: "Enter Image");
    } else if (_nameController.text.isEmpty) {
      showToast(message: "Enter Product Name");
    } else if (_priceController.text.isEmpty) {
      showToast(message: "Enter Price");
    } else if (_selectedCategory == null) {
      showToast(message: "Select a Category");
    } else {
      try {
        setState(() {
          showLoader = true;
        });
        Reference storageRef = FirebaseStorage.instance.ref();
        Reference brandDirRef = storageRef.child('product');
        Reference uploadRef = brandDirRef.child(filename);
        await uploadRef.putFile(File(imagePath!));
        imageUrl = await uploadRef.getDownloadURL();
        setState(() {
          clicked = false;
        });
        // Save the product data in Firestore
        var docRef = await FirebaseFirestore.instance
            .collection("categories")
            .doc(_selectedCategory)
            .collection('products')
            .add(
          {
            "productCode": _codeController.text.trim(),
            "productName": _nameController.text.trim(),
            "productDescription": _descriptionController.text.trim(),
            "Price": int.parse(_priceController.text.trim()),
            'imageUrl': imageUrl,
            'filename': filename,
            'CategoryId': _selectedCategory,

          },
        );

        // Get the auto-generated ID of the document
        final productId = docRef.id;

        // Update the document with the ID as a field (optional)
        await docRef.update({"id": productId});

        setState(() {
          showLoader = false;
        });

        // Navigate back to the dashboard
        Navigator.of(context).pushReplacementNamed('/productList');
      } catch (e) {
        print("Error adding product: $e");
        setState(() {
          showLoader = false;
        });
      }
    }
  }

  List<String> categories = []; // List to store categories fetched from Firestore


  @override
  void initState() {
    _codeController =
        TextEditingController(text: widget.productData?['productCode']);
    _nameController =
        TextEditingController(text: widget.productData?['productName']);
    _descriptionController =
        TextEditingController(text: widget.productData?['productDescription']);
    _priceController =
        TextEditingController(text: widget.productData?['Price'].toString());

    setState(() {
      filename =
      widget.productData != null ? widget.productData!['filename'] : '';
      imageUrl = widget.productData?['imageUrl'];
    });
    fetchCategories(); // Fetch categories when the widget initializes
    fetchNames();
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    setState(() {
      filename = pickedImage.name + DateTime.now().toString();
    });
    imagePath = pickedImage.path;

    imageUrl = imageUrl != null ? imageUrl : "";
  }


  void fetchCategories() async {
    // Get the current user's ID

    // Query Firestore for categories collection under the current user
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('categories').get();

    List<String> fetchedCategories = [];

    // Iterate through the documents in the query snapshot
    querySnapshot.docs.forEach((doc) {
      // Extract category name from document data
      String categoryName = doc['categoryName'];

      // Extract document ID and add it as a prefix to the category name
      String categoryID = doc.id;
      fetchedCategories.add('$categoryID: $categoryName');
    });

    setState(() {
      categories = fetchedCategories; // Update categories list
    });
  }

  Widget buildCategorySlider() {
    print(categories);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            'Select Category:',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Container(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                    _selectedCategory == categories[index].split(':')[0]
                        ? Colors.grey
                        : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedCategory = categories[index].split(':')[0];
                      print(_selectedCategory);
                    });
                  },
                  child: Text(
                    categories[index].split(': ')[1],
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void fetchNames() async {
    if (widget.categoryId != null ) {
      DocumentSnapshot<Map<String, dynamic>> categoryDoc =
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .get();

      setState(() {
        selectedCategoryName = categoryDoc['categoryName'];
      });
    }
  }


  void updateProduct() async {
    try {
      setState(() {
        showLoader = true;
      });
      Reference storageRef = FirebaseStorage.instance.ref();
      if (filename != widget.productData?['filename']) {
        final desertRef =
        storageRef.child('product/${widget.productData?['filename']}');
        await desertRef.delete();

        Reference brandDirRef = storageRef.child('product');
        Reference uploadRef = brandDirRef.child(filename);
        await uploadRef.putFile(File(imagePath!));
        imageUrl = await uploadRef.getDownloadURL();
      }
      setState(() {
        clicked = false;
      });
      final productRef = FirebaseFirestore.instance
          .collection("categories")
          .doc(widget.productData!['CategoryId'])
          .collection('products')
          .doc(widget.productData!['id']);

      await productRef.update({
        "productCode": _codeController.text.trim(),
        "productName": _nameController.text.trim(),
        "productDescription": _descriptionController.text.trim(),
        "Price": _priceController.text.trim(),
        "imageUrl": imageUrl,
        'filename': filename,

      });
      globals.imageName[widget.productId] = filename;
      setState(() {
        showLoader = false;
      });

      Navigator.of(context).pushReplacementNamed('/productList');
    } catch (e) {
      print("Error updating product: $e");
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
        title: const Text("Enter Products"),
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
            Navigator.pushReplacementNamed(context, "/productList");
          },
        ),
      ),
      body: showLoader
          ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ))
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
                      widget.productId == null
                          ? buildCategorySlider()
                          : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8),
                                  child: Text(
                                    'Selected Category:',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  height: 30,
                                  child: Padding(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        horizontal: 6.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton
                                          .styleFrom(
                                        foregroundColor:
                                        Colors.white,
                                        backgroundColor:
                                        Colors.grey,
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius
                                              .circular(15.0),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: Text(
                                        selectedCategoryName ??
                                            "hi",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight:
                                          FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Enter Product Code',
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
                            fontWeight: FontWeight.w500),
                        controller: _codeController,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Product Code",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 193, 189, 189),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Enter Product Name',
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
                            fontWeight: FontWeight.w500),
                        controller: _nameController,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Product Name",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 193, 189, 189),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Enter Product Description',
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
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: 'Product Description',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 193, 189, 189),
                              fontWeight: FontWeight.w500,
                            )),
                      ),

                      Text(
                        'Enter Product Price',
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
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: Color.fromARGB(255, 193, 189, 189),
                            fontWeight: FontWeight.w500),
                        controller: _priceController,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            hintText: "Product Price",
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 193, 189, 189),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          _selectedImage != null
                              ? Image.file(_selectedImage!)
                              : const Text(
                            "Please select an image",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 18,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: const Text(
                              "Pick Image",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                clicked = true;
                              });
                              _pickImageFromGallery();
                            },
                          ),
                        ],
                      ),
                      imageUrl == null
                          ? clicked
                          ? Text("Image is Uploading",
                          style: TextStyle(color: Colors.blue))
                          : Text("")
                          : Text(
                        filename.toString(),
                        style: TextStyle(color: Colors.blue),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.productData != null
                                ? updateProduct()
                                : addProduct();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 18, horizontal: 38),
                            backgroundColor:
                            Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            widget.productData != null
                                ? "Update Product"
                                : "Add Product",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.productId == null
                        ? buildCategorySlider() // Assuming buildCategorySlider is defined elsewhere
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                'Selected Category:',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // Set text color to blue
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    selectedCategoryName ?? "hi",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Enter Product Code',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: _codeController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Product Code",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Enter Product Name',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: _nameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Product Name",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Enter Product Description',
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
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: 'Product Description',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Enter Product Price',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: _priceController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        hintText: "Product Price",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 193, 189, 189),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        _selectedImage != null
                            ? Image.file(_selectedImage!)
                            : const Text(
                          "Please select an image",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text(
                            "Pick Image",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              clicked = true;
                            });
                            _pickImageFromGallery();
                          },
                        ),
                      ],
                    ),
                    imageUrl == null
                        ? clicked
                        ? Text("Image is Uploading",
                        style: TextStyle(color: Colors.blue))
                        : Text("")
                        : Text(
                      filename.toString(),
                      style: TextStyle(color: Colors.blue),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.productData != null
                              ? updateProduct()
                              : addProduct();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          widget.productData != null
                              ? "Update Product"
                              : "Add Product",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

          },
        ),
      ),
    );
  }
}