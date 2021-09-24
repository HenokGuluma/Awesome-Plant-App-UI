import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../main.dart';



class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{

  bool dropDownToggle = true;
  final List<ChartData> chartData = [
    ChartData('Abyssinia Bank', 2500, Colors.orange ),
    ChartData('Dashen Bank', 2000, Colors.pink),
    ChartData('Awash Bank', 4000, Colors.deepPurple),
    ChartData('Berhan Bank', 1000, Colors.lightBlue),
    ChartData('Enat Bank', 800, Colors.green),
    ChartData('Wegagen Bank', 1500, Colors.yellow)
  ];
  List<String> logos = [
    'assets/dashen bank logo.jpg',
    'assets/abyssinia bank logo.png',
    'assets/enat bank logo.png',
  ];
  List<dynamic> duePaymentData;
  List<dynamic> moneyCollectedData;
  bool dataLoaded = false;
  Map<String, bool> bookmarkMap = Map();
  String centerText = 'Bank Info';
  String duePaymentsUrl = 'https://610e396448beae001747ba80.mockapi.io/duePayments';
  String collectedPaymentsUrl = 'https://610e396448beae001747ba80.mockapi.io/collectedPayments';
  int touchedIndex = -1;
  int explodeIndex = 0;
  double amountOwed= 0;
  String bankName = '';
  String totalOwed = '';



