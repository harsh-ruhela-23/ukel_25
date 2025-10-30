import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/add_new_branch_screen.dart';
import 'package:ukel/admin_app/admin_ui/admin_home/branch_details_screen.dart';
import 'package:ukel/model/branch_model.dart';
import 'package:ukel/resource/fonts_manager.dart';
import 'package:ukel/resource/styles_manager.dart';
import 'package:ukel/ui/screens/home/home_repository.dart';
import 'package:ukel/utils/common_widget.dart';
import 'package:ukel/utils/constants.dart';

class AdminBranchesTab extends StatefulWidget {
  const AdminBranchesTab({super.key});

  @override
  State<AdminBranchesTab> createState() => _AdminBranchesTabState();
}

class _AdminBranchesTabState extends State<AdminBranchesTab> {
  final repository = HomeRepository();
  bool isBranchesListFetchingData = false;
  List<BranchModel> branchesList = [];
  String error = '';

  @override
  void initState() {
    super.initState();
    getBranchesList();
  }

  void getBranchesList() async {
    branchesList.clear();
    try {
      if (!isBranchesListFetchingData) {
        isBranchesListFetchingData = true;
        await repository.fetchBranches().then((list) {
          if (list.isNotEmpty) {
            branchesList.addAll(list);
            branchesList.add(BranchModel(
                id: '',
                createdBy: "",
                tag: "",
                sid: 0,
                createdAtDate: null,
                branchCode: null,
                branchDetailsModel: null,
                bankDetailsModel: null));
          }
        });

        error = '';
        isBranchesListFetchingData = false;
      }
    } catch (e) {
      error = e.toString();
      isBranchesListFetchingData = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.sp),
        child: Column(
          children: [
            SizedBox(height: 15.sp),

            // Branch List
            isBranchesListFetchingData
                ? Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: buildLoadingWidget,
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Text(error.toString()),
                      )
                    : branchesList.isEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 30.h),
                            child: Center(child: addNewBranchCard()),
                          )
                        : buildBranchListWidget(),
          ],
        ),
      ),
    );
  }

  Widget buildBranchListWidget() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.1,
          crossAxisCount: 2,
          crossAxisSpacing: 24.0,
          mainAxisSpacing: 4.0),
      shrinkWrap: true,
      itemCount: branchesList.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 15.sp),
          child: index == branchesList.length - 1
              ? addNewBranchCard()
              : branchItemCard(index: index, model: branchesList[index]),
        );
      },
    );
  }

  Widget branchItemCard({required BranchModel model, required int index}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BranchDetailsScreen(branchModel: model),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          color: index % 2 == 1
              ? const Color(0XFFE1FAEC)
              : const Color(0XFFFAF4E1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${model.branchCode}',
              style: getBoldStyle(
                  color: Colors.grey.withOpacity(0.5),
                  fontSize: FontSize.largeExtra),
            ),
            SizedBox(height: 20.sp),
            Text(
              model.branchDetailsModel!.ownerAddress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getMediumStyle(
                  color: Colors.black, fontSize: FontSize.bigExtra),
            ),
            SizedBox(height: 8.sp),
            Text(
              model.branchDetailsModel!.ownerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  getMediumStyle(color: Colors.black, fontSize: FontSize.medium),
            ),
          ],
        ),
      ),
    );
  }

  Widget addNewBranchCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddNewBranchScreen(),
          ),
        ).then((value) {
          if (value == true) {
            getBranchesList();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.sp),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          color: const Color(0XFFFAF4E1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.black,
              size: 25.sp,
            ),
            SizedBox(height: 5.sp),
            Text(
              'Add New Branch',
              style: getBoldStyle(
                  color: Colors.black, fontSize: FontSize.mediumExtra),
            ),
          ],
        ),
      ),
    );
  }
}
