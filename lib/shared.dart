library shared;

import 'dart:math';

import 'package:dartemis/dartemis.dart';
export 'package:dartemis/dartemis.dart';
import 'package:dartemis_toolbox/system_transform.dart';
export 'package:dartemis_toolbox/system_transform.dart';
import 'package:dartemis_toolbox/utils_dartemis.dart';
export 'package:dartemis_toolbox/utils_dartemis.dart';
import 'package:vector_math/vector_math.dart';
export 'package:vector_math/vector_math.dart';
import 'package:gamedev_helpers/gamedev_helpers.dart';
export 'package:gamedev_helpers/gamedev_helpers.dart';

part 'src/shared/components.dart';
part 'src/shared/systems/collisions.dart';
part 'src/shared/systems/game_logic.dart';
part 'src/shared/systems/spawning.dart';

const MAX_WIDTH = 600;
const MAX_HEIGHT = 720;

const PLAYER_1 = 'player1';

const SOUNDS_EXPLOSION = 4;

Random random = new Random();