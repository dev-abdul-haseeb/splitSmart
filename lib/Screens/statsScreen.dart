import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:split_smart/Widgets/colors.dart';
import 'package:split_smart/Widgets/loadingDots.dart';
import '../DatabaseHandling.dart';
import '../Widgets/CardEntryWidget.dart';
import '../Widgets/TextStyles.dart';

class statsScreen extends StatefulWidget {
  const statsScreen({super.key});

  @override
  State<statsScreen> createState() => _statsScreenState();
}
var cardImages = ['Assets/Images/Visa.jpg',
  'Assets/Images/Master.png',
  'Assets/Images/AmericanExpress.jpeg',
  'Assets/Images/Discover.jpeg'];

class _statsScreenState extends State<statsScreen> {
  var screenWidth;
  var screenHeight;
  var chartData;
  bool isLoading = false;

  Widget Chart() {
    return SizedBox(
      height: screenHeight * 0.2,
      child: PieChart(
        dataMap: chartData,
        chartType: ChartType.disc,
        animationDuration: Duration(milliseconds: 800),
        chartRadius: screenWidth / 1.2,
        colorList: [
          ?ErrorColor(context),
          ?Success(context),
          ?TextSecondary(context),
        ],
        chartValuesOptions: ChartValuesOptions(
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 2,
          showChartValueBackground: false,
          chartValueStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenHeight*0.012
          ),
        ),
        legendOptions: LegendOptions(
          showLegends: true,
          legendPosition: LegendPosition.right,
          legendTextStyle: TextStyle(
            color: TextPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget Listing() {
    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: userRelationsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: loadingDots());
          }

          final relations = snapshot.data!;

          if (relations.isEmpty) {
            return Center(
              child: Text(
                "No expense relations yet.",
                style: heading2(screenHeight, context),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Email", style: subTitle(screenHeight, context)),
                  SizedBox(width: screenWidth*0.2,),
                  Text("To Give\n(Rs)", style: TextStyle(color: TextSecondary(context))),
                  SizedBox(width: screenWidth*0.01,),
                  Text("To Take\n(Rs)", style: TextStyle(color: TextSecondary(context))),
                  SizedBox(width: screenWidth*0.05,),
                  Text("Action", style: subTitle(screenHeight, context)),
                ],
              ),
              Divider(color: DividerColor(context)),

              // Table Rows
              Expanded(
                child: ListView.builder(
                  itemCount: relations.length,
                  itemBuilder: (context, index) {
                    final person = relations[index];
                    final email = person["email"];
                    final toGive = person["toGive"];
                    final toTake = person["toTake"];

                    return Container(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      decoration: BoxDecoration(
                        color: Surface(context),
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Email
                          Flexible(
                            flex: 4,
                            child: Text(
                              email,
                              style: TextStyle(color: TextPrimary(context)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // To Give
                          Flexible(
                            flex: 2,
                            child: Text(
                              "${toGive.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: ErrorColor(context),
                              ),
                            ),
                          ),
                          // To Take
                          Flexible(
                            flex: 2,
                            child: Text(
                              "${toTake.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Success(context),
                              ),
                            ),
                          ),
                          // Settle Up Button
                          SizedBox(
                            width: screenWidth * 0.15,
                            height: screenHeight*0.035,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Button(context),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(screenWidth * 0.015),
                                ),
                              ),
                              onPressed: () async {
                                if(toTake == 0 && toGive != 0){
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (context) => SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.85,
                                      child: CardEntryWidget(
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                        amount: toGive,
                                        onSuccess: () {
                                          markAsPaid(email, toGive);
                                        },
                                      ),
                                    ),
                                  );
                                }
                                else {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await settleUpWithUser(email);
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              child: FittedBox(
                                child: Text(
                                  "Settle",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Background(context),
      appBar: AppBar(
        backgroundColor: Background(context),
        elevation: 0,
        title: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.02),
          child: Text('Statistics', style: heading1(screenHeight, context)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.015),
        child: StreamBuilder<Map<String, double>>(
          stream: transactionOfAllGroups(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.hasError) {
              return Center(child: loadingDots());
            }
            final data = snapshot.data!;
            final give = data['give']!;
            final take = data['take']!;
            final given = data['given']!;
            final received = data['received']!;

            chartData = <String, double>{
              "You owe": give,
              "Others owe you": take,
              "Cleared": given + received,
            };

            return Stack(
              children:[
                Column(
                  children: [

                    Chart(),

                    SizedBox(height: screenHeight * 0.02),
                    Divider(color: DividerColor(context),),
                    SizedBox(height: screenHeight * 0.02),

                    Listing(),
                  ],
                ),
                if(isLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: screenWidth * 0.4),
                      child: SpinKitWave(
                        color: Primary(context),
                        size: screenWidth * 0.1,
                      ),
                    ),
                  ),
              ]
            );
          },
        ),
      ),
    );
  }
}


