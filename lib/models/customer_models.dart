import 'package:flutter/material.dart';

// --- Model ---
class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int bookings;
  final String joinedDate;
  final String location;
  final bool isActive;
  final String avatarColor; // storing color as string for demo

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bookings,
    required this.joinedDate,
    required this.location,
    required this.isActive,
    required this.avatarColor,
  });
}

// --- Mock Data ---
final List<Customer> mockCustomers = [
  Customer(id: '1', name: 'Aarav Kumar', email: 'aarav.k@gmail.com', phone: '+91 98765 43210', bookings: 12, joinedDate: '15 Jan, 2024', location: 'Gomti Nagar', isActive: true, avatarColor: '0xFFFFF3E0'),
  Customer(id: '2', name: 'Priya Singh', email: 'priya.singh88@gmail.com', phone: '+91 88901 23456', bookings: 5, joinedDate: '22 Feb, 2024', location: 'Hazratganj', isActive: true, avatarColor: '0xFFE3F2FD'),
  Customer(id: '3', name: 'Rohan Verma', email: 'rohan.v@chayankaro.com', phone: '+91 76543 21098', bookings: 0, joinedDate: '01 Mar, 2024', location: 'Aliganj', isActive: false, avatarColor: '0xFFE8F5E9'),
  Customer(id: '4', name: 'Ananya Gupta', email: 'ananya.g@gmail.com', phone: '+91 99887 76655', bookings: 8, joinedDate: '10 Mar, 2024', location: 'Indira Nagar', isActive: true, avatarColor: '0xFFF3E5F5'),
];

// --- Constants ---
const Color kPrimaryOrange = Color(0xFFFF6B00); // Matches the orange in screenshots
const Color kTextDark = Color(0xFF1E293B);
const Color kTextLight = Color(0xFF64748B);
const Color kBorderColor = Color(0xFFE2E8F0);
const Color kBgColor = Color(0xFFF1F5F9);