part of client;

class SoundSystem extends EntityProcessingSystem {
  ComponentMapper<Sound> sm;
  AudioManager audioManager;
  bool active = false;
  SoundSystem(this.audioManager) : super(Aspect.getAspectForAllOf([Sound]));

  initialize() {
    sm = new ComponentMapper<Sound>(Sound, world);
  }

  processEntity(Entity e) {
    if (active) {
      var sound = sm.get(e);
      audioManager.playClipFromSource('default', sound.clipName);
    }
    e.deleteFromWorld();
  }

  void activate() {
    active = true;
  }
}