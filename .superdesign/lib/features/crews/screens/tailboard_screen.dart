import 'package:flutter/material.dart';

class TailboardScreen extends StatefulWidget {
  const TailboardScreen({super.key});

  @override
  State<TailboardScreen> createState() => _TailboardScreenState();
}

class _TailboardScreenState extends State<TailboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _hazardsController = TextEditingController();
  final _controlMeasuresController = TextEditingController();
  
  List<String> _crewMembers = [];
  final _crewMemberController = TextEditingController();
  
  @override
  void dispose() {
    _jobNumberController.dispose();
    _locationController.dispose();
    _hazardsController.dispose();
    _controlMeasuresController.dispose();
    _crewMemberController.dispose();
    super.dispose();
  }

  void _addCrewMember() {
    if (_crewMemberController.text.isNotEmpty) {
      setState(() {
        _crewMembers.add(_crewMemberController.text);
        _crewMemberController.clear();
      });
    }
  }

  void _removeCrewMember(int index) {
    setState(() {
      _crewMembers.removeAt(index);
    });
  }

  void _submitTailboard() {
    if (_formKey.currentState!.validate()) {
      // Handle tailboard submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tailboard submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jobNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Job Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a job number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Crew Members Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crew Members',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _crewMemberController,
                              decoration: const InputDecoration(
                                labelText: 'Add Crew Member',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_add),
                              ),
                              onSubmitted: (_) => _addCrewMember(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addCrewMember,
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_crewMembers.isNotEmpty) ...[
                        Text(
                          'Current Crew:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _crewMembers.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(_crewMembers[index]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeCrewMember(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Safety Information Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safety Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hazardsController,
                        decoration: const InputDecoration(
                          labelText: 'Identified Hazards',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.warning),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please identify potential hazards';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _controlMeasuresController,
                        decoration: const InputDecoration(
                          labelText: 'Control Measures',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.security),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please specify control measures';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitTailboard,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text(
                    'Submit Tailboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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