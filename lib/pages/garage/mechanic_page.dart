import 'package:flutter/material.dart';

class MechanicPage extends StatefulWidget {
  @override
  _MechanicPageState createState() => _MechanicPageState();
}

class _MechanicPageState extends State<MechanicPage> {
  List<Car> cars = [

  ];

  List<Car> filteredCars = [];
  bool showGoodStatus = true;
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 6.0), // Add top padding to title
            child: Text(
              "Страница механика",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          toolbarHeight: 80, // Increase app bar height
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  _buildStatusToggle(),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildCarListView(),
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
        hintText: "Поиск по машине...",
        prefixIcon: Icon(Icons.search, color: Colors.blue),
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.withOpacity(0.3), width: 1),
        ),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton("Одобрено", true),
        SizedBox(width: 16),
        _buildToggleButton("Не одобрено", false),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isGoodStatus) {
    final isActive = isGoodStatus == showGoodStatus;

    return GestureDetector(
      onTap: () => _toggleStatusFilter(isGoodStatus),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGoodStatus ? Icons.check_circle : Icons.warning,
              color: isActive ? Colors.white : Colors.blue,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarListView() {
    if (filteredCars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.car_repair, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "Машины не найдены",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(top: 16, bottom: 24),
      itemCount: filteredCars.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final car = filteredCars[index];
        final isApproved = car.status == "Одобрено";

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isApproved
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isApproved ? Icons.check : Icons.close,
                color: isApproved ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              car.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              "Модель: ${car.model}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isApproved
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                car.status,
                style: TextStyle(
                  color: isApproved ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
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