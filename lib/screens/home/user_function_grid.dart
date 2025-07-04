import 'package:flutter/material.dart';

class UserFunctionGrid extends StatelessWidget {
  final String userId;
  final String username;
  
  const UserFunctionGrid({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      padding: const EdgeInsets.all(12),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        // Nghỉ phép
        _buildIconTile(
          context,
          Icons.edit_note,
          'Nghỉ phép',
          Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Placeholder(), // LeaveRequestScreen()
              ),
            );
          },
        ),
        
        // Nhiệm vụ
        _buildIconTile(
          context,
          Icons.assignment_turned_in,
          'Nhiệm vụ',
          Colors.green,
          onTap: () async {
            // Chuyển tới trang nhiệm vụ
          },
        ),
        
        // Bổ sung công
        _buildIconTile(
          context,
          Icons.add_circle,
          'Bổ sung công',
          Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Placeholder(), // AddWorkHoursScreen()
              ),
            );
          },
        ),
        
        // Hòm thư góp ý
        _buildIconTile(
          context,
          Icons.forum,
          'Hộp thư góp ý',
          Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Placeholder(), // SuggestionBoxScreen()
              ),
            );
          },
        ),

        // Phiếu tạm ứng
        _buildIconTile(
          context,
          Icons.attach_money,
          'Phiếu Tạm Ứng',
          Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Placeholder(), // AdvanceRequestScreen()
              ),
            );
          },
        ),
        
        // Lịch sử chấm công
        _buildIconTile(
          context,
          Icons.access_time,
          'Lịch Sử Chấm Công',
          Colors.lightBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Placeholder(), // LichSuChamCongScreen(userId: userId)
              ),
            );
          },
        ),

        // Công tác
        _buildIconTile(
          context,
          Icons.flight_takeoff,
          'Công tác',
          Colors.deepOrange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Placeholder()), // CongTacScreen()
            );
          },
        ),
        
        // Chấm công hộ
        _buildIconTile(
          context,
          Icons.location_on,
          'Chấm công hộ',
          Colors.pink,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Placeholder()), // ChamCongHoScreen()
            );
          },
        ),
      ],
    );
  }

  Widget _buildIconTile(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
