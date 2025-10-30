// view/sub_admin_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../model/user_model.dart';
import '../../../../repository/user_repository.dart';
import '../../../../services/get_storage.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/indicator.dart';

class SubAdminPage extends StatefulWidget {
  const SubAdminPage({super.key});

  @override
  State<SubAdminPage> createState() => _SubAdminPageState();
}

class _SubAdminPageState extends State<SubAdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository repository = UserRepository();
  final List<String> emailList = [];

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<String> addBranchUserToUserCollection(UserModel userModel) async {
    String val = await repository.createUser(userModel.toJson());
    return val;
  }

  Future<void> fetchEmails() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('createdBy', isEqualTo: Storage.getValue(FbConstant.uid))
        .get();

    setState(() {
      emailList.clear();
      emailList.addAll(
          snapshot.docs.map((doc) => doc.data()['email'].toString()).toList());
    });
  }

  @override
  void initState() {
    super.initState();
    fetchEmails();
  }

  void showCommentBottomSheet(BuildContext context) {
    bool _obscurePassword = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => value != null && value.contains('@')
                  ? null
                  : 'Enter valid email',
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) => TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'Min 6 characters',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text != "" &&
                    passwordController.text != "") {
                  Indicator.showLoading();
                  try {
                    var result = await _auth.createUserWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    final User? user = result.user;
                    String? branchId = user?.uid;
                    UserModel userModel = UserModel(
                      id: branchId,
                      role: "D",
                      email: emailController.text,
                      createdBy: Storage.getValue(FbConstant.uid),
                    );
                    await addBranchUserToUserCollection(userModel);
                    await fetchEmails();
                    Indicator.closeIndicator();
                    emailController.clear();
                    passwordController.clear();
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Sub Admin account created",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: const Color.fromRGBO(251, 164, 218, 0.6),
                      textColor: Colors.black,
                      fontSize: 18.0,
                    );
                  } on FirebaseAuthException catch (e) {
                    Indicator.closeIndicator();
                    if (e.code == 'email-already-in-use') {
                      Fluttertoast.showToast(msg: "Email already exists");
                    } else {
                      Fluttertoast.showToast(msg: e.message ?? "Error");
                    }
                  }
                } else {
                  Fluttertoast.showToast(
                    msg: "Email and password cannot be empty",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: const Color.fromRGBO(251, 164, 218, 0.6),
                    textColor: Colors.black,
                    fontSize: 18.0,
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value != null && value.contains('@')
                          ? null
                          : 'Enter valid email',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'Min 6 characters',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          Indicator.showLoading();
                          try {
                            var result =
                                await _auth.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            final User? user = result.user;
                            String? branchId = user?.uid;
                            UserModel userModel = UserModel(
                              id: branchId,
                              role: "D",
                              email: emailController.text,
                              createdBy: Storage.getValue(FbConstant.uid),
                            );
                            await addBranchUserToUserCollection(userModel);
                            await fetchEmails();
                            Indicator.closeIndicator();
                            emailController.clear();
                            passwordController.clear();
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Sub Admin account created",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor:
                                  const Color.fromRGBO(251, 164, 218, 0.6),
                              textColor: Colors.black,
                              fontSize: 18.0,
                            );
                          } on FirebaseAuthException catch (e) {
                            Indicator.closeIndicator();
                            if (e.code == 'email-already-in-use') {
                              Fluttertoast.showToast(
                                  msg: "Email already exists");
                            } else {
                              Fluttertoast.showToast(msg: e.message ?? "Error");
                            }
                          }
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: emailList.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(emailList[index]));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCommentBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SubAdminController with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
