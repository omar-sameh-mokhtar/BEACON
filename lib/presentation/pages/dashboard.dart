import 'package:flutter/material.dart';
import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';
import 'chat.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/p2p_viewmodel.dart';
import '../../main.dart';


class NetworkDashboardPage extends StatefulWidget {
  final bool isHost;
  const NetworkDashboardPage({super.key, required this.isHost});

  @override
  State<NetworkDashboardPage> createState() => _NetworkDashboardPageState();
}

class _NetworkDashboardPageState extends State<NetworkDashboardPage> {

  @override
  Widget build(BuildContext context) {
    final p2pVM = context.watch<P2PViewModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title:"Network Dashboard"),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Connected: ${p2pVM.peers.length} Devices",
                    style: TextStyle(color: Colors.white)),
                
              ],
            ),
            SizedBox(height: 10),
            Text("Network Status: ${p2pVM.connectionStatus}",
                style: TextStyle(color: Colors.green)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: p2pVM.peers.length,
                itemBuilder: (context, i) {
                  final p = p2pVM.peers[i];
                  final lastMsgObj = p2pVM.lastMessages[p.id];

                  String lastMsgText = lastMsgObj?.content ?? "No messages yet";
                  String lastSeenText = "Never";

                  if (lastMsgObj != null) {
                    final dt = DateTime.parse(lastMsgObj.timestamp);
                    final diff = DateTime.now().difference(dt);
                    
                    if (diff.inMinutes < 1){ lastSeenText = "Just now";}
                    else if (diff.inMinutes < 60){ lastSeenText = "${diff.inMinutes}m ago";}
                    else{ lastSeenText = "${diff.inHours}h ago";}
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: p.isHost ? Colors.orange : Colors.red,
                          child: Icon(Icons.person, color: Colors.white)),
                      title: Text(p.username,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.isHost ? "Host" : "Client",
                              style: TextStyle(color: Colors.grey)),
                          Text("Last seen: $lastSeenText",
                              style: TextStyle(color: Colors.grey)),
                          Text("Last msg: $lastMsgText",
                              style: TextStyle(color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: Icon(Icons.chat_bubble_outline, color: Colors.red),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChattingPage(target: p, isHost: widget.isHost))),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width:  MediaQuery.of(context).size.width * 0.7,
              child: ElevatedButton(
                key: const Key('Broadcast_button'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => _showBroadcastDialog(context),
                child: Text("Send Broadcast Message",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Floatingvoicebutton(centre: false),
      bottomNavigationBar: NavigationBarBottom(currentIndex: 0)
    );
  }
void _showBroadcastDialog(BuildContext context) {
  final TextEditingController msgController = TextEditingController();
  final TextEditingController newMsgController = TextEditingController();
  final p2pVM = context.read<P2PViewModel>();
  final appState = context.read<MyAppState>();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Broadcast Message",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    const Text("Shortcuts (Long press to delete)", 
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: appState.predefinedMessages.map((text) {
                        return GestureDetector(
                          onLongPress: () async {
                            await appState.deletePredefinedMessage(text);
                            setDialogState(() {});
                          },
                          child: ActionChip(
                            backgroundColor: Colors.red.withOpacity(0.2),
                            label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
                            onPressed: () => msgController.text = text,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newMsgController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: "Add new shortcut...",
                              hintStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () async {
                            if (newMsgController.text.trim().isNotEmpty) {
                              await appState.addPredefinedMessage(newMsgController.text.trim());
                              newMsgController.clear();
                              setDialogState(() {}); 
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),

                    TextField(
                      controller: msgController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final msg = msgController.text.trim();
                            if (msg.isEmpty) return;

                            await p2pVM.sendBroadcastMessage(msg, p2pVM.myId);
                            Navigator.pop(context);
                          },
                          child: const Text("Send", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }
      );
    },
  );
}




}
