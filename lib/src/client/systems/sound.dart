part of client;

class SoundSystem extends EntityProcessingSystem {
  ComponentMapper<Sound> sm;
  AudioHelper helper;
  bool active = false;
  SoundSystem(this.helper) : super(Aspect.getAspectForAllOf([Sound]));

  initialize() {
    sm = new ComponentMapper<Sound>(Sound, world);
  }

  processEntity(Entity e) {
    if (active) {
      var sound = sm.get(e);
      helper.playClip(sound.clipName);
    }
    e.deleteFromWorld();
  }

  void activate() {
    active = true;
  }
}