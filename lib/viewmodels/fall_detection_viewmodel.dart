import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';
import '../model/service/fall_detection_service.dart';
import 'p2p_viewmodel.dart';

class FallDetectionViewModel extends ChangeNotifier {
  final FallDetectionService _service =
  FallDetectionService();

  final AudioPlayer _audioPlayer =
  AudioPlayer();

  bool _fallDetected = false;

  bool get fallDetected => _fallDetected;

  DateTime? _lastAlertTime;

  Future<void> initialize(
      P2PViewModel p2pVM,
      ) async {
    await _service.loadModel();

    _service.startDetection(
      onFallDetected: () async {
        if (_fallDetected) return;

        if (_lastAlertTime != null) {
          final diff = DateTime.now()
              .difference(_lastAlertTime!)
              .inSeconds;

          if (diff < 5) return;
        }

        _lastAlertTime = DateTime.now();

        _fallDetected = true;

        notifyListeners();

        try {
          await _audioPlayer.setReleaseMode(
            ReleaseMode.loop,
          );

          await _audioPlayer.play(
            AssetSource('sounds/alarm.mp3'),
          );
        } catch (e) {
          print("ALARM ERROR: $e");
        }

        final isHost = p2pVM.isHost;

        Future.microtask(() async {
          navigatorKey.currentContext?.goNamed(
            'dashboard',
            pathParameters: {
              'isHost': '$isHost',
            },
          );

          await Future.delayed(
            const Duration(milliseconds: 400),
          );

          final context =
              navigatorKey.currentContext;

          if (context == null) return;

          final endTime = DateTime.now().add(
            const Duration(seconds: 15),
          );

          int secondsLeft = 15;

          bool dialogClosed = false;

          Future<void> handleResetOnly() async {
            if (dialogClosed) return;

            dialogClosed = true;

            if (Navigator.of(
              context,
              rootNavigator: true,
            ).canPop()) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop();
            }

            await reset();
          }

          Future<void> handleEmergency() async {
            if (dialogClosed) return;

            dialogClosed = true;

            if (Navigator.of(
              context,
              rootNavigator: true,
            ).canPop()) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop();
            }

            await sendEmergencyBroadcast(
              p2pVM,
            );

            await reset();
          }

          Future.delayed(
            const Duration(seconds: 15),
                () async {
              if (!dialogClosed) {
                await handleEmergency();
              }
            },
          );

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              Timer? uiTimer;

              return StatefulBuilder(
                builder: (
                    context,
                    setDialogState,
                    ) {
                  uiTimer ??= Timer.periodic(
                    const Duration(seconds: 1),
                        (t) {
                      if (dialogClosed) {
                        t.cancel();
                        return;
                      }

                      final remaining = endTime
                          .difference(
                        DateTime.now(),
                      )
                          .inSeconds;

                      setDialogState(() {
                        secondsLeft =
                        remaining < 0
                            ? 0
                            : remaining;
                      });
                    },
                  );

                  return Dialog(
                    backgroundColor:
                    Colors.grey[900],
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.all(
                        20,
                      ),
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons
                                .warning_amber_rounded,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Text(
                            "Are you okay?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text(
                            "Upnormal activity detected. Do you need help?",
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration:
                            BoxDecoration(
                              shape:
                              BoxShape.circle,
                              border: Border.all(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "$secondsLeft",
                                style:
                                const TextStyle(
                                  color:
                                  Colors.red,
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child:
                                OutlinedButton(
                                  style:
                                  OutlinedButton
                                      .styleFrom(
                                    side:
                                    const BorderSide(
                                      color:
                                      Colors
                                          .green,
                                    ),
                                  ),
                                  onPressed:
                                  handleResetOnly,
                                  child:
                                  const Text(
                                    "NO, I'm fine",
                                    style:
                                    TextStyle(
                                      color:
                                      Colors
                                          .green,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child:
                                ElevatedButton(
                                  style:
                                  ElevatedButton
                                      .styleFrom(
                                    backgroundColor:
                                    Colors.red,
                                  ),
                                  onPressed:
                                  handleEmergency,
                                  child:
                                  const Text(
                                    "I need help",
                                    style:
                                    TextStyle(
                                      color:
                                      Colors
                                          .white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ).then((_) {});
        });
      },
    );
  }

  Future<void> sendEmergencyBroadcast(
      P2PViewModel p2pVM,
      ) async {
    try {
      await p2pVM.sendBroadcastMessage(
        "🚨 EMERGENCY ALERT: Fall detected! User may need help.",
        p2pVM.myId,
      );
      await p2pVM.sendBroadcastMessage(
        "FALL_DETECTED",
        p2pVM.myId,
      );
    } catch (e) {
      print("BROADCAST ERROR: $e");
    }
  }

  Future<void> reset() async {
    _fallDetected = false;

    notifyListeners();

    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("RESET ERROR: $e");
    }
  }

  @override
  void dispose() {
    _service.dispose();

    _audioPlayer.dispose();

    super.dispose();
  }
}