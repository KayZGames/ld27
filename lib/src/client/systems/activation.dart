part of client;

typedef Future<Map<String, String>> AchievementLoader();
typedef Future<SpriteSheet> GraphicsLoader(int version);

class FeatureActivationSystem extends IntervalEntitySystem {
  int executionCount = 0;
  int graphicsVersion = 0;
  int nextFeatureIndex;
  List<Feature> features = new List<Feature>();

  LayeredSpriteSheet sheet;
  AchievementLoader achievementLoader;
  GraphicsLoader graphicsLoader;
  AudioHelper helper;
  FeatureActivationSystem(this.achievementLoader, this.graphicsLoader, this.sheet, this.helper) : super(10000, Aspect.getEmpty());

  void initialize() {
    features.add(_achivementFeature);
    features.add(_graphicsUpdateFeature);
    features.add(_graphicsUpdateFeature);
    features.add(_soundActivationFeature);
    features.add(_tankSpawnerActivationFeature);
    features.add(_planeSpawnerActivationFeature);

    nextFeatureIndex = random.nextInt(features.length);
    features[nextFeatureIndex].preparationResult = features[nextFeatureIndex].prepare();
  }

  void processEntities(ReadOnlyBag<Entity> entities) {
    var feature = features.removeAt(nextFeatureIndex);
    var playtime = '${++executionCount * 10} seconds played!';
    feature.activate(feature.preparationResult);
    addNewEntity(world, [new Achievement(feature.achivementId, playtime), new ExpirationTimer(8000.0)]);

    if (features.length > 0) {
      nextFeatureIndex = random.nextInt(features.length);
      var nextFeature = features[nextFeatureIndex];
      nextFeature.preparationResult = nextFeature.prepare();
    }
  }

  bool checkProcessing() => super.checkProcessing() && features.length > 0;

  Feature get _achivementFeature {
    var prepare = achievementLoader;
    var activate = (_) => (world.getSystem(AchievementRenderSystem) as AchievementRenderSystem).activate();
    return new Feature('achievements', prepare, activate);
  }

  Feature get _graphicsUpdateFeature {
    var prepare = () => graphicsLoader(++graphicsVersion);
    return new Feature('graphics1', prepare, _activateGraphicsUpdate);
  }

  Feature get _soundActivationFeature {
    return new Feature('sound', _prepareSoundActivation, _activateSound);
  }

  Feature get _planeSpawnerActivationFeature {
    return new Feature('planes', _noopPrepare, _activatePlaneSpawner);
  }

  Feature get _tankSpawnerActivationFeature {
    return new Feature('tanks', _noopPrepare, _activateTankSpawner);
  }

  void _noopPrepare() {}

  void _activateGraphicsUpdate(Future<SpriteSheet> layerFuture) {
    layerFuture.then((layer) {
      sheet.add(layer);
      (world.getSystem(BackgroundRenderingSystem) as BackgroundRenderingSystem).prepareBackground(1);
    });
  }

  Future _prepareSoundActivation() {
    List<String> names = ['shoot_0', 'collision_0'];
    for (int i = 0; i < SOUNDS_EXPLOSION; i++) {
     names.add('explosion_$i');
    }
    return helper.loadAudioClips(names);
  }

  void _activateSound(Future preparationResult) {
    preparationResult.then((_) {
      SoundSystem soundSystem = world.getSystem(SoundSystem);
      soundSystem.activate();
    });
  }

  void _activatePlaneSpawner(_) {
    PlaneSpawningSystem system = world.getSystem(PlaneSpawningSystem);
    system.activate();
  }

  void _activateTankSpawner(_) {
    TankSpawningSystem system = world.getSystem(TankSpawningSystem);
    system.activate();
  }
}

class Feature {
  String achivementId;
  Future preparationResult;
  Function prepare;
  Function activate;
  Feature(this.achivementId, this.prepare, this.activate);
}