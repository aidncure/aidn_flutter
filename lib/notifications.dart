import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/Notification.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'Bookappointment.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';

class notifications extends StatefulWidget {
  @override
  _notificationsState createState() => _notificationsState();
}

class _notificationsState extends State<notifications> {
  List<Data> userNotification = [];

  bool _loadding = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callApiNotification();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color:  Palette.dark_blue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor:  Palette.white,
        title: Text(
          getTranslated(context, notification_title).toString(),
          style: TextStyle(fontSize: 18, color:  Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _loadding,
        opacity: 0,
        progressIndicator: SpinKitFadingCircle(
          color:  Palette.blue,
          size: 50.0,
        ),
        child: userNotification.length > 0
            ? SingleChildScrollView(
                child: ListView.builder(
                  itemCount: userNotification.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    String date = DateUtil()
                        .formattedDate(DateTime.parse(userNotification[index].createdAt!));
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: width * 0.01, vertical: width * 0.02),
                          child: Row(
                            children: [
                              Container(
                                width: width * 0.15,
                                alignment: AlignmentDirectional.center,
                                margin: EdgeInsets.symmetric(
                                    horizontal: width * 0.01, vertical: width * 0.02),
                                child: Column(
                                  children: [
                                    Container(
                                      width: width * 0.15,
                                      height: height * 0.065,
                                      child: CachedNetworkImage(
                                        alignment: Alignment.center,
                                        imageUrl: userNotification[index].doctor!.fullImage!,
                                        imageBuilder: (context, imageProvider) => CircleAvatar(
                                          radius: 50,
                                          backgroundColor:  Palette.image_circle,
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundImage: imageProvider,
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            // CircularProgressIndicator(),
                                            SpinKitFadingCircle(color:  Palette.blue),
                                        errorWidget: (context, url, error) =>
                                            Image.asset("assets/images/no_image.jpg"),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: width * 0.8,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text(
                                                userNotification[index].doctor!.name!,
                                                style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    color:  Palette.dark_blue,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '$date',
                                                style: TextStyle(
                                                  fontSize: width * 0.03,
                                                  color:  Palette.dark_blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: AlignmentDirectional.topStart,
                                        child: Text(
                                          userNotification[index].message!,
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                            color:  Palette.dark_blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Column(
                            children: [
                              DottedLine(
                                direction: Axis.horizontal,
                                lineLength: double.infinity,
                                lineThickness: 1.0,
                                dashLength: 3.0,
                                dashColor:  Palette.blue,
                                dashRadius: 0.0,
                                dashGapLength: 1.0,
                                dashGapColor:  Palette.transparent,
                                dashGapRadius: 0.0,
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            : Container(
                child: Center(
                  child: Text(
                    getTranslated(context, notification_notFound).toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:  Palette.dark_blue,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<BaseModel<UserNotification>> callApiNotification() async {
    UserNotification response;
    setState(() {
      _loadding = true;
    });
    try {
      response = await RestClient(Retro_Api().Dio_Data()).notificationRequest();
      setState(() {
        _loadding = false;
        if (response.success == true) {
          setState(() {
            _loadding = false;
            userNotification.addAll(response.data!);
          });
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
