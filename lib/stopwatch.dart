import 'dart:async';

import 'package:flutter/material.dart';

class FlutterStopWatch extends StatefulWidget {
  @override
  _FlutterStopWatchState createState() => _FlutterStopWatchState();
}

class _FlutterStopWatchState extends State<FlutterStopWatch> {
  bool _isTicking = false;
  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;
  int _timeInSeconds;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        setState(() {
          _timeInSeconds = 0;
          _isTicking = false;
        });
        streamController.close();
      }
    }

    void tick(_) {
      setState(() {
        _timeInSeconds++;
      });
      streamController.add(_timeInSeconds);
    }

    void startTimer() {
      setState(() {
        if (_timeInSeconds == null) {
          _timeInSeconds = 0;
        }
        _isTicking = true;
      });
      timer = Timer.periodic(timerInterval, tick);
    }

    void pauseTimer() {
      setState(() {
        _isTicking = false;
      });
      timer.cancel();
    }

    void resumeTimer() {
      setState(() {
        _isTicking = true;
      });
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: resumeTimer,
      onPause: pauseTimer,
    );

    return streamController.stream;
  }

  void setTimeStr(int newTick) {
    setState(() {
      hoursStr =
          ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
      minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
      secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
    });
    print("Current time in seconds: $_timeInSeconds");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter StopWatch")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$hoursStr:$minutesStr:$secondsStr",
              style: TextStyle(
                fontSize: 90.0,
              ),
            ),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: !_isTicking
                      ? () {
                          if (timerStream == null ||
                              timerSubscription == null) {
                            timerStream = stopWatchStream();
                            timerSubscription =
                                timerStream.listen((int newTick) {
                              setTimeStr(newTick);
                            });
                          } else {
                            timerSubscription.resume();
                          }
                        }
                      : () {
                          timerSubscription.pause();
                        },
                  color: _isTicking ? Colors.orange : Colors.green,
                  child: Text(
                    _isTicking ? 'PAUSE' : 'START',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
                SizedBox(width: 40.0),
                RaisedButton(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  onPressed: () {
                    timerSubscription.cancel();
                    timerStream = null;
                    setState(() {
                      hoursStr = '00';
                      minutesStr = '00';
                      secondsStr = '00';
                    });
                  },
                  color: Colors.red,
                  child: Text(
                    'RESET',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
