library ld27;

import 'package:ld27/client.dart';

void main() {
  new Game().start();
}

class Game extends GameBase {
  LayeredSpriteSheet sheet;

  Game() : super('ld27', 'canvas', MAX_WIDTH, MAX_HEIGHT);

  void onInit() {
    sheet = new LayeredSpriteSheet(spriteSheet);
    world.addManager(new TagManager());
    world.addManager(new PlayerManager());
  }

  void onInitDone() {}

  void createEntities() {
    var entity = addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 100.0, 0.0), new Velocity(0.0, 0.0), new BodyDef('ship_0')]);
    addNewEntity(world, [new Transform.w2d(MAX_WIDTH/2.0, MAX_HEIGHT - 170.0, 0.0), new Velocity(0.0, 0.0), new Gun(1, 500.0)], player: PLAYER_1);

    (world.getManager(TagManager) as TagManager).register(entity, PLAYER_1);
  }

  List<EntitySystem> getSystems() {
    return [
      // Input
      new MouseInputHandlingSystem(canvas),
      // Logic
      new MovementSystem(),
      new CollisionDetectionSystem(bodyDefs),
      new DestroyOnCollisionSystem(),
      new DestructionSystem(),
      new DamageToHealthSystem(),
      new CooldownSystem(),
      new ExpirationSystem(),
      // Spawning
      new CollisionImpactSpawningSystem(),
      new DestructionExplosionSpawningSystem(),
      new BulletSpawningSystem(),
      new TruckSpawningSystem(),
      new TankSpawningSystem(),
      new PlaneSpawningSystem(),
      new FeatureActivationSystem(_achievementLoader, _graphicsLoader, sheet, helper.audioHelper),
      // Sound
      new SoundSystem(helper.audioHelper),
      // Rendering
      new BackgroundRenderingSystem(canvas.context2D, sheet),
      new EntityRenderingSystem(canvas.context2D, sheet),
      new AchievementRenderSystem(canvas.context2D),
     ];
  }

  Future<Map<String, String>> _achievementLoader() => helper.loadAchievements().then(setAchievementsToAchivementRenderSystem);
  Future<SpriteSheet> _graphicsLoader(int version) => helper.loadSpritesheet('assetsv$version');

  void setAchievementsToAchivementRenderSystem(Map<String, String> achievements) {
    AchievementRenderSystem system = world.getSystem(AchievementRenderSystem);
    system.achievements = achievements;
  }
}