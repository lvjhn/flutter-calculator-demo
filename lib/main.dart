import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() 
{
  runApp(const App(title: "Calculator App"));  
}

enum CalculatorOperation {
  addition,
  subtraction, 
  division, 
  multiplication,
  equals
}

class AppState extends ChangeNotifier 
{
  double? result                   = 0; 
  double? input                    = 0;
  bool hasJustCleared              = true;
  CalculatorOperation operation    = CalculatorOperation.addition;
  late TextEditingController? inputController; 

  void setResult(double? value) {
    result = value;
    notifyListeners();
  }

  void setInput(double? value) {
    input = value;
    notifyListeners();
  }

  void reset() {
    input = 0.0;
    result = 0.0;
    notifyListeners();
  }
}

var appState = AppState();

class App extends StatelessWidget
{
  const App({ super.key, required this.title }); 
  
  final String title; 

  @override 
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => appState)
      ], 
      child: MaterialApp(
        title: title, 
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Calculator Demo')
          ), 
          body: Container(
            margin: const EdgeInsets.all(20),
            child: const CalculatorWidget()
          )
        )
      )
    );
  }
}

class CalculatorWidget extends StatefulWidget 
{
  const CalculatorWidget({ super.key, }); 

  @override 
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> 
{
  final double result = 0;

  @override 
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CalculatorInputWidget(), 
        const SizedBox(height: 20),
        const CalculatorButtonsWidget(),
        Row(
          children: [
            ClearCalculatorButtonWidget()
          ]
        ),
        //   Consumer<AppState> (
        //     builder: (context, appState, child) {
        //       return Text("${appState.input}");
        //     }
        //   ),
        const SizedBox(height: 20), 
        Consumer<AppState> (
            builder: (context, appState, child) {
              return Text(
                "${appState.result}",
                style: const TextStyle(fontSize: 20),
              );
            }
          )
        ]
    );
  } 
}

class ClearCalculatorButtonWidget extends StatelessWidget 
{
  @override 
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          appState.reset();
          appState.inputController?.text = ""; 
        }, 
        child: const Icon(CupertinoIcons.trash)
      )
    );
  } 
}

class CalculatorInputWidget extends StatefulWidget 
{
  const CalculatorInputWidget({ super.key }); 

  @override 
  State<CalculatorInputWidget> createState() => _CalculatorInputWidgetState();
}

class _CalculatorInputWidgetState extends State<CalculatorInputWidget> 
{
  final inputController = TextEditingController();

  @override 
  void initState() {
    super.initState(); 
    appState.inputController = inputController;
    inputController.addListener(_onInputUpdate);
  }

  void _onInputUpdate() {
    if(inputController.text == "") {
      appState.setInput(0.0);
    }
    else {
      appState.setInput(double.parse(inputController.text));
    }
  }

  @override 
  Widget build(BuildContext context) {
    return TextField(controller: inputController);
  }
}

class CalculatorButtonsWidget extends StatelessWidget 
{
  const CalculatorButtonsWidget({ super.key });

  double evaluateCurrentExpression() {
    var currResult = appState.result!;
    var currInput  = appState.input!;
    late double result;

    if(appState.hasJustCleared) {
      return currInput;
    }

    if(appState.operation == CalculatorOperation.addition) {
      result = currResult + currInput;
    } 
    else if(appState.operation == CalculatorOperation.subtraction) {
      result = currResult - currInput; 
    }
    else if(appState.operation == CalculatorOperation.multiplication) {
      result = currResult * currInput; 
    }
    else if(appState.operation == CalculatorOperation.division) {
      result = currResult / currInput;
    }

    return result; 
  }

  void setupStandardOperation(CalculatorOperation op) {
    double result = evaluateCurrentExpression();

    appState.operation = op;
    appState.setInput(0.0);
    appState.setResult(result);
    appState.inputController?.text = "";
    appState.hasJustCleared = false;
  }

  @override 
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            print("Adding...");
            setupStandardOperation(CalculatorOperation.addition);
          }, 
          child: const Icon(Icons.add)
        ),
        ElevatedButton(
          onPressed: () {
            print("Subtracting...");
            setupStandardOperation(CalculatorOperation.subtraction);
          }, 
          child: const Icon(Icons.remove)
        ),
        ElevatedButton(
          onPressed: () {
            print("Dividing...");
            setupStandardOperation(CalculatorOperation.division);
          }, 
          child: const Icon(CupertinoIcons.divide)
        ),
        ElevatedButton(
          onPressed: () {
            print("Multiplying...");
            setupStandardOperation(CalculatorOperation.multiplication);
          }, 
          child: const Icon(CupertinoIcons.multiply)
        ),
        ElevatedButton(
          onPressed: () {
            print("Equals...");
            print("Input: ${appState.input}");
            print("Result: ${appState.result}");
            var result = evaluateCurrentExpression();
            appState.inputController!.text = result.toString();
            appState.reset();
            appState.setInput(result);
            appState.hasJustCleared = true;
          }, 
          child: const Icon(CupertinoIcons.equal)
        )
      ]
    );
  } 
}