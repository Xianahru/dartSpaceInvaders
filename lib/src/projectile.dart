part of SpaceInvader;

/**
 * Klasse Projectile
 * Besteht aus einem Koordinatenpaar und einer Bewegungsrichtung
 * Momentan soll nur der Spieler neue [Projectile] erstellen können
 */
class Projectile {
  Map<String, int> _coordinate;
  int _direction;

  SpaceInvaderModel _model;

  Projectile(Map<String, int> coor, SpaceInvaderModel mod) {
    this._coordinate = {'row': coor['row'], 'col': coor['col']};
    this._direction = coor['dir'];
    this._model = mod;
  }

  Map<String, int> get coordinate => this._coordinate;

  /**
   * Bewegt das Projektil eine Zeile nach oben oder unten abhängig von [_direction]
   * 
   */
  move() {
    if (_coordinate['row'] >= gamesize - 1 || _coordinate['row'] <= 0) 
      _model.removeProjectile(this);
    else {
      _coordinate['row'] += _direction;
      print('moved to row: ${_coordinate['row']}');
      this.detectCollision();
    }
  }

  /**
   * Überprüft dieses [Projectile] drauf, ob es sich auf dem gleichen Feld wie ein [EnemyShip] oder [PlayerShip] befindet.
   * Wenn ja, werden die [_hitpoints] von diesem [Ship] um 1 reduziert und das [Projectile] entfernt.
   */
  detectCollision() {
    List<EnemyShip> enemies = this._model.enemies.toList();
    for (EnemyShip enemy in enemies) {
      for (Map<String, int> part in enemy.parts) {
        if ((part['row'] == this._coordinate['row']) &&
            (part['col'] == this._coordinate['col'])) {
          print('Hit the enemy! Reducing enemy HP by 1');
          enemy.reduceHitpointsBy(1);
          _model.removeProjectile(this);
          print('Projectile deleted.');
        }
      }
    }
    PlayerShip player = this._model._player;
    for (Map<String, int> coor in player._parts) {
      if ((coor['row'] == this._coordinate['row']) &&
          (coor['col'] == this._coordinate['col'])) {
        print('Player got hit! Reducing player HP by 1');
        player.reduceHitpointsBy(1);
        _model.removeProjectile(this);
      }
    }
    List<Projectile> projectiles = this._model.projectiles.toList();
    for (Projectile prj in projectiles) {
      if (this != prj) {
        if ((prj.coordinate['row'] == this._coordinate['row']) &&
            (prj.coordinate['col'] == this._coordinate['col'])) {
          this._model.removeProjectile(prj);
          this._model.removeProjectile(this);
        }
      }
    }
  }
}
