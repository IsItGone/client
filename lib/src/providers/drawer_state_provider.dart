import 'package:client/src/state/drawer_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final drawerStateProvider = ChangeNotifierProvider((ref) => DrawerState(
      minHeight: 300,
      maxHeight: 600,
    ));