  @override
  void initState() {
    super.initState();
    getDuePaymentsData().then((value) {
      setState(() {
        duePaymentData = value;
      });
      getMoneyCollectedData().then((value){
        setState(() {
          moneyCollectedData = value;
          dataLoaded = true;
        });
      });
    });
    totalOwed = calculateTotalOwed(chartData);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateManager = Provider.of<UserVariables>(context, listen: false);
    bookmarkMap = stateManager.bookmarkMap;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 50,
          bottomOpacity: 0,
          backgroundColor: Colors.white,
          title: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: Image.asset('assets/male_model.jpg').image,
                  fit: BoxFit.cover,
                ),
              ),
              width: 30,
              height: 30,
           ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.bookmark_border, color: Colors.grey,),
            )
          ],
        ),
        body: Column(
          children: [
            TitleWidget(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height-135,
              child: ListView(
                children: [
                  //Visibility Widget
                  dropDownToggle
                  ?PieChartWidget()
                  :Center(),
                  SizedBox(
                      height: 10
                  ),
                  DuePaymentsContainer(),
                  SizedBox(
                      height: 10
                  ),
                  MoneyCollectedWidget(),
                ],
              ),
            )
          ],
        )
    );
  }

  String calculateTotalOwed(List<ChartData> data) {
    double totalOwed = 0;
    for (int i =0; i< data.length; i++){
      totalOwed+=data[i].y;
    }
    var formatter = NumberFormat('#,##,000');

    return formatter.format(totalOwed);
  }

  getDuePaymentsData() async {
    var paymentData = await http.get(Uri.parse(duePaymentsUrl));
    duePaymentData = json.decode(paymentData.body);
    print('the data is: ');
    print(duePaymentData);
    return duePaymentData;
  }
  getMoneyCollectedData() async {
    var collectedData = await http.get(Uri.parse(collectedPaymentsUrl));
    moneyCollectedData = json.decode(collectedData.body);
    print('the data is: ');
    print(moneyCollectedData);
    return moneyCollectedData;
  }
  int daysLeft(String timestamp){
    var givenDay = DateTime.parse(timestamp);
    var difference = DateTimeRange(start: givenDay, end: DateTime.now());
    int days = difference.duration.inDays;
    return days;
  }
  TitleWidget(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Container(
              width: MediaQuery.of(context).size.width*0.5,
              child: Text.rich(
                TextSpan(
                  text: 'Hi, ',
                  style: TextStyle(fontSize: 16, color: Color(0xff555555)),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Alem ',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xff555555)
                        )),
                    TextSpan(
                        text: 'have ',
                        style: TextStyle(
                            color: Color(0xff555555)
                        )),
                    TextSpan(
                        text: 'ETB ${totalOwed} ',
                        style: TextStyle(
                            color: Colors.green
                        )),
                    TextSpan(
                        text: 'unpaid debt.',
                        style: TextStyle(
                            color: Color(0xff555555)
                        )),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
              onPressed: (){
                if(dropDownToggle){
                  setState(() {
                    dropDownToggle = false;
                  });
                }
                else{
                  setState(() {
                    dropDownToggle = true;
                  });
                }
              },
              icon: dropDownToggle
          ?Icon(Icons.arrow_drop_up, color: Colors.black,)
          :Icon(Icons.arrow_drop_down, color: Colors.black,))
        ],
      ),
    );
  }
  void legendClicked(ChartPointDetails args) {
    print(args.pointIndex);
    setState(() {
      explodeIndex = args.pointIndex;
      bankName = chartData[args.pointIndex].x;
      amountOwed = chartData[args.pointIndex].y;
    });
  }

  PieChartConstructor(){
    return SfCircularChart(
      //centerX: '80',
      legend: Legend(
        isVisible: true, iconHeight: 10, iconWidth: 10, position: LegendPosition.left,
        overflowMode: LegendItemOverflowMode.wrap, alignment: ChartAlignment.far, width: '20%'
      ),

        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            horizontalAlignment: ChartAlignment.center,
              verticalAlignment: ChartAlignment.center,
              widget: Container(
                child: Column(
                  children: [
                    Text('ETB ${amountOwed}', style: TextStyle( color: Color(0xff222222), fontSize: 18)),
                    Text(bankName, style: TextStyle( color: Color(0xff555555), fontSize: 14,), overflow: TextOverflow.ellipsis,)
                  ],
                )
                ),
          )
        ],
        series: <CircularSeries>[
      DoughnutSeries<ChartData, String>(
        onPointTap: (ChartPointDetails args) => legendClicked(args),
        explodeIndex: explodeIndex,
          strokeColor: Colors.transparent,
          explodeOffset: '20%',
          explode: true,
          dataSource: chartData,
          pointColorMapper: (ChartData data, _) => data.color,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          innerRadius: '80%',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            useSeriesColor: true,
            opacity: 1,
            labelAlignment: ChartDataLabelAlignment.middle,
            labelPosition: ChartDataLabelPosition.inside,
            margin: EdgeInsets.all(10),
            //color: Colors.white,
            borderColor: Colors.transparent,
            showCumulativeValues: true,
          ),
          enableSmartLabels: true,
          // Radius of doughnut
          radius: '100%')
    ]);
  }

  PieChartWidget(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 250,
      child:  PieChartConstructor()
    );
  }
  DuePaymentsContainer(){
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('Due Payments', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: dataLoaded
            ?ListView.builder(
                //shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: duePaymentData.length,
                  itemBuilder: ((context, index) => DuePaymentsWidget(index)))
              :Center(
                child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black)),
              ),
            )
          ],
        )
    );
  }
  DuePaymentsWidget(int index){
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Container(
        width: 130,
        height: 350,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xffdddddd), width: 0.5)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red),
                  image: DecorationImage(
                    image: Image.asset(logos[index]).image,
                    fit: BoxFit.cover,
                  ),
                ),
                width: 80,
                height: 80,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
               duePaymentData[index]['name'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on_rounded, color: Colors.red, size: 15,),
                Text('ETB ${duePaymentData[index]['owedAmount']}')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.access_time_filled_rounded, color: Colors.grey, size: 15,),
                //Text('3 days left'),
                Text('${daysLeft(duePaymentData[index]['dueDate'])} days left')
              ],
            ),
            MaterialButton(
              onPressed: (){
                final snackBar = SnackBar(
                  content: Text('Paid ${duePaymentData[index]['owedAmount']} ETB to ${duePaymentData[index]['name']}.'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Container(
                width: 100,
                height: 25,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Center(
                  child: Text('Pay', style: TextStyle(color: Colors.red),),
                )
              ),)
          ],
        ),
      ),
    );
  }
  MoneyCollectedWidget(){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 400,
      child: Column(
        children: [
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.4,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Color(0xff64a840),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child:  Text('Money Collected', style: TextStyle(color: Colors.white),),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xff999999))
                  ),
                  child: Center(
                    child: Text('Money Due', style: TextStyle(color: Color(0xff999999)),),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 350,
            child: CollectedWidget()
            /*TabBarView(
              children: <Widget>[
                CollectedWidget(),
                CollectedWidget()
              ],
              controller: _tabController,
            )*/,
          )
        ],
      ),
    );
  }

  String calculateFrequency(int frequency){
    if(frequency.isEven){
      return 'Monthly';
    }
    else if(frequency%3 ==0){
      return 'Weekly';
    }
    else{
      return 'Annual';
    }
  }

  CollectedWidget(){
    return dataLoaded
    ?GridView.builder(
      itemCount: moneyCollectedData.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 0.0, mainAxisSpacing: 0, childAspectRatio: 13/10),
        itemBuilder: ((context,index){
          return GridWidget(index);
        }))
    : Center(
      child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.black)),
    );
  }
  GridWidget(int index){
    final stateManager = Provider.of<UserVariables>(context, listen: false);
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xffdddddd))
        ),
        height: 80,
        width: MediaQuery.of(context).size.width*0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                        image: Image.asset('assets/money bag.png').image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width*0.12,
                    height: MediaQuery.of(context).size.width*0.12,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.01,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.3,
                        child: Text('${moneyCollectedData[index]['title']}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),),
                      ),
                      Row(
                        children: [
                          Icon(Icons.access_time_filled, color: Color(0xff777777), size: 16,),
                          Text(calculateFrequency(moneyCollectedData[index]['frequency']), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 14),)
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
           /* Container(
              height: 80,
              child:*/ Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_sharp, size: 16, color: Color(0xff777777),),
                            SizedBox(width: 2,),
                            Text('100 Cycles', style: TextStyle(color: Colors.grey, fontSize: 14),)
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.monetization_on, size: 16, color:  Color(0xff777777),),
                            SizedBox(width: 2,),
                            Text('ETB ${moneyCollectedData[index]['amount']}', style: TextStyle(color: Colors.grey, fontSize: 14),)
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.group, size: 16, color:  Color(0xff777777),),
                            SizedBox(width: 2,),
                            Text('${moneyCollectedData[index]['membersCount']} Members', style: TextStyle(color: Colors.grey, fontSize: 14),)
                          ],
                        )
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20,),
                      IconButton(
                          onPressed: (){
                            if(bookmarkMap.containsKey(moneyCollectedData[index]['title'])){
                              setState(() {
                                bookmarkMap.remove(moneyCollectedData[index]['title']);
                                stateManager.removeBookmark(moneyCollectedData[index]['title']);
                              });
                            }
                            else{
                              setState(() {
                                bookmarkMap[moneyCollectedData[index]['title']] = true;
                                stateManager.bookmark(moneyCollectedData[index]['title']);
                              });
                              final snackBar = SnackBar(
                                content: Text('Bookmarked ${moneyCollectedData[index]['amount']} payment.'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          },
                          icon: bookmarkMap.containsKey(moneyCollectedData[index]['title'])
                        ?Icon(Icons.bookmark, size: 25, color: Colors.black,)
                      :Icon(Icons.bookmark_border, size: 25, color: Colors.grey,))
                    ],
                  )
                ],
              ),
            //)
          ],
        ),
      ),
    );
  }

}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color color;
}
