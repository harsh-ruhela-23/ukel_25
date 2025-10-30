import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/services/get_storage.dart';
import 'package:ukel/utils/app_utils.dart';
import 'package:ukel/utils/constants.dart';

import 'model/other/services_list_model.dart';

class AddNewServicesPage extends StatefulWidget {
  static String routeName = "/add_new_services_page";

  const AddNewServicesPage({super.key});

  @override
  State<AddNewServicesPage> createState() => _AddNewServicesPageState();
}

class _AddNewServicesPageState extends State<AddNewServicesPage> {
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController option1 = TextEditingController();
  final TextEditingController option2 = TextEditingController();
  final TextEditingController amount1 = TextEditingController();
  final TextEditingController amount2 = TextEditingController();
  final List<Map<String, TextEditingController>> _measurementControllers = [];
  var isOptionVisible = false;
  bool _isSubmitting = false;

  void _addRadioOption() {
    setState(() {
      isOptionVisible = !isOptionVisible;
      // if(isOptionVisible){
      //   _measurementControllers.clear();
      // }
    });
  }

  void _addMeasurementRow() {
    setState(() {
      isOptionVisible = false;
      _measurementControllers.add({
        'label': TextEditingController(),
      });
    });
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) {
      return;
    }
    final name = _serviceController.text.trim();
    final amount = _amountController.text.trim();
    if (name.isEmpty) {
      AppUtils.showToast("Enter service name");
      return;
    }

    final measurements = _measurementControllers
        .map((map) {
          return {
            'label': map['label']!.text.trim(),
          };
        })
        .where((e) => e['label']!.isNotEmpty)
        .toList();
    for (var item in measurements) {
      print('measurements: ${item['label']}');
    }
    int parsedAmount = 0;
    List<Map<String, dynamic>>? radioOptions;

    if (isOptionVisible) {
      final option1Name = option1.text.trim();
      final option2Name = option2.text.trim();
      final option1Amount = int.tryParse(amount1.text.trim());
      final option2Amount = int.tryParse(amount2.text.trim());

      if (option1Name.isEmpty || option2Name.isEmpty) {
        AppUtils.showToast("Enter option names");
        return;
      }

      if (option1Amount == null || option2Amount == null) {
        AppUtils.showToast("Enter valid option amounts");
        return;
      }

      radioOptions = [
        {
          "label": option1Name,
          "name": option1Name,
          "charges": option1Amount,
        },
        {
          "label": option2Name,
          "name": option2Name,
          "charges": option2Amount,
        },
      ];
    } else {
      if (amount.isEmpty) {
        AppUtils.showToast("Enter amount");
        return;
      }

      final amountValue = int.tryParse(amount);
      if (amountValue == null) {
        AppUtils.showToast("Enter valid amount");
        return;
      }

      parsedAmount = amountValue;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final serviceModel = await addServiceToFirestore(
        name,
        parsedAmount,
        measurements,
        radioOptions: radioOptions,
      );
      if (!mounted) return;
      Navigator.pop(context, serviceModel);
    } catch (error) {
      AppUtils.showToast('Failed to add service. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<ServicesListModel> addServiceToFirestore(
      String name, int charges, List<Map<String, String>> measurements,
      {List<Map<String, dynamic>>? radioOptions}) async {
    final docRef = FirebaseFirestore.instance.collection('service').doc();
    List<Map<String, dynamic>> options = [];
    List<String> generatedIds = [];
    if (radioOptions != null && radioOptions.isNotEmpty) {
      options.addAll(radioOptions);
      final serviceType =
      FirebaseFirestore.instance.collection('service_type').doc();
      if (measurements.isEmpty) {
        await serviceType.set({
          'id': serviceType.id,
          'option': options,
          'type': "radio",
          "value": ""
        });
        print("isOptionVisible");
        print(serviceType.id);
        generatedIds.add(serviceType.id);
      } else {
        for (var measurement in measurements) {
          final serviceType =
          FirebaseFirestore.instance.collection('service_type').doc();
          await serviceType.set({
            'id': serviceType.id,
            'name': measurement["label"],
            'type': "text",
            'unit': "inch",
            "validator": {"max_value": "100", "min_value": "0"}
          });
          print("measurements");
          print(serviceType.id);
          generatedIds.add(serviceType.id);
        }
        await serviceType.set({
          'id': serviceType.id,
          'option': options,
          'type': "radio",
          "value": ""
        });
        print("isOptionVisible");
        print(serviceType.id);
        generatedIds.add(serviceType.id);
      }
    } else {
      for (var measurement in measurements) {
        final serviceType =
        FirebaseFirestore.instance.collection('service_type').doc();
        await serviceType.set({
          'id': serviceType.id,
          'name': measurement["label"],
          'type': "text",
          'unit': "inch",
          "validator": {"max_value": "100", "min_value": "0"}
        });
        print("measurements");
        print(serviceType.id);
        generatedIds.add(serviceType.id);
      }
    }
    print("generatedIds");
    print(generatedIds);
    print(generatedIds.length);
    await docRef.set({
      'id': docRef.id,
      'name': name,
      'charges': charges,
      'type': generatedIds,
      "branch_id": Storage.getValue(FbConstant.uid)
    });
    print(docRef.id);
    return ServicesListModel(
      name: name,
      id: docRef.id,
      charges: charges,
      serviceTypeModelList: generatedIds,
    );
  }

  String generateRandomAlphanumeric(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _serviceController,
                decoration:
                    const InputDecoration(hintText: 'Enter service name'),
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: !isOptionVisible,
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(hintText: 'Enter Amount'),
                ),
              ),
              const SizedBox(height: 16),
              ..._measurementControllers.map((map) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: TextField(
                          controller: map['label'],
                          decoration: const InputDecoration(
                              hintText: 'Enter Part Name'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              Visibility(
                visible: isOptionVisible,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: option1,
                              decoration: const InputDecoration(
                                  hintText: 'Enter Option 1'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: option2,
                              decoration: const InputDecoration(
                                  hintText: 'Enter Option 2'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amount1,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                  hintText: 'Amount for option 1'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: amount2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                  hintText: 'Amount for option 2'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _addMeasurementRow,
                    child: const Text(
                      '+ Measurement',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: _addRadioOption,
                    child: const Text(
                      '+ more',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.btnColorDarkBlue,
                    ),
                    onPressed: _isSubmitting ? null : _onSubmit,
                    child: _isSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Saving...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            'Done',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
