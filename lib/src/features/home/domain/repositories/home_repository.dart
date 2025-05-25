abstract class HomeRepository {
  Future<Map<String, dynamic>> getFeedingSummary(String babyId);
  Future<Map<String, dynamic>> getSleepSummary(String babyId);
  Future<Map<String, dynamic>> getDiaperSummary(String babyId);
  Future<Map<String, dynamic>> getTemperatureSummary(String babyId);
  Future<Map<String, dynamic>> getGrowthSummary(String babyId);
}