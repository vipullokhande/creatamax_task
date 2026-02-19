import 'dart:convert';
import 'dart:io';
import 'package:creatamax_task/auth_config.dart';
import 'package:creatamax_task/models/service_create_model.dart';
import 'package:creatamax_task/view/manage_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ServicesPricing extends StatefulWidget {
  const ServicesPricing({super.key});

  @override
  State<ServicesPricing> createState() => _ServicesPricingState();
}

class _ServicesPricingState extends State<ServicesPricing> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  File? _image;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? selectedCategory;
  String? selectedSubCategory;
  List<dynamic> categoryList = [];
  List<dynamic> subCategoryList = [];
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _durationController;
  late TextEditingController _aboutController;

  Future<void> _openCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse("https://velvook-node.creatamax.in/api/categories"),
      );
      if (response.statusCode == 200) {
        final json = await jsonDecode(response.body);
        setState(() {
          categoryList = json['data'] ?? [];
        });
      }
    } catch (e) {
      print("Category Error: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchSubCategories(String categoryId) async {
    setState(() {
      isLoading = true;
      subCategoryList = [];
      selectedSubCategory = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          "https://velvook-node.creatamax.in/api/categories/$categoryId",
        ),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          subCategoryList = decoded['data']?['subCategories'] ?? [];
        });
      }
    } catch (e) {
      print("SubCategory Error: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> createService(ServiceCreateModel model) async {
    setState(() => isLoading = true);
    try {
      var uri = Uri.parse(
        "https://velvook-node.creatamax.in/api/providers/services",
      );
      var request = http.MultipartRequest("POST", uri);
      request.headers['Authorization'] = "Bearer ${AuthConfig.API_KEY}";
      request.fields.addAll(model.toFields());
      request.files.add(
        await http.MultipartFile.fromPath('image', model.image.path),
      );
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      final jsonResponse = await jsonDecode(responseData.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Service created successfully")));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ManageServices()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? "Something went wrong"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _durationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void initControllers() async {
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _discountController = TextEditingController();
    _durationController = TextEditingController();
    _aboutController = TextEditingController();
    await fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: Size(double.maxFinite, 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Services & Pricing",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _globalKey,
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => _openCamera(),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.height * 0.13,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  width: 1,
                                  color: Colors.black,
                                ),
                                borderRadius: .circular(16),
                              ),
                              child: Stack(
                                children: [
                                  _image == null
                                      ? FlutterLogo(size: 100)
                                      : Image.file(_image!),
                                  Align(
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text("Business Logo"),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Service Name"),
                    ),
                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter value" : null,
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Service name",
                          border: OutlineInputBorder(
                            borderRadius: .circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Category"),
                    ),
                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: DropdownButtonFormField<String>(
                        icon: Icon(Icons.keyboard_arrow_down_sharp),
                        hint: Text("Select category"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: .circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        items: categoryList
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category['_id'].toString(),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Text(category['name'] ?? ''),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        borderRadius: .circular(10),
                        value: selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                          if (value != null) {
                            fetchSubCategories(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Sub Category"),
                    ),
                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: DropdownButtonFormField<String>(
                        icon: Icon(Icons.keyboard_arrow_down_sharp),
                        hint: Text("Select subcategory"),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: .circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        items: subCategoryList
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category['_id'].toString(),
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Text(category['name'] ?? ''),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        borderRadius: .circular(10),
                        value: selectedSubCategory,
                        onChanged: (value) async {
                          setState(() {
                            selectedSubCategory = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Price"),
                    ),
                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter value" : null,
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Price",
                          border: OutlineInputBorder(
                            borderRadius: .circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Discount (optional)"),
                    ),
                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter value" : null,
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Discount",
                          border: OutlineInputBorder(
                            borderRadius: .circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Duration"),
                    ),
                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter value" : null,
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Duration",
                          border: OutlineInputBorder(
                            borderRadius: .circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text("About Business"),
                    ),
                    Padding(
                      padding: .symmetric(horizontal: 10),
                      child: TextFormField(
                        validator: (value) =>
                            value!.isEmpty ? "Enter value" : null,
                        minLines: 3,
                        maxLines: 3,
                        controller: _aboutController,
                        decoration: InputDecoration(
                          hintText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: .circular(10),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ).copyWith(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_globalKey.currentState!.validate() &&
                              selectedCategory != null &&
                              selectedSubCategory != null &&
                              _image != null) {
                            await createService(
                              ServiceCreateModel(
                                serviceName: _nameController.text,
                                description: _aboutController.text,
                                category: selectedCategory!,
                                subCategory: selectedSubCategory!,
                                price: int.parse(_priceController.text),
                                duration: int.parse(_durationController.text),
                                startTime: "09:00 AM",
                                endTime: "11:00 AM",
                                availability: [
                                  AvailabilityModel(date: "2026-02-05"),
                                  AvailabilityModel(date: "2026-02-05"),
                                  AvailabilityModel(date: "2026-02-05"),
                                ],
                                image: _image!,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please fill all fields")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(148, 111, 223, 1),
                          fixedSize: Size(double.maxFinite, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: .circular(10),
                          ),
                        ),
                        child: Text(
                          "Save & Continue",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
