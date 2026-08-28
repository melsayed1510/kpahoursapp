import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/shift_header_card.dart';
import '../widgets/time_input_section.dart';
import '../widgets/result_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'شيفت اليوم ومواعيد البصمة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShiftHeaderCard(),
              SizedBox(height: 16),
              TimeInputSection(),
              SizedBox(height: 16),
              ResultCard(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
