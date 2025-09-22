import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class BecomePartnerDialog extends StatefulWidget {
  // MODIFIED: Added parameters to receive user data
  final String currentDisplayName;
  final String currentPhoneNumber;

  const BecomePartnerDialog({
    super.key,
    required this.currentDisplayName,
    required this.currentPhoneNumber,
  });

  @override
  State<BecomePartnerDialog> createState() => _BecomePartnerDialogState();
}

class _BecomePartnerDialogState extends State<BecomePartnerDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController phoneController;
  final addressController = TextEditingController();
  final nationalIdController = TextEditingController();
  final licenseController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // MODIFIED: Use the passed-in widget data to initialize controllers
    final nameParts = widget.currentDisplayName.split(' ');
    firstNameController = TextEditingController(
        text: nameParts.isNotEmpty ? nameParts.first : '');
    lastNameController = TextEditingController(
        text: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '');
    phoneController = TextEditingController(text: widget.currentPhoneNumber);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    nationalIdController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (formKey.currentState!.validate() && !isLoading) {
      setState(() => isLoading = true);
      try {
        await Supabase.instance.client
            .rpc('submit_partner_application', params: {
          'first_name_arg': firstNameController.text,
          'last_name_arg': lastNameController.text,
          'phone_arg': phoneController.text,
          'address_arg': addressController.text,
          'national_id_arg': nationalIdController.text,
          'license_id_arg': licenseController.text,
        });

        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Application submitted! We will contact you soon.'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Error: ${e is PostgrestException ? e.message : e.toString()}'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ));
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AlertDialog(
      backgroundColor: theme.secondaryBackground,
      title: Text('Partner Application', style: theme.headlineSmall),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nationalIdController,
                decoration:
                    const InputDecoration(labelText: 'National ID Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: licenseController,
                decoration:
                    const InputDecoration(labelText: 'Medical License Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
        ),
        ElevatedButton(
          onPressed: _submitApplication,
          style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
