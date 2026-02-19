import 'dart:convert';
import 'package:creatamax_task/auth_config.dart';
import 'package:creatamax_task/view/services_pricing.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ManageServices extends StatefulWidget {
  const ManageServices({super.key});

  @override
  State<ManageServices> createState() => _ManageServicesState();
}

class _ManageServicesState extends State<ManageServices> {
  bool isLoading = false;
  List data = [];
  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  fetchServices() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse("https://velvook-node.creatamax.in/api/providers/services"),
        headers: {'Authorization': "Bearer ${AuthConfig.API_KEY}"},
      );
      final json = await jsonDecode(response.body);
      setState(() {
        data = json['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size(double.maxFinite, 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Text(
                  "Manage Services",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ServicesPricing()),
                  ),
                  child: Text(
                    "Add services",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              padding: .symmetric(horizontal: 10, vertical: 10),
              itemBuilder: (context, index) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: .circular(16)),
                child: Row(
                  children: [
                    Padding(
                      padding: const .all(5.0),
                      child: FlutterLogo(size: 100),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            data[index]['serviceName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            data[index]['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, color: Colors.orange),
                              Text(data[index]['duration'].toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.075,
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 5),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.edit, color: Colors.black),
                            ),
                            const SizedBox(width: 5),
                            Icon(Icons.delete_outline, color: Colors.black),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
