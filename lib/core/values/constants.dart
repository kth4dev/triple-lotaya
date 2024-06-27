//Rest API Base Url

// const String baseUrl="http://103.233.204.110:2201/api/v1/";
// const String baseUrl="http://172.16.0.71:8002/api/v1/";
// const String baseUrl="http://172.16.0.71:8001/api/v1/";
import 'package:intl/intl.dart';

const  int currentVersionCode=2;
const String baseUrl="http://172.16.0.71:8100/api/v1/";

//API Custom Keys , Status Code & Messages
const statusCode="STATUS_CODE";
const errorMessage="ERROR_MESSAGE";

const somethingWrongStatusCode=0;
const somethingWrongStatusMessage="Something went wrong!";

const noInternetStatusCode=1;
const noInternetStatusMessage="Check your internet connection!";

const timeOutStatusCode=2;
const timeOutStatusMessage="Time out!";



String formatMoney(int value) {

    return NumberFormat("#,##0", "en_US").format(value);

}

String formatMoneyForNum(num value) {
    if (value % 1 == 0) {
        return NumberFormat("#,##0", "en_US").format(value.toInt());
    } else {
        return NumberFormat("#,##0.00", "en_US").format(value);
    }
}