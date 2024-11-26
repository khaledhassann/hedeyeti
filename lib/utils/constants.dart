// constant examples that will later be replaced by real data from DB
import '../models/Event.dart';
import '../models/Gift.dart';
import '../models/User.dart';

List<Gift> EXAMPLE_GIFTS = [
  Gift(
      name: "Smartphone",
      category: 'Electronics',
      price: 799.99,
      status: 'Available'),
  Gift(
      name: 'Blender',
      category: 'Home Appliances',
      price: 149.99,
      status: 'Available'),
  Gift(
      name: 'Laptop',
      category: 'Electronics',
      price: 1499.75,
      status: 'Pledged'),
  Gift(
      name: 'Flutter for Beginners',
      category: 'Books',
      price: 24.99,
      status: 'Available'),
];

// Initialize events
List<Event> EXAMPLE_EVENTS = [
  Event(
      name: 'Birthday party',
      date: DateTime(2024, 12, 15),
      category: 'Birthday',
      gifts: EXAMPLE_GIFTS),
  Event(
      name: 'Wedding',
      date: DateTime(2025, 9, 30),
      category: 'Wedding',
      gifts: EXAMPLE_GIFTS),
  Event(
      name: 'Graduation party',
      date: DateTime(2025, 7, 1),
      category: 'Graduation',
      gifts: EXAMPLE_GIFTS),
];

// Initialize users
List<User> EXAMPLE_USERS = [
  User(
      name: 'Khaled Taha',
      email: 'khaled@email.com',
      profilePicture: 'assets/images.png',
      isMe: true,
      events: EXAMPLE_EVENTS),
  User(
      name: 'John Doe',
      email: 'john.doe@email.com',
      profilePicture: 'assets/man02.png',
      isMe: false,
      events: EXAMPLE_EVENTS),
  User(
      name: 'Jane Smith',
      email: 'jane.smith@email.com',
      profilePicture: 'assets/girl01.png',
      isMe: false,
      events: []),
  User(
      name: 'Pablo Escobar',
      email: 'pablo.escobar@email.com',
      profilePicture: 'assets/man01.png',
      isMe: false,
      events: EXAMPLE_EVENTS),
];

List<Gift> EXAMPLE_PLEDGED_GIFTS = [
  Gift(
      name: 'Smartphone',
      category: 'Electronics',
      price: 799.99,
      status: 'Pending',
      description: "Latest model smartphone"),
  Gift(
      name: 'Headphones',
      category: 'Electronics',
      price: 199.99,
      status: 'Completed',
      description: "Noise-cancelling headphones"),
];
