import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تغيير كلمة المرور"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _passwordField(
                "كلمة المرور الحالية",
                oldCtrl,
                showOld,
                () => setState(() => showOld = !showOld),
              ),
              _passwordField(
                "كلمة المرور الجديدة",
                newCtrl,
                showNew,
                () => setState(() => showNew = !showNew),
              ),
              _passwordField(
                "تأكيد كلمة المرور",
                confirmCtrl,
                showConfirm,
                () => setState(() => showConfirm = !showConfirm),
                confirm: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: API Change Password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم تحديث كلمة المرور")),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("تحديث كلمة المرور"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool visible,
    VoidCallback toggle, {
    bool confirm = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        obscureText: !visible,
        validator: (v) {
          if (v == null || v.isEmpty) return "الحقل مطلوب";
          if (confirm && v != newCtrl.text) {
            return "كلمة المرور غير متطابقة";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}
