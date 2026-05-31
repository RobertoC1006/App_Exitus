import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app_exitus/features/auth/domain/entities/user.dart';

class StudentDojoStoreScreen extends StatefulWidget {
  final User studentUser;
  final int currentPoints;

  const StudentDojoStoreScreen({
    super.key,
    required this.studentUser,
    required this.currentPoints,
  });

  @override
  State<StudentDojoStoreScreen> createState() => _StudentDojoStoreScreenState();
}

class _StudentDojoStoreScreenState extends State<StudentDojoStoreScreen> {
  late int _points;
  String _selectedCategory = 'Dragones';
  String _sortBy = 'Más recientes';
  final List<String> _ownedItems = [];

  @override
  void initState() {
    super.initState();
    _points = widget.currentPoints;
  }

  // Handle purchasing an item
  void _confirmPurchase(String itemName, int price) {
    if (_points < price) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Puntos Insuficientes",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
          ),
          content: Text(
            "Necesitas $price puntos para desbloquear '$itemName'. ¡Sigue esforzándote en tus clases para ganar más puntos!",
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Entendido",
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
              ),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "¿Desbloquear item?",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            children: [
              const TextSpan(text: "¿Estás seguro de que quieres adquirir "),
              TextSpan(
                text: itemName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D2848)),
              ),
              const TextSpan(text: " por "),
              TextSpan(
                text: "$price",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEF6C00)),
              ),
              const TextSpan(text: " puntos?"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _points -= price;
                _ownedItems.add(itemName);
              });
              _showSuccessDialog(itemName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D2848),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Confirmar",
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Color(0xFF2E7D32), size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              "¡Desbloqueo Exitoso!",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D2848)),
            ),
            const SizedBox(height: 8),
            Text(
              "Has adquirido '$itemName'. Ahora puedes seleccionarlo en la personalización de tu perfil de Dojo.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D2848),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                "Estupendo",
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. COMPACT FIXED HEADER
            _buildCompactHeader(),

            // 2. CATEGORY SELECTOR BAR
            _buildCategorySelector(),

            // 3. STORE MAIN BODY
            Expanded(
              child: _buildStoreBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      height: 195, // Increased height to prevent rendering breaks and accommodate text
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background soft curves drawing
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: CustomPaint(
                painter: StoreHeaderPatternPainter(),
              ),
            ),
          ),
          // Left side Column contents
          Padding(
            padding: const EdgeInsets.only(left: 18, top: 30, right: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically to avoid Spacer overflow
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 14,
                      color: Color(0xFF1D2848),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tienda Dojo",
                  style: GoogleFonts.outfit(
                    fontSize: 28, // Increased size to fill space and look bold
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1D2848),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Usa tus puntos para desbloquear dragones, auras y más elementos.",
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                // Points balance capsule
                _buildPointsCapsule(),
              ],
            ),
          ),
          // Mascot positioned on the right, larger and shifted to the left
          Positioned(
            right: 25, // Shuffled left to overlay/align better
            bottom: 0,
            child: Image.asset(
              'assets/images/mascot_tienda.png',
              height: 140, // Increased size from 120 to 140
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                child: const Icon(Icons.face, size: 40, color: Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCapsule() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              color: Color(0xFFFFB300),
              size: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "$_points",
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2848),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "puntos",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _buildCategoryTab('Dragones', Icons.pets, const Color(0xFFFFB300))),
          const SizedBox(width: 8),
          Expanded(child: _buildCategoryTab('Auras', Icons.auto_awesome, const Color(0xFF9C27B0))),
          const SizedBox(width: 8),
          Expanded(child: _buildCategoryTab('Multiplicadores', Icons.bolt, const Color(0xFFFFEB3B))),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category, IconData icon, Color iconColor) {
    final bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFE2E8F0) : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? iconColor : const Color(0xFF94A3B8),
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              category,
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1D2848) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreBody() {
    if (_selectedCategory == 'Dragones') {
      return _buildDragonsSection();
    } else if (_selectedCategory == 'Auras') {
      return _buildAurasSection();
    } else {
      return _buildMultipliersSection();
    }
  }

  Widget _buildDragonsSection() {
    // 6 vertical dragons in a unified grid, now Celestial and Verde are also here
    final List<Map<String, dynamic>> verticalDragons = [
      {'name': 'Zorro Exitino', 'points': 20, 'isNew': true},
      {'name': 'Furia Nocturna', 'points': 200, 'isNew': false},
      {'name': 'Furia Fénix', 'points': 500, 'isNew': false},
      {'name': 'Dragón Solar', 'points': 750, 'isNew': false},
      {'name': 'Dragón Celestial', 'points': 1000, 'isNew': false},
      {'name': 'Dragón Verde', 'points': 300, 'isNew': false},
    ];

    // Apply simple mock sorting
    if (_sortBy == 'Menor precio') {
      verticalDragons.sort((a, b) => (a['points'] as int).compareTo(b['points'] as int));
    } else if (_sortBy == 'Mayor precio') {
      verticalDragons.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Grid Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets, color: Color(0xFFFFB300), size: 14),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dragones Especiales",
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    const Text(
                      "Desbloquea nuevos dragones para tu aventura.",
                      style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
            // Sorting Dropdown
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF1D2848)),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2848),
              ),
              items: <String>['Más recientes', 'Menor precio', 'Mayor precio']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _sortBy = newValue;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid of all 6 dragons (same card sizes)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: verticalDragons.length,
          itemBuilder: (context, index) {
            final dragon = verticalDragons[index];
            return _buildVerticalDragonCard(
              name: dragon['name'],
              points: dragon['points'],
              isNew: dragon['isNew'],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildVerticalDragonCard({
    required String name,
    required int points,
    required bool isNew,
  }) {
    final bool isOwned = _ownedItems.contains(name);
    final bool canAfford = _points >= points;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // "Nuevo" Badge
          if (isNew)
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Nuevo",
                  style: GoogleFonts.outfit(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Main card layout column
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Dragon Egg Image
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/Huevo_dragon.png',
                    height: 95,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      child: const Icon(Icons.egg, size: 40, color: Colors.orange),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D2848),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Points row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: Color(0xFFFBC02D), size: 13),
                  const SizedBox(width: 3),
                  Text(
                    "$points puntos",
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF6C00),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Buy button
              GestureDetector(
                onTap: isOwned ? null : () => _confirmPurchase(name, points),
                child: Container(
                  height: 32,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isOwned 
                        ? const Color(0xFFE2E8F0) 
                        : (canAfford ? const Color(0xFF3B82F6) : const Color(0xFF93C5FD)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOwned ? Icons.check : Icons.shopping_cart,
                        color: isOwned ? const Color(0xFF64748B) : Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOwned ? "Adquirido" : "Adquirir",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOwned ? const Color(0xFF64748B) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAurasSection() {
    final List<Map<String, dynamic>> auras = [
      {
        'name': 'Aura Ígnea',
        'points': 350,
        'description': 'Destellos de fuego alrededor de tu dragón',
        'icon': Icons.local_fire_department,
        'color': const Color(0xFFEF5350),
        'bgColor': const Color(0xFFFFEBEE),
      },
      {
        'name': 'Aura Glacial',
        'points': 400,
        'description': 'Niebla y copos de nieve flotando en tu perfil',
        'icon': Icons.ac_unit,
        'color': const Color(0xFF26C6DA),
        'bgColor': const Color(0xFFE0F7FA),
      },
      {
        'name': 'Aura Eléctrica',
        'points': 600,
        'description': 'Relámpagos dinámicos de alto voltaje en tu avatar',
        'icon': Icons.flash_on,
        'color': const Color(0xFFAB47BC),
        'bgColor': const Color(0xFFF3E5F5),
      },
      {
        'name': 'Aura Cósmica',
        'points': 1200,
        'description': 'Polvo estelar y galaxias en miniatura giratorias',
        'icon': Icons.blur_on,
        'color': const Color(0xFF5C6BC0),
        'bgColor': const Color(0xFFE8EAF6),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: auras.length,
      itemBuilder: (context, index) {
        final aura = auras[index];
        final bool isOwned = _ownedItems.contains(aura['name']);
        final bool canAfford = _points >= aura['points'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: aura['bgColor'],
                  shape: BoxShape.circle,
                ),
                child: Icon(aura['icon'], color: aura['color'], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aura['name'],
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aura['description'],
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Color(0xFFFBC02D), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          "${aura['points']} puntos",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF6C00),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isOwned ? null : () => _confirmPurchase(aura['name'], aura['points']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwned 
                      ? const Color(0xFFE2E8F0) 
                      : (canAfford ? const Color(0xFF1D2848) : const Color(0xFF94A3B8)),
                  foregroundColor: isOwned ? const Color(0xFF64748B) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  isOwned ? "Adquirido" : "Adquirir",
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultipliersSection() {
    final List<Map<String, dynamic>> multipliers = [
      {
        'name': 'x1.5 Tareas',
        'points': 800,
        'description': 'Aumenta en 50% todos los puntos de tus tareas durante 7 días',
        'icon': Icons.trending_up,
        'color': const Color(0xFF66BB6A),
        'bgColor': const Color(0xFFE8F5E9),
      },
      {
        'name': 'x2.0 Asistencia',
        'points': 1000,
        'description': 'Duplica los puntos que obtienes por asistencia perfecta esta semana',
        'icon': Icons.bolt,
        'color': const Color(0xFFFFCA28),
        'bgColor': const Color(0xFFFFF8E1),
      },
      {
        'name': 'x2.0 Participación',
        'points': 1500,
        'description': 'Duplica todos los puntos obtenidos por participar activamente en clase',
        'icon': Icons.people,
        'color': const Color(0xFF29B6F6),
        'bgColor': const Color(0xFFE1F5FE),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: multipliers.length,
      itemBuilder: (context, index) {
        final mult = multipliers[index];
        final bool isOwned = _ownedItems.contains(mult['name']);
        final bool canAfford = _points >= mult['points'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: mult['bgColor'],
                  shape: BoxShape.circle,
                ),
                child: Icon(mult['icon'], color: mult['color'], size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mult['name'],
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1D2848),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mult['description'],
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Color(0xFFFBC02D), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          "${mult['points']} puntos",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF6C00),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isOwned ? null : () => _confirmPurchase(mult['name'], mult['points']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwned 
                      ? const Color(0xFFE2E8F0) 
                      : (canAfford ? const Color(0xFF1D2848) : const Color(0xFF94A3B8)),
                  foregroundColor: isOwned ? const Color(0xFF64748B) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  isOwned ? "Activo" : "Activar",
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Draw elegant header soft shapes
class StoreHeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D2848)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.8), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 60, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
