part of SpaceInvader;

/**
 * Klasse Level
 * Hat eine Anzahl an SpawnPoints
 * Und momentan ein ShipType, der auf jeden dieser SpawnPoints spawnd
 */
class Level {
  
  List<SpawnPoint> _spawns = [];

  Level(this._spawns);
  
  List<SpawnPoint> get spawns => _spawns;
  
}