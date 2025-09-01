import 'package:flutter/material.dart';
import 'package:futurex_app/order_screens/category_selection_screen.dart';
import 'package:futurex_app/order_screens/course_selections_screen.dart';

class EnrollmentPlansScreen extends StatefulWidget {
  const EnrollmentPlansScreen({super.key});

  @override
  State<EnrollmentPlansScreen> createState() => _EnrollmentPlansScreenState();
}

class _EnrollmentPlansScreenState extends State<EnrollmentPlansScreen> {
  String? selectedPlan;

  void _navigateToPlanScreen() {
    if (selectedPlan == null) return;

    switch (selectedPlan) {
      case 'Premium':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CategorySelectionScreen(type: "premium ", isFull: true),
          ),
        );
        break;
      case 'Single Grade':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategorySelectionScreen(
              type: "Grade Based ",
              isFull: false,
            ),
          ),
        );
        break;
      case 'Single Course':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CourseSelectionScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Your Enrollment',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Select a plan that suits your learning goals',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Premium Plan Card
              _PlanCard(
                title: 'Premium Plan',
                features: const [
                  'Unlimited enrollment to all subjects',
                  'for all grade levels',
                  'Access to every video lesson &',
                  'All practice exams, quizzes, and',
                  'Full access to all games, quizzes,',
                  'and puzzles',
                  'Personalized study planner',
                ],
                price: '3,999 Birr',
                priceDescription: 'Lifetime Access',
                isSelected: selectedPlan == 'Premium',
                onTap: () {
                  setState(() {
                    selectedPlan = 'Premium';
                  });
                },
              ),

              const SizedBox(height: 20),

              // Single Grade Plan Card
              _PlanCard(
                title: 'Single Grade Plan',
                features: const [
                  'All subjects for your selected',
                  'Grade-specific practice exams,',
                  'quizzes,and videos',
                  'Full access for 1 year',
                ],
                price: '1,999 Birr/year',
                isSelected: selectedPlan == 'Single Grade',
                onTap: () {
                  setState(() {
                    selectedPlan = 'Single Grade';
                  });
                },
              ),

              const SizedBox(height: 20),

              // Single Course Card
              _PlanCard(
                title: 'Single Course',
                features: const [
                  'Choose specific subjects',
                  'Subject-specific tests and videos',
                  'Unlimited lifetime access',
                ],
                price: 'Starts at 499 Birr/course',
                isSelected: selectedPlan == 'Single Course',
                onTap: () {
                  setState(() {
                    selectedPlan = 'Single Course';
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedPlan != null
                      ? _navigateToPlanScreen
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPlan != null
                        ? Colors.blueAccent
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final List<String> features;
  final String price;
  final String? priceDescription;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.title,
    required this.features,
    required this.price,
    this.priceDescription,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        elevation: 0,
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blueAccent : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 12),

              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Icon(
                          Icons.check_circle,
                          size: 16,
                          color: isSelected ? Colors.blueAccent : Colors.green,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.blue.shade800
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blueAccent : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue.shade900 : Colors.black,
                      ),
                    ),
                    if (priceDescription != null)
                      Text(
                        priceDescription!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.blue.shade800
                              : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for each plan type
class SingleGradePlanScreen extends StatelessWidget {
  const SingleGradePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Grade Plan Details')),
      body: const Center(child: Text('Single Grade Plan Screen Content')),
    );
  }
}

class SingleCoursePlanScreen extends StatelessWidget {
  const SingleCoursePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Course Plan Details')),
      body: const Center(child: Text('Single Course Plan Screen Content')),
    );
  }
}
