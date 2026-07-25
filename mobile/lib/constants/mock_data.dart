import '../models/gobag_item.dart';

class MockData {
  // Default Go-Bag Items
  static List<GoBagItem> getDefaultGoBagItems() {
    return [
      // Documents (Priority 1 - Critical)
      GoBagItem(
        id: '1',
        category: 'documents',
        name: 'Valid IDs',
        description: 'Government-issued IDs, birth certificates',
        priority: 1,
        icon: '📄',
      ),
      GoBagItem(
        id: '2',
        category: 'documents',
        name: 'Emergency Contacts',
        description: 'List ng mga telepono ng pamilya at kaibigan',
        priority: 1,
        icon: '📞',
      ),
      GoBagItem(
        id: '3',
        category: 'documents',
        name: 'Medical Records',
        description: 'Prescription, medical history',
        priority: 1,
        icon: '🏥',
      ),
      
      // Food & Water (Priority 1 - Critical)
      GoBagItem(
        id: '4',
        category: 'food',
        name: 'Bottled Water',
        description: '3-day supply, 1 liter per day per person',
        priority: 1,
        icon: '💧',
      ),
      GoBagItem(
        id: '5',
        category: 'food',
        name: 'Non-perishable Food',
        description: 'Canned goods, biscuits, instant noodles',
        priority: 1,
        icon: '🥫',
      ),
      
      // Medical (Priority 1 - Critical)
      GoBagItem(
        id: '6',
        category: 'medical',
        name: 'First Aid Kit',
        description: 'Bandages, alcohol, betadine, cotton',
        priority: 1,
        icon: '⚕️',
      ),
      GoBagItem(
        id: '7',
        category: 'medical',
        name: 'Maintenance Medicine',
        description: 'Para sa may sakit (hypertension, diabetes, etc.)',
        priority: 1,
        icon: '💊',
      ),
      
      // Tools (Priority 2 - Important)
      GoBagItem(
        id: '8',
        category: 'tools',
        name: 'Flashlight',
        description: 'With extra batteries',
        priority: 2,
        icon: '🔦',
      ),
      GoBagItem(
        id: '9',
        category: 'tools',
        name: 'Transistor Radio',
        description: 'Para sa emergency broadcasts',
        priority: 2,
        icon: '📻',
      ),
      GoBagItem(
        id: '10',
        category: 'tools',
        name: 'Whistle',
        description: 'Para makakuha ng atensyon',
        priority: 2,
        icon: '🔔',
      ),
      GoBagItem(
        id: '11',
        category: 'tools',
        name: 'Swiss Knife / Multi-tool',
        description: 'For cutting and basic repairs',
        priority: 2,
        icon: '🔪',
      ),
      
      // Clothing (Priority 2 - Important)
      GoBagItem(
        id: '12',
        category: 'clothing',
        name: 'Extra Clothes',
        description: '2-3 sets of comfortable clothing',
        priority: 2,
        icon: '👕',
      ),
      GoBagItem(
        id: '13',
        category: 'clothing',
        name: 'Rain Gear',
        description: 'Raincoat or poncho',
        priority: 2,
        icon: '🧥',
      ),
      GoBagItem(
        id: '14',
        category: 'clothing',
        name: 'Blanket',
        description: 'For warmth and comfort',
        priority: 2,
        icon: '🛏️',
      ),
      
      // Communication (Priority 2 - Important)
      GoBagItem(
        id: '15',
        category: 'communication',
        name: 'Cellphone',
        description: 'Fully charged',
        priority: 1,
        icon: '📱',
      ),
      GoBagItem(
        id: '16',
        category: 'communication',
        name: 'Power Bank',
        description: 'Fully charged, high capacity',
        priority: 2,
        icon: '🔋',
      ),
      
      // Others (Priority 3 - Recommended)
      GoBagItem(
        id: '17',
        category: 'others',
        name: 'Cash',
        description: 'Small bills for emergencies',
        priority: 2,
        icon: '💵',
      ),
      GoBagItem(
        id: '18',
        category: 'others',
        name: 'Personal Hygiene Items',
        description: 'Toothbrush, soap, tissue, sanitary pads',
        priority: 3,
        icon: '🧼',
      ),
      GoBagItem(
        id: '19',
        category: 'others',
        name: 'Matches/Lighter',
        description: 'Waterproof if possible',
        priority: 3,
        icon: '🔥',
      ),
      GoBagItem(
        id: '20',
        category: 'others',
        name: 'Plastic Bags',
        description: 'Para sa basura o proteksyon ng gamit',
        priority: 3,
        icon: '🛍️',
      ),
    ];
  }

