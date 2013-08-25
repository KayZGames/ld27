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
  double time;
  ExpirationTimer(this.time);
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

class Effect extends Component {}
class Collision extends Component {}
class Destruction extends Component {}
class ImpactOnCollision extends Component {}
class DestroyOnCollision extends Component {}
class ExplosionOnDestruction extends Component {}