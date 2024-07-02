import 'package:client/src/common/widgets/bottom_drawer/view_models/bottom_sheet_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomSheetProvider = ChangeNotifierProvider(
  (ref) => BottomSheetViewModel(),
);
