import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../resource/color_manager.dart';
import '../../../../resource/styles_manager.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/default_button.dart';
import '../../../../widgets/custom_app_bar.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  static String routeName = "/order_screen";

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OtherScreenAppBar(
        onBackClick: () {
          AppUtils.navigateUp(context);
        },
        title: "Order",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18.sp),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart',
                    style: getBoldStyle(
                      color: ColorManager.primary,
                      fontSize: 19.sp,
                    ),
                  ),
                  Text(
                    'Clear(2)',
                    style: getMediumStyle(
                      color: ColorManager.colorGrey,
                      fontSize: 17.5.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25.sp),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.sp),
                child: Column(
                  children: [
                    orderItem(),
                    SizedBox(height: 20.sp),
                    orderItem(),
                    SizedBox(height: 20.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Total QTY : ',
                                style: getMediumStyle(
                                  color: ColorManager.colorBlack,
                                  fontSize: 17.sp,
                                ),
                              ),
                              TextSpan(
                                text: ' 2',
                                style: getRegularStyle(
                                  color: ColorManager.grey,
                                  fontSize: 16.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Total : ',
                                style: getMediumStyle(
                                  color: ColorManager.colorBlack,
                                  fontSize: 17.sp,
                                ),
                              ),
                              TextSpan(
                                text: ' ₹ 55,000',
                                style: getRegularStyle(
                                  color: ColorManager.grey,
                                  fontSize: 16.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.sp),
                    TextIconButton(
                      onPress: () {},
                      text: 'Add Item',
                      iconWidget: Icon(Icons.add, color: ColorManager.primary),
                    ),
                    SizedBox(height: 15.sp),
                    DefaultButton(
                      onPress: () {},
                      text: 'Order now',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.sp),

              // Your order
              Text(
                'Your order',
                style: getBoldStyle(
                  color: ColorManager.primary,
                  fontSize: 19.sp,
                ),
              ),
              SizedBox(height: 25.sp),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Order no : ',
                            style: getMediumStyle(
                              color: ColorManager.colorBlack,
                              fontSize: 17.sp,
                            ),
                          ),
                          TextSpan(
                            text: ' 001',
                            style: getRegularStyle(
                              color: ColorManager.grey,
                              fontSize: 16.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Jan 21, 18:03',
                      style: getRegularStyle(
                        color: ColorManager.grey,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.sp),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.sp),
                child: Column(
                  children: [
                    orderItem(),
                    SizedBox(height: 20.sp),
                    orderItem(),
                    SizedBox(height: 20.sp),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Total QTY : ',
                            style: getMediumStyle(
                              color: ColorManager.colorBlack,
                              fontSize: 17.sp,
                            ),
                          ),
                          TextSpan(
                            text: ' 2',
                            style: getRegularStyle(
                              color: ColorManager.grey,
                              fontSize: 16.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Total : ',
                            style: getMediumStyle(
                              color: ColorManager.colorBlack,
                              fontSize: 17.sp,
                            ),
                          ),
                          TextSpan(
                            text: ' ₹ 55,000',
                            style: getRegularStyle(
                              color: ColorManager.grey,
                              fontSize: 16.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNaW2O0A0v7PI4pmOaFJKBeVHNGCNU09hHZRFUX6ch4w587QOtCiPqxlH3em9VJG3PqZQ&usqp=CAU',
          width: 28.sp,
          height: 33.sp,
          fit: BoxFit.cover,
        ),
        SizedBox(width: 13.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Banarasi Saree',
              style: getBoldStyle(
                color: ColorManager.primary,
                fontSize: 17.5.sp,
              ),
            ),
            SizedBox(height: 13.sp),
            Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Code :',
                        style: getRegularStyle(
                          color: ColorManager.primary,
                          fontSize: 16.5.sp,
                        ),
                      ),
                      TextSpan(
                        text: ' BS0054',
                        style: getRegularStyle(
                          color: ColorManager.grey,
                          fontSize: 16.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.sp),
                Text(
                  '20 X 550=11,000',
                  style: getMediumStyle(
                    color: ColorManager.primary,
                    fontSize: 16.5.sp,
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
