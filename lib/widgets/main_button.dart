import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const MainButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
    BoxShadow(
    color: color.withValues(alpha: 0.2),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onPressed,
    child: Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
    children: [
    CircleAvatar(
    backgroundColor: color.withValues(alpha: 0.1),
    child: Icon(icon, color: color),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
    ],
    ),
    ),
    Icon(Icons.chevron_right, color: Colors.grey.shade400),
    ],
    ),
    ),
    ),
    ),
    );

  }
}
