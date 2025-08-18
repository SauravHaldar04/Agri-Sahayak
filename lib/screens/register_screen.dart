import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'farmer';
  final Map<String, dynamic> _roleSpecificData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Role Selection
                  Text(
                    'Select Your Role',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.work),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                      DropdownMenuItem(value: 'advisor', child: Text('Agricultural Advisor')),
                      DropdownMenuItem(value: 'policymaker', child: Text('Policymaker')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                        _roleSpecificData.clear();
                      });
                    },
                  ),
                  SizedBox(height: 24),

                  // Role-specific fields
                  if (_selectedRole == 'farmer') _buildFarmerFields(),
                  if (_selectedRole == 'advisor') _buildAdvisorFields(),
                  if (_selectedRole == 'policymaker') _buildPolicymakerFields(),

                  SizedBox(height: 24),

                  // Password Fields
                  Text(
                    'Security',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Please enter a password';
                      if (value!.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: authProvider.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Register', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  // Error Message
                  if (authProvider.error != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFarmerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Farm Details', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        // Add farmer-specific fields here
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Primary Crop',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _roleSpecificData['primaryCrop'] = value,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Farm Size (hectares)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _roleSpecificData['farmSize'] = double.tryParse(value),
        ),
      ],
    );
  }

  Widget _buildAdvisorFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Professional Details', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Certification',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _roleSpecificData['certification'] = value,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Specialization',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _roleSpecificData['specialization'] = [value],
        ),
      ],
    );
  }

  Widget _buildPolicymakerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Official Details', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Department',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _roleSpecificData['department'] = value,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Designation',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _roleSpecificData['designation'] = value,
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      role: _selectedRole,
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      roleSpecificData: _roleSpecificData,
    );

    if (success) {
      // Navigate based on user role
      final dashboardRoute = authProvider.getDashboardRoute();
      Navigator.pushReplacementNamed(context, dashboardRoute);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
