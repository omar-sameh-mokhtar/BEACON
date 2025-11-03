import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:flutter/material.dart';

class NetworkDashboardPage extends StatefulWidget {
  const NetworkDashboardPage({super.key});

  @override
  State<NetworkDashboardPage> createState() => _NetworkDashboardPageState();
}

class _NetworkDashboardPageState extends State<NetworkDashboardPage> {
  String selectedRange = "100m";
  final List<Map<String, String>> devices = [
    {"name": "Device 1", "lastSeen": "2 mins ago", "lastMsg": "Help"},
    {"name": "Device 2", "lastSeen": "5 mins ago", "lastMsg": "All good"},
    {"name": "Device 3", "lastSeen": "10 mins ago", "lastMsg": "Need food"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Network Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.dark_mode,// : Icons.light_mode,
              color:  Colors.yellow,// : Colors.black,
            ),
            onPressed: () {
              //themeProvider.toggleTheme();
            },
          ),
          Icon(Icons.settings, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Connected: ${devices.length} Devices",
                    style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.grey[900],
                      style: TextStyle(color: Colors.white),
                      value: selectedRange,
                      items: ["50m", "100m", "200m"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedRange = v!;
                        });
                      },
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.refresh, color: Colors.white))
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
            Text("Network Status: Connected",
                style: TextStyle(color: Colors.green)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, i) {
                  final d = devices[i];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.person, color: Colors.white)),
                      title: Text(d["name"]!,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Last seen: ${d["lastSeen"]}",
                              style: TextStyle(color: Colors.grey)),
                          Text("Last msg: ${d["lastMsg"]}",
                              style: TextStyle(color: Colors.grey))
                        ],
                      ),
                      trailing: Icon(Icons.chat_bubble_outline, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {},
                child: Text("Send Broadcast Message",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Floatingvoicebutton(),
      bottomNavigationBar: NavigationBarBottom(currentIndex: 0)
    );
  }
}
