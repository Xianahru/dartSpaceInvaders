part of SpaceInvader;

/**
 * Klasse ShipType
 * Besteht aus einer Liste von Koordinatenpaaren relativ zum jeweiligen Schiffsmittelpunkt [0/0]
 * Wird genutzt um [EnemyShip] auf einem [SpawnPoint] zu spawnen
 */
class ShipType{
  
  List<Map<String, int>> _parts = [];
  int _hitpoints;
  
  ShipType(this._parts, this._hitpoints);

  List<Map<String, int>> get parts => _parts;
  int get hitpoints => this._hitpoints;
  
}

/**
 * Abstrakte Klasse Ship
 * Besitzt eine Referenz auf das verwaltende Model
 * Besteht aus einer Liste von Koordinatenpaaren (bereits interpretiert)
 * Der Teil von [Ship] ganz links und ganz rechts wird in [_leftMost] und [_rightMost] gespeichert
 * um zu garantieren, dass das Spielfeld nicht verlassen wird
 * Besitzt eine Anzahl von Trefferpunkten
 * Wenn [_hitpoints] == 0 soll dieses Schiff entfernt werden [MUSS NOCH EINGEBAUT WERDEN]
 * Über [_rng] wird die nächste Bewegung festgelegt 
 */
abstract class Ship {
  
  Random _rng = new Random();
  
  SpaceInvaderModel _model;
  
  List<Map<String, int>> _parts = [];
  List<Map<String, int>> _cannons = [];
  
  Map<String, int> _leftMost;
  Map<String, int> _rightMost;
  
  int _hitpoints;
  
  /**
   * Konstruktor
   */
  Ship(SpaceInvaderModel model, List<Map<String, int>> parts, int hitpoints){
    this._model = model;
    this._parts = parts;
    this._hitpoints = hitpoints;
    setup();
    print('Spawned ship on $this');
  }

  List<Map<String, int>> get parts => _parts;

  int get hitpoints => this._hitpoints;
  
  reduceHitpointsBy(int damage){
    this._hitpoints -= damage;
    if(this._hitpoints <= 0) {
      this._model.removeEnemy(this);
      this._model.addScore(this._hitpoints);
      print('Ship is destroyed!');
    }
  }
  
  /**
   * Überprüft dieses [Ship] drauf, ob es sich auf dem gleichen Feld wie ein [Projectile] befindet.
   * Wenn ja, werden die [_hitpoints] von diesem [Ship] um 1 reduziert und das [Projectile] entfernt.
   */
  void detectCollision(){
    List<Projectile> projectiles = this._model.projectiles.toList();
    for(Map<String, int> part in this._parts){
      for(Projectile prj in projectiles){
        if((part['row'] == prj._coordinate['row']) && (part['col'] == prj._coordinate['col'])){
          print('Hit by enemy! Reducing HP by 1');
          this.reduceHitpointsBy(1);
          this._model.removeProjectile(prj);
        }
      }
    }
  }
  
  /**
   * Nachdem die Koordinaten des Schiffes eingetragen sind, werden [_leftMost] und [_rightMost]
   * ausgerechnet. In Klassen, die von [Ship] erben, werden möglicherweise noch [_bottomMost] und 
   * [_topMost] ausgerechnet. Ggf kann auch [_cannons] ausgerechnet werden
   */
  setup();
  
  /**
   * Stringrepräsentation eines Schiffes
   */
  String toString(){
    return _parts.toString();
  }
}

/**
 * Klasse EnemyShip
 * Erbt von [Ship]
 * Besitzt neben [_leftMost] und [_rightMost] auch noch [_bottomMost] um festzustellen, ob das Spiel verloren wurde
 */
class EnemyShip extends Ship {
  
  Map<String, int> _bottomMost;
  
  EnemyShip(SpaceInvaderModel model, List<Map<String, int>> parts, int hitpoints) : super(model, parts, hitpoints);
  
  void move(){ 
    switch(determineDirection()){
      case 'down':
        if(this._bottomMost['row'] == gamesize-1) { _model.setGameOver(); break; }
        else {
          for(Map coor in _parts){
            coor['row'] += 1;
            if(coor['row'] > this._bottomMost['row']) this._bottomMost = coor; 
          }
        }
        print("moved down");
        break;
      case 'left':
        if(this._leftMost['col'] == 0) break;
        else {
          for(Map coor in _parts){
            coor['col'] -= 1;
            if(coor['col'] < _leftMost['col']) this._leftMost = coor; 
          }
        print("moved left");
        }
        break;
      case 'right':
        if(this._rightMost['col'] == gamesize-1) break;
        else { 
          for(Map coor in _parts){
            coor['col'] += 1;
            if(coor['col'] > this._rightMost['col']) this._rightMost = coor; 
          }
        print("moved right");
        }
        break;
    }
    
    this.detectCollision();

  }
  
  determineDirection(){
    int dir = _rng.nextInt(12);
    
    if(dir<=5)                 return 'down';
    else if(dir>=6 && dir<=8)  return 'left';
    else if(dir>=9 && dir<=11) return 'right';
  }
  
  setup(){
    this._leftMost = _parts[0];
    this._rightMost = _parts[0];
    this._bottomMost = _parts[0];
    
    for(Map coor in _parts){
      if(coor['row'] > this._bottomMost['row']) this._bottomMost = coor; 
      if(coor['col'] < this._leftMost['col']) this._leftMost = coor; 
      if(coor['col'] > this._rightMost['col']) this._rightMost = coor;
      if(coor['cannon'] == 1) this._cannons.add(coor);
    }
  }
  
}

/**
 * Klasse PlayerShip
 * Erbt von [Ship]
 * Bewegt sich nur bei Nutzereingabe
 */
class PlayerShip extends Ship {
    
  PlayerShip(SpaceInvaderModel model, List<Map<String, int>> parts, int hitpoints) : super(model, parts, hitpoints);
  
  void move(String direction){
    switch(direction){
      case 'left':
        if(this._leftMost['col'] == 0) { print('Cant move left anymore'); break; }
        else {
          for(Map coor in parts){
            coor['col'] -= 1;
            if(coor['col'] < this._leftMost['col']) this._leftMost = coor;
          }
        print('moved player left');
        }
        break;
      case 'right':
        if(this._rightMost['col'] == gamesize-1) { print('Cant move right anymore'); break; }
        else {
          for(Map coor in parts){
            coor['col'] += 1;
            if(coor['col'] > this._rightMost['col']) this._rightMost = coor; 
          }
        print('moved player right');
        }
        break;
    }
  }
  
  /**
   * Jede Kanone in [_cannons] schießt eine Kugel mit Richtung -1 ab
   * (Das [Projectile] fliegt nach oben)
   */
  shoot(){
    for(Map<String, int> coor in _cannons){
      this._model.spawnProjectile({'row': (coor['row']-1), 'col': coor['col'], 'dir': -1});
    }
  }
  
  setup(){
    
    this._leftMost = _parts[0];
    this._rightMost = _parts[0];
    
    for(Map coor in _parts){
      if(coor['col'] < _leftMost['col']) this._leftMost = coor; 
      if(coor['col'] > _rightMost['col']) this._rightMost = coor;
      if(coor['cannon'] == 1) this._cannons.add(coor);
    }
  }
}