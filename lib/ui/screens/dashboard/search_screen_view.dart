import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:ukel/model/service_invoice_model.dart';
import 'package:ukel/resource/color_manager.dart';
import 'package:ukel/ui/screens/home/home_view_model.dart';

import '../home/home_tab/job_tab.dart';
import '../home/invoice/invoice_details_screen.dart';
import '../home/service_invoice/service_invoice_screen.dart';

class SearchScreenView extends SearchDelegate {
  SearchScreenView(BuildContext context)
      : super(
            searchFieldLabel: 'Search for Service invoice',
            searchFieldStyle: TextStyle(fontSize: 16.sp));

  final viewModel = HomeViewModel();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return BackButton(color: ColorManager.primary);
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<ServiceInvoiceModel>?>(
      future: viewModel.onSearch(query),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // if serviceInvoice is inCompleted then navigate to update serviceInvoice screen
                      if (snapshot.data![index].serviceInvoiceStatusValue ==
                          -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceInvoiceScreen(
                                model: snapshot.data![index], isUpdate: true),
                          ),
                        );
                      } else {
                        // navigate to InvoiceDetailScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceDetailsScreen(
                                model: snapshot.data![index]),
                          ),
                        );
                      }
                    },
                    child: DeliveryJobItem(
                        allJobList: viewModel.allJobItemList,
                        serviceInvoiceModel: snapshot.data![index]),
                  );
                });
          } else {
            return const Center(
              child: Text('No result found.'),
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<ServiceInvoiceModel>?>(
      future: viewModel.onSearch(''),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // if serviceInvoice is inCompleted then navigate to update serviceInvoice screen
                      if (snapshot.data![index].serviceInvoiceStatusValue ==
                          -1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceInvoiceScreen(
                                model: snapshot.data![index], isUpdate: true),
                          ),
                        );
                      } else {
                        // navigate to InvoiceDetailScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceDetailsScreen(
                                model: snapshot.data![index]),
                          ),
                        );
                      }
                    },
                    child: DeliveryJobItem(
                        allJobList: viewModel.allJobItemList,
                        serviceInvoiceModel: snapshot.data![index]),
                  );
                });
          } else {
            return const Center(
              child: Text('No result found.'),
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
