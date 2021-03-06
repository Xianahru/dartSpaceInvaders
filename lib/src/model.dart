part of SpaceInvader;

class SpaceInvaderModel {
  Map<int, Level> _levels = new Map<int, Level>();
  Map<int, ShipType> _enemyTypes = new Map<int, ShipType>();
  List<EnemyShip> _enemies = [];
  List<Projectile> _projectiles = [];
  List<Projectile> _playerProjectiles = [];
  PlayerShip _player;
  SpawnPoint _playerSpawn = new SpawnPoint.player({'row': 28, 'col': 15});
  int _score = 0;

  SpawnPointInterpreter interp = new SpawnPointInterpreter();
  
  String document;
  var _doc;
  var lvls;
  var ships;
  
  int _currentLevel = 1;
  bool _gameWon = false;
  bool _gameOver = false;
  bool _running = false;
  
  List<Projectile> get projectiles => this._projectiles;
  List<Projectile> get playerProjectiles => this._playerProjectiles;
  List<EnemyShip> get enemies => this._enemies;
  
  bool isRunning() { return this._running; }

  bool gameOver(){ return this._gameOver; }
  
  bool stageClear(){ return this._enemies.length == 0; }
  
  bool gameWon() { return this._gameWon; }
  
  setRunning(bool run) { this._running = run; }
  
  getLeftShips() { return _enemies.length; }
  
  getPlayerHitpoints() { return _player._hitpoints; }
 
  getLevel() { return this._currentLevel; }
  
  setLevel(int lvl) {
    if(lvl > _levels.length) {
      this._running = false;
      this._gameWon = true;
    } else this._currentLevel = lvl;  
  }

  setGameOver(){
    this._gameOver = true;
    this._running = false;
    print('You\'ve reached level ${this._currentLevel} with a score of ${this._score}');
  }
  
  /**
   * Erhöhrt die Punktzahl um den angegebenen Betrag
   */
  addScore(int i){ this._score += i; }
  
  getScore() { return this._score; }
  
  /**
   * Entfernt das angegebene [Projectile] aus der Liste der [Projectile] [_projectiles]
   */
  removeProjectile(Projectile proj){
    if(this._playerProjectiles.contains(proj)) this._playerProjectiles.remove(proj);
    this._projectiles.remove(proj);
  }
  
  /**
   * Entfernt das angegebene [EnemyShip] aus der Liste der [EnemyShip] [_enemies]
   */
  removeEnemy(EnemyShip enemy){
    this._enemies.remove(enemy);
  }
  

  /**
   * ACTHUNG
   * ASYNC --> Wenn Setup ausgeführt wird, muss jeder weitere Methodenaufruf darauf warten um zu verhindern,
   * dass es NULLPOINTER gibt!
   */
  setup() async {
    String document = await html.HttpRequest.getString('src/xml/spaceInvader.xml');
    _doc = parse(document);
    lvls = _doc.findAllElements('level');
    ships = _doc.findAllElements('ship');
    loadShiptypesFromFile();
    loadLeveldataFromFile();
  }

  /**
   * Lade alle Schiffstypen und speicher sie in [_enemyTypes]
   * Koordinaten müssen beim Spawnen auf verschiedenen Levels noch interpretiert werden!
   * (Übernimmt [loadLevel] beim Bereitstellen des Levels)
   */
  loadShiptypesFromFile() {
    for (var ship in ships) {
      var coordinates = ship.findElements('coordinate');
      List<Map<String, int>> dummy = [];
      for (var cor in coordinates) {
        dummy.add({
          'row': int.parse(cor.attributes[0].value),
          'col': int.parse(cor.attributes[1].value),
          'cannon': int.parse(cor.attributes[2].value)
        });
      }
      _enemyTypes[int.parse(ship.attributes[0].value)] = new ShipType(dummy, int.parse(ship.attributes[1].value));
    }
  }

  /**
   * Lade alle Levels aus der XML und speicher sie in [_levels]
   */
  loadLeveldataFromFile() {
    for (var lvl in lvls) {
      int stage = int.parse(lvl.attributes[0].value);
      var spawnpoints = lvl.findAllElements('spawnpoint');
      List<SpawnPoint> spawns = [];
      for (var spawn in spawnpoints) {
        var coor = spawn.attributes;
        spawns.add(new SpawnPoint.enemy({
          'row': int.parse(coor[0].value),
          'col': int.parse(coor[1].value),
        }, _enemyTypes[int.parse(coor[2].value)]));
      }
      _levels[stage] = new Level(spawns);
    }
  }
  
