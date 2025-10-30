import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/resource/color_manager.dart';

import '../model/color_model.dart';

class CustomColorPickerBottomSheet extends StatefulWidget {
  const CustomColorPickerBottomSheet({
    super.key,
    required this.selectedColorModel,
    required this.colorList,
  });

  final CustomColorModel? selectedColorModel;
  final List<CustomColorModel> colorList;

  @override
  State<CustomColorPickerBottomSheet> createState() =>
      _CustomColorPickerBottomSheetState();
}

class _CustomColorPickerBottomSheetState
    extends State<CustomColorPickerBottomSheet> {
  CustomColorModel? selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.selectedColorModel;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Pick a Color',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20,),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 0,
                    childAspectRatio: 1, // 🔑 makes each grid item a square
                  ),
                  itemCount: widget.colorList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            selectedColor = widget.colorList[index];
                            setState(() {});
                          },
                          child: Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(
                                  widget.colorList[index].colorCode!)),
                            ),
                            child: selectedColor != null &&
                                selectedColor!.name ==
                                    widget.colorList[index].name
                                ? const Icon(Icons.check)
                                : const SizedBox(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.colorList[index].name ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, selectedColor);
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

