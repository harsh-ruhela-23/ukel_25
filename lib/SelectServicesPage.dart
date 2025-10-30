import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ukel/ui/screens/home/service_invoice/widgets/add_new_customer_screen.dart';

import 'model/other/services_list_model.dart';

class SelectServicesPage extends StatefulWidget {
  final List<ServicesListModel> items;
  final List<ServicesListModel> initiallySelected;

  const SelectServicesPage({
    Key? key,
    required this.items,
    required this.initiallySelected,
  }) : super(key: key);

  @override
  _SelectServicesPageState createState() => _SelectServicesPageState();
}

class _SelectServicesPageState extends State<SelectServicesPage> {
  late List<ServicesListModel> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initiallySelected);
  }

  void _toggleSelection(ServicesListModel item, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(item);
      } else {
        _selected.remove(item);
      }
    });
  }

  void _deleteItem(ServicesListModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure you want to delete?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () {
              setState(() {
                widget.items.remove(item);
                _selected.remove(item);
                widget.initiallySelected.remove(item);
                FirebaseFirestore.instance
                    .collection('service')
                    .doc(item.id)
                    .delete();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Select Services"),
            backgroundColor: Colors.white),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (_, index) {
                  final item = widget.items[index];
                  final isSelected = _selected.contains(item);
                  return ListTile(
                    title: Text(item.name),
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (val) => _toggleSelection(item, val ?? false),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(item),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomView(
          onSaveClick: () {
            Navigator.pop(context, _selected);
          },
          onCancelClick: () {
            Navigator.pop(context);
          },
        ));
  }
}