  /**
   * Läd das gewünschte [Level]
   * Stellt vorher sicher, dass kein [EnemyShip] mehr in [_enemies] existiert
   * Ändert dann das [Level] im Model
   * Für jeden [SpawnPoint] im [Level] wird ein [EnemyShip] relativ zum [SpawnPoint] erstellt
   */
  loadLevel(int stage){
    
    _enemies.clear();
    _player = null;
    _projectiles.clear();
    _playerProjectiles.clear();
    setLevel(stage);
        
    Level level = _levels[stage];
    for(SpawnPoint spawn in level.spawns){
      _enemies.add(new EnemyShip(this, interp.interpret(spawn.type.parts, spawn), spawn.type.hitpoints));
    }
    
    List<Map<String, int>> dummy = [
        {'row': -1, 'col': 0, 'cannon': 1},
        {'row': 0, 'col': 0, 'cannon': 0},
        {'row': 0, 'col': 1, 'cannon': 0},
        {'row': 0, 'col': -1,'cannon': 0},
        {'row': 1, 'col': 1, 'cannon': 0},
        {'row': 1, 'col': -1, 'cannon': 0},
        {'row': 1, 'col': 2, 'cannon': 0},
        {'row': 1, 'col': -2, 'cannon': 0}
      ];
    _player = new PlayerShip(this, interp.interpret(dummy, _playerSpawn), 5);
    
  }
  
  /**
   * Spawnt ein [Projectile]
   * Unterscheidet dabei ein vom Spieler generiertes [Projectile] und das eines [EnemyShip]
   * Der Spieler kann maximal 5 [Projectiles] auf dem Feld haben
   */
  spawnProjectile(Map<String, int> coor, bool player){
    Projectile dummy = new Projectile(coor, this);
    if(_running && player && this._playerProjectiles.length < 5) {
      _projectiles.add(dummy);
      _playerProjectiles.add(dummy);
    }
    else if (_running && !player) _projectiles.add(dummy);
  }
  
  /**
   * [_player] schießt alle seinen Kanonen
   */
  playerShoot(){
    if(_running) _player.shoot();
  }
  
  enemyShoot() {
    if(_running) _enemies.toList().forEach((p) => p.shoot());
  }
  
  /**
   * Bewegt [_player] in die angegebene Richtung
   * Richtung ist entweder ['left'] oder ['right']
   * Ggf kann auch noch ['up'] und ['down'] implementiert werden
   */
  movePlayer(String direction){
    if(_running) _player.move(direction);
  }
  
  /**
   * Gibt einen Bewegungsbefehl an alle [EnemyShip] in [_enemies]
   * Für eine genauere Beschreibung siehe [EnemyShip.move]
   */
  moveEnemies(){
    if(_running) _enemies.toList().forEach((enemy) => enemy.move());
  }
  
  /**
   * Gibt einen Bewgungsbefehl an alle [Projectile] in [_projectiles]
   * Für eine genauere Beschreibung siehe [Projectile.move]
   */
  moveProjectiles(){
    _projectiles.toList().forEach((p) => p.move());
  }
  
  
  /**
   * Gibt den momentan Spielstand zurück
   * Trägt alle Teile der [_enemies] in eine Liste ein
   * Trägt dann alle Teile des [_player] in selbige Liste ein
   * Schlussendlich sollen noch alle Projektile aus [_projectiles] eingetragen werden
   */
  List<List<String>> getCurrentState(){
    List<List<String>> field = new Iterable.generate(gamesize, (row) {
        return new Iterable.generate(gamesize, (col) => 'empty').toList();
    }).toList();
    
    for(EnemyShip enemy in _enemies){
      int health = ((enemy.hitpoints / enemy.baseHitpoints) * 100).round();
      for(Map<String, int> coor in enemy.parts){
        if(coor['cannon']==0) field[coor['row']][coor['col']] = 'part_$health';
        else field[coor['row']][coor['col']] = 'cannonEnemy_$health';
      }
    }
    
    for(Map<String, int> coor in _player.parts){
      if(coor['cannon']==0) field[coor['row']][coor['col']] = 'player';
      else field[coor['row']][coor['col']] = 'cannonPlayer';
    }
    
    for(Projectile proj in _projectiles){
      field[proj.coordinate['row']][proj.coordinate['col']] = 'enemyProjectile';
    }
    
    for(Projectile proj in _playerProjectiles){
      field[proj.coordinate['row']][proj.coordinate['col']] = 'playerProjectile';
    }
    
    return field;
  }
}