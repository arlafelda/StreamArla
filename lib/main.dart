import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arla',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const StreamHomePage(),
    );
  }
}

class StreamHomePage extends StatefulWidget {
  const StreamHomePage({super.key});

  @override
  State<StreamHomePage> createState() => _StreamHomePageState();
}

class _StreamHomePageState extends State<StreamHomePage> {
  Color bgColor = Colors.blueGrey;
  late ColorStream colorStream;
  int lastNumber = 0;
  late NumberStream numberStream;
  late StreamSubscription<int> numberSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize ColorStream
    colorStream = ColorStream();
    changeColor();

    // Initialize NumberStream
    numberStream = NumberStream();
    numberSubscription = numberStream.stream.listen((event) {
      setState(() {
        lastNumber = event;
      });
    });
  }

  void changeColor() async {
    await for (var eventColor in colorStream.getColors()) {
      setState(() {
        bgColor = eventColor;
      });
    }
  }

  void addRandomNumber() {
    Random random = Random();
    int myNum = random.nextInt(10); // Generate a random number between 0-9
    numberStream.addNumberToSink(myNum);
  }

  @override
  void dispose() {
    numberSubscription.cancel(); // Cancel the subscription
    numberStream.dispose(); // Close the stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arla'),
      ),
      body: Container(
        decoration: BoxDecoration(color: bgColor),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(lastNumber.toString(), style: const TextStyle(color: Colors.white, fontSize: 24)),
              ElevatedButton(
                onPressed: addRandomNumber,
                child: const Text('New Random Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorStream {
  Stream<Color> getColors() async* {
    final random = Random();
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
    }
  }
}

class NumberStream {
  final StreamController<int> _controller = StreamController<int>();

  Stream<int> get stream => _controller.stream;

  void addNumberToSink(int number) {
    _controller.sink.add(number);
  }

  void dispose() {
    _controller.close();
  }
}
