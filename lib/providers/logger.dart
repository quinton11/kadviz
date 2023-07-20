import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class LoggerProvider extends ChangeNotifier {
  late var logger =
      Logger(filter: null, printer: PrettyPrinter(), output: null);
}
