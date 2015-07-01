part of SpaceInvader;

/**
 * Klasse SpawnPoint
 * Ein SpawnPoint ist ein Koordinatenpaar
 */
class SpawnPoint {
  Map<String, int> _coordinate;
  ShipType _type;
  
  SpawnPoint.enemy(this._coordinate, this._type);
  SpawnPoint.player(this._coordinate);
  
  Map<String, int> get coordinate => _coordinate;
  ShipType get type => _type;
}

/**
 * Klasse SpawnPointInterpreter
 * Wird genutzt um ein [ShipType] auf einem [SpawnPoint] abzubilden
 */
class SpawnPointInterpreter {
  
  /**
   * Interpretiert die Koordinaten des Schiffes [coordinates] relativ zum angegebenen Spawnpunkt [point]
   */
  List<Map<String, int>> interpret(List<Map<String, int>> coordinates, SpawnPoint point){
    List<Map<String, int>> relativeCoordinates = [];
    Map<String, int> sCoor = point.coordinate;
    
    for(Map coor in coordinates){
      relativeCoordinates.add({ 'row' : sCoor['row'] + coor['row'], 'col' : sCoor['col'] + coor['col'], 'cannon' : coor['cannon'] });
    }
    return relativeCoordinates;
  }
}