import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:flutter/material.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title:"Profile"),
      body: Column(
        children: [
          Container(
            color: Colors.grey[900],
            child: Row(children: [
              _buildTab("Medical", Icons.medical_services, 0),
              _buildTab("Shelter", Icons.home, 1),
              _buildTab("Food", Icons.fastfood, 2),
            ]),
          ),

          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red, onPressed: () {},
        child: Icon(Icons.mic, color: Colors.white),
      ),
      bottomNavigationBar: NavigationBarBottom(currentIndex: 2,)
    );
  }

  Widget _buildTab(String name, IconData icon, int index) {
    bool isSelected = _currentTab == index;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? Colors.red : Colors.grey, width: 2))),
        child: TextButton(
          onPressed: () => setState(() => _currentTab = index),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: isSelected ? Colors.red : Colors.white70, size: 20),
            SizedBox(height: 4),
            Text(name, style: TextStyle(color: isSelected ? Colors.red : Colors.white70, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildContent() {
    List<Map<String, String>> items = _currentTab == 0 ? [
      {"title": "Need First Aid Kit", "type": "Request", "user": "User Alpha", "distance": "0.5 km"},
      {"title": "Medical Supplies", "type": "Offer", "user": "User Beta", "distance": "1.2 km"},
    ] : _currentTab == 1 ? [
      {"title": "Emergency Shelter", "type": "Offer", "user": "Safe House", "distance": "1.5 km"},
      {"title": "Need Shelter", "type": "Request", "user": "Family Group", "distance": "2.1 km"},
    ] : [
      {"title": "Purified Water", "type": "Offer", "user": "Community Center", "distance": "0.7 km"},
      {"title": "Need Food Supplies", "type": "Request", "user": "Stranded Group", "distance": "3.2 km"},
    ];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Text("Available Resources", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Spacer(),
          IconButton(icon: Icon(Icons.add, color: Colors.red), onPressed: () {}),
        ]),
        SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              bool isRequest = item["type"] == "Request";
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isRequest ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20), border: Border.all(color: isRequest ? Colors.orange : Colors.green),
                    ),
                    child: Icon(isRequest ? Icons.help_outline : Icons.volunteer_activism, color: isRequest ? Colors.orange : Colors.green, size: 20),
                  ),
                  title: Text(item["title"]!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Padding(padding: EdgeInsets.only(top: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(
                        color: isRequest ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(item["type"]!, style: TextStyle(color: isRequest ? Colors.orange : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.person_outline, color: Colors.grey, size: 14), SizedBox(width: 4), Text(item["user"]!, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(width: 16), Icon(Icons.location_on_outlined, color: Colors.grey, size: 14), SizedBox(width: 4), Text(item["distance"]!, style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ])),

                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}