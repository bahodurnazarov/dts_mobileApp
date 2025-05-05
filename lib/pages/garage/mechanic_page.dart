import 'package:flutter/material.dart';

class MechanicPage extends StatefulWidget {
  @override
  _MechanicPageState createState() => _MechanicPageState();
}

class _MechanicPageState extends State<MechanicPage> {
  List<Car> cars = [
    Car(name: "Tesla Model S", model: "2022", status: "Одобрено"),
    Car(name: "BMW X5", model: "2021", status: "Не одобрено"),
    Car(name: "Mercedes G-Wagon", model: "2023", status: "Одобрено"),
    Car(name: "Audi A6", model: "2020", status: "Одобрено"),
    Car(name: "Toyota Supra", model: "2019", status: "Не одобрено"),
  ];

  List<Car> filteredCars = [];
  bool showGoodStatus = true; // Default to show "Одобрено" cars

  @override
  void initState() {
    super.initState();
    filteredCars = cars;
  }

  void _filterCars(String query) {
    setState(() {
      filteredCars = cars
          .where((car) =>
      (car.name.toLowerCase().contains(query.toLowerCase()) ||
          car.model.contains(query)) &&
          (showGoodStatus
              ? car.status == "Одобрено"
              : car.status == "Не одобрено"))
          .toList();
    });
  }

  void _toggleStatusFilter(bool isGoodStatus) {
    setState(() {
      showGoodStatus = isGoodStatus;
      filteredCars = cars
          .where((car) =>
      (car.status == (isGoodStatus ? "Одобрено" : "Не одобрено")) &&
          (car.name.toLowerCase().contains(_searchQuery) ||
              car.model.contains(_searchQuery)))
          .toList();
    });
  }

  String _searchQuery = ''; // To keep track of search query

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent navigation to the previous page
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Set background color to white
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes the back button
          backgroundColor: Colors.white, // Set app bar background to white
          elevation: 3,
          title: Text(
            "Страница механика",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildSearchBar(),
              SizedBox(height: 20),
              Expanded(
                child: _buildCarListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
        _filterCars(query);
      },
      decoration: InputDecoration(
        hintText: "Поиск по номеру машины...",
        prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
        contentPadding: EdgeInsets.symmetric(vertical: 14.0),
        filled: true,
        fillColor: Colors.grey[200], // Set background color of the text field to white
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


  Widget _buildToggleButton(String label, bool isGoodStatus) {
    return GestureDetector(
      onTap: () {
        _toggleStatusFilter(isGoodStatus);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isGoodStatus == showGoodStatus ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(32),
          boxShadow: isGoodStatus == showGoodStatus
              ? [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
          border: Border.all(
            color: isGoodStatus == showGoodStatus
                ? Colors.blue
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGoodStatus ? Icons.check_circle : Icons.schedule,
              color: isGoodStatus == showGoodStatus
                  ? Colors.white
                  : Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isGoodStatus == showGoodStatus
                    ? Colors.white
                    : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarListView() {
    return ListView.builder(
      itemCount: filteredCars.length,
      itemBuilder: (context, index) {
        final car = filteredCars[index];
        return Card(
          elevation: 5,
          shadowColor: Colors.blueAccent.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(bottom: 16),
          color: Colors.grey[100], // Set card background to white
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              car.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Модель: ${car.model}"),
            trailing: Text(
              car.status,
              style: TextStyle(
                color: car.status == "Одобрено" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class Car {
  final String name;
  final String model;
  final String status;

  Car({required this.name, required this.model, required this.status});
}
