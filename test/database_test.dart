import 'package:flutter_test/flutter_test.dart';
import 'package:mysql1/mysql1.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

class MockMySqlConnection extends Mock implements MySqlConnection {}

class MockResults extends Mock implements Results {}

@GenerateMocks([MySqlConnection, Results])
void main() {
  test('Save location to database', () async {
    final connection = MockMySqlConnection();
    final results = MockResults();

    when(connection.query('INSERT INTO Locations (LocationName) VALUES (?)', ['Dalat']))
        .thenAnswer((_) async => results);

    await saveToDatabase('London', connection);

    verify(connection.query('INSERT INTO Locations (LocationName) VALUES (?)', ['Dalat'])).called(1);

    await connection.close();
  });
}

Future<void> saveToDatabase(String location, MySqlConnection connection) async {
  try {
    await connection.query(
        'INSERT INTO Locations (LocationName) VALUES (?)',
        [location]);
  } catch (e) {
    print('Error: Unable to save to the database. $e');
  }
}
