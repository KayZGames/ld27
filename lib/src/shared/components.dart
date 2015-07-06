part of shared;

class Gun extends Component {
  double cooldown;
  int damage;
  Gun(this.damage, this.cooldown);
}

class Cooldown extends Component {
  double value;
  Cooldown(this.value);
}

class Velocity extends Component {
  double abs, angle;
  Velocity(this.abs, this.angle);
}

class ExpirationTimer extends Component {
  double time, maxTime;
  ExpirationTimer(this.maxTime) {
    time = maxTime;
  }
}

class BodyDef extends Component {
  String bodyId;
  BodyDef(this.bodyId);
}

class Damage extends Component {
  int value;
  Damage(this.value);
}

class DamageOnCollision extends Component {
  int value;
  DamageOnCollision(this.value);
}

class Health extends Component {
  int maxHealth, currentHealth;
  Health(this.maxHealth) {
    currentHealth = maxHealth;
  }
}

class Sound extends Component {
  final String clipName;
  Sound(this.clipName);
}

class Achievement extends Component {
  String id;
  String playtime;
  Achievement(this.id, this.playtime);
}

class Effect extends Component {}
class Collision extends Component {}
class Destruction extends Component {}
class ImpactOnCollision extends Component {}
class DestroyOnCollision extends Component {}
class ExplosionOnDestruction extends Component {}

class Transform extends Component {
  static final CT = ComponentTypeManager.getTypeFor(Transform);

  Vector3 position3d;
  Vector3 rotation3d;
  Vector3 scale3d;

  // 2d view
  Vector2 _position2d = new Vector2.zero();
  double get angle => rotation3d.z;
  set angle(double v) => rotation3d.z = v;
  Vector2 get position {
    _position2d.x = position3d.x;
    _position2d.y = position3d.y;
    return _position2d;
  }
  set position(Vector2 v) {
    position3d.x = v.x;
    position3d.y = v.y;
  }

  Transform._();
  static _ctor() => new Transform._();
  factory Transform.w2d(double x, double y, double a) {
    return new Transform.w3d(new Vector3(x, y, 0.0), new Vector3(0.0, 0.0, a));
  }
  factory Transform.w3d(Vector3 position, [Vector3 rotation, Vector3 scale]) {
    var c = new Pooled.of(Transform, _ctor) as Transform;
    c.position3d = position;
    c.rotation3d = (rotation == null) ? new Vector3(0.0, 0.0, 0.0) : rotation;
    c.scale3d = (scale == null) ? new Vector3(1.0, 1.0, 1.0) : scale;
    return c;
  }
}
