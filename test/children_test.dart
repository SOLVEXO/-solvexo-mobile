import 'package:book_store_app/app/data/repositories/children_repository.dart';
import 'package:book_store_app/app/modules/children/controllers/children_controller.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:flutter_test/flutter_test.dart';

// Live POST /api/children (test buyer, 2026-11-20; deleted right after):
// {"name":"TEST child","educationLevel":"primary_school","gradeLabel":"class-3",
//  "age":8,"gender":null,"subjects":["Maths"],"_id":..}
void main() {
  test('child row and request body (server derives educationLevel)', () {
    final c = Child.fromJson({'_id': '6affedbed1f43443b864e9c6', 'name': 'TEST child', 'educationLevel': 'primary_school', 'gradeLabel': 'class-3', 'age': 8, 'subjects': ['Maths']});
    expect(c.gradeLabel, 'class-3');
    expect(c.toBody(), {'name': 'TEST child', 'gradeLabel': 'class-3', 'age': 8, 'subjects': ['Maths']});
  });

  test('same rules as children.service.ts', () {
    expect(ChildrenController.validate(name: '', gradeLabel: 'class-3', age: '', subjects: []), contains('name'));
    expect(ChildrenController.validate(name: 'A', gradeLabel: null, age: '', subjects: []), contains('class'));
    expect(ChildrenController.validate(name: 'A', gradeLabel: 'kg', age: '1', subjects: []), contains('age'));
    expect(ChildrenController.validate(name: 'A', gradeLabel: 'kg', age: '', subjects: List.filled(11, 'x')), contains('subjects'));
    expect(ChildrenController.validate(name: 'Ali', gradeLabel: 'class-3', age: '8', subjects: ['Maths']), isEmpty);
  });

  test('For-your-child rail asks products by class', () {
    expect(ApiConstants.getProductsByCategory(classLevel: 'class-1', limit: 10), contains('class=class-1'));
  });
}