  // DRRM Learning Content
  static List<Map<String, dynamic>> getDRRMTrivia() {
    return [
      {
        'question': 'Ano ang unang dapat gawin kapag may lindol?',
        'options': [
          'Tumakbo palabas',
          'Duck, Cover, and Hold',
          'Tumawag sa 911',
          'Magpost sa social media'
        ],
        'correctAnswer': 1,
        'explanation':
            'Duck, Cover, and Hold ang dapat gawin. Magpahiga, magsilong sa ilalim ng mesa, at humawak nang mahigpit.',
        'category': 'earthquake',
      },
      {
        'question': 'Gaano kataas ang mabuting evacuation center?',
        'options': [
          'Mababa lang, malapit sa bahay',
          'Mas mataas kaysa flood level',
          'Walang pinagkaiba',
          'Sa basement'
        ],
        'correctAnswer': 1,
        'explanation':
            'Ang evacuation center ay dapat nasa mataas na lugar para hindi maabot ng baha.',
        'category': 'flood',
      },
      {
        'question': 'Ilang araw na supply ng tubig ang dapat nakahandang?',
        'options': ['1 araw', '3 araw', '1 linggo', 'Walang kailangan'],
        'correctAnswer': 1,
        'explanation':
            'Mag-ready ng 3-day supply ng tubig, at least 1 liter per person per day.',
        'category': 'preparedness',
      },
      {
        'question': 'Ano ang signal ng bagyo na pinakamalakas?',
        'options': ['Signal #1', 'Signal #2', 'Signal #3', 'Signal #5'],
        'correctAnswer': 3,
        'explanation':
            'Signal #5 ang pinakamalakas at delikado. Manatili sa loob ng bahay at huwag lumabas.',
        'category': 'typhoon',
      },
      {
        'question': 'Saan HINDI dapat pumunta kung may baha?',
        'options': [
          'Evacuation center',
          'Mataas na lugar',
          'Ilalim ng tulay',
          'Rooftop'
        ],
        'correctAnswer': 2,
        'explanation':
            'Huwag pumunta sa ilalim ng tulay dahil mabilis ang agos ng tubig doon.',
        'category': 'flood',
      },
    ];
  }

  // Badges
  static List<Map<String, dynamic>> getBadges() {
    return [
      {
        'id': 'first_report',
        'name': 'First Reporter',
        'description': 'Nag-submit ng unang report',
        'icon': '📝',
      },
      {
        'id': 'ready_ka_na',
        'name': 'Ready Ka Na!',
        'description': 'Kumpleto ang Go-Bag checklist',
        'icon': '🎒',
      },
      {
        'id': 'helper',
        'name': 'Bayanihan Hero',
        'description': 'Tumulong sa 5 reports',
        'icon': '🦸',
      },
      {
        'id': 'safe_citizen',
        'name': 'Safe Citizen',
        'description': 'Nag-update ng safe status 10 times',
        'icon': '✅',
      },
      {
        'id': 'learner',
        'name': 'DRRM Scholar',
        'description': 'Natapos ang lahat ng trivia',
        'icon': '🎓',
      },
      {
        'id': 'community_guardian',
        'name': 'Community Guardian',
        'description': 'Active sa community sa loob ng 30 days',
        'icon': '🛡️',
      },
    ];
  }
}
