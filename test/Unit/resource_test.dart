import 'package:flutter_test/flutter_test.dart';
import 'package:beacon/model/data/resource.dart';

void main() {
  group('Resource Model Tests', () {
    test('Resource object is created correctly', () {
      final resource = Resource(
        id: 1,
        resourceType: 'Water',
        quantity: 5,
        note: 'Urgent',
        requesterId: 'device-123',
        owner: 'Ahmed',
        status: 'pending',
        isRequested: true,
        isMine: false,
        timestamp: '2024-01-01T10:00:00',
      );

      expect(resource.id, 1);
      expect(resource.resourceType, 'Water');
      expect(resource.quantity, 5);
      expect(resource.note, 'Urgent');
      expect(resource.requesterId, 'device-123');
      expect(resource.owner, 'Ahmed');
      expect(resource.status, 'pending');
      expect(resource.isRequested, true);
      expect(resource.isMine, false);
      expect(resource.timestamp, '2024-01-01T10:00:00');
    });

    test('Resource.toMap returns correct map structure', () {
      final resource = Resource(
        id: 2,
        resourceType: 'Food',
        quantity: 10,
        note: 'For family',
        requesterId: 'device-456',
        owner: 'Omar',
        status: 'approved',
        isRequested: false,
        isMine: true,
        timestamp: '2024-02-01T12:00:00',
      );

      final map = resource.toMap();

      expect(map['id'], 2);
      expect(map['resource_type'], 'Food');
      expect(map['quantity'], 10);
      expect(map['note'], 'For family');
      expect(map['requester_id'], 'device-456');
      expect(map['owner'], 'Omar');
      expect(map['status'], 'approved');
      expect(map['is_requested'], 0);
      expect(map['is_mine'], 1);
      expect(map['timestamp'], '2024-02-01T12:00:00');
    });

    test('Resource.fromMap creates Resource correctly', () {
      final map = {
        'id': 3,
        'resource_type': 'Medicine',
        'quantity': 2,
        'note': 'Critical',
        'requester_id': 'device-789',
        'owner': 'Yousef',
        'status': 'delivered',
        'is_requested': 1,
        'is_mine': 0,
        'timestamp': '2024-03-01T08:30:00',
      };

      final resource = Resource.fromMap(map);

      expect(resource.id, 3);
      expect(resource.resourceType, 'Medicine');
      expect(resource.quantity, 2);
      expect(resource.note, 'Critical');
      expect(resource.requesterId, 'device-789');
      expect(resource.owner, 'Yousef');
      expect(resource.status, 'delivered');
      expect(resource.isRequested, true);
      expect(resource.isMine, false);
      expect(resource.timestamp, '2024-03-01T08:30:00');
    });

    test('Resource.copyWith updates selected fields only', () {
      final original = Resource(
        id: 4,
        resourceType: 'Water',
        quantity: 3,
        note: 'Initial',
        requesterId: 'device-000',
        owner: 'Ali',
        status: 'pending',
        isRequested: true,
        isMine: true,
        timestamp: '2024-04-01T09:00:00',
      );

      final updated = original.copyWith(
        quantity: 7,
        note: 'Updated note',
        status: 'approved',
        isRequested: false,
      );

      expect(updated.id, original.id);
      expect(updated.resourceType, original.resourceType);
      expect(updated.requesterId, original.requesterId);
      expect(updated.owner, original.owner);
      expect(updated.isMine, original.isMine);

      expect(updated.quantity, 7);
      expect(updated.note, 'Updated note');
      expect(updated.status, 'approved');
      expect(updated.isRequested, false);


      expect(updated.timestamp, isNot(original.timestamp));
    });
  });
}
