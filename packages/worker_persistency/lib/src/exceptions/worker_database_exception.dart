
/**
 * Worker Database Exception class
 * 
 * Luca Raffo @ 24/02/2025
 */
class DatabaseException implements Exception {
  
  String motivation;

  DatabaseException(this.motivation);

  @override
  String toString() {
    return motivation;
  }
}