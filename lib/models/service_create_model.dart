import 'dart:io';

class ServiceCreateModel {
  final String serviceName;
  final String description;
  final String category;
  final String subCategory;
  final int price;
  final int duration;
  final String startTime;
  final String endTime;
  final List<AvailabilityModel> availability;
  final File image;

  ServiceCreateModel({
    required this.serviceName,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.price,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.availability,
    required this.image,
  });

  /// Convert only normal fields (NOT image)
  Map<String, String> toFields() {
    return {
      "serviceName": serviceName,
      "description": description,
      "category": category,
      "subCategory": subCategory,
      "price": price.toString(),
      "duration": duration.toString(),
      "startTime": startTime,
      "endTime": endTime,
      "availability": availabilityToJson(),
    };
  }

  String availabilityToJson() {
    return availability.map((e) => {"date": e.date}).toList().toString();
  }
}

class AvailabilityModel {
  final String date;

  AvailabilityModel({required this.date});

  Map<String, dynamic> toJson() {
    return {"date": date};
  }
}
