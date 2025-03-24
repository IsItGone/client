import 'package:client/features/home/widgets/bottom_drawer/view_models/bottom_drawer_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomDrawerProvider = ChangeNotifierProvider(
  (ref) => BottomDrawerViewModel(ref),
);
