class HeartPart {
  final String id;
  final String name;
  final String description;
  final String function;

  const HeartPart({
    required this.id,
    required this.name,
    required this.description,
    required this.function,
  });
}

const heartParts = [
  HeartPart(
    id: '1',
    name: 'Aorta',
    description: '...',
    function: '...',
  ),

  HeartPart(
    id: '2',
    name: '...',
    description: '...',
    function: '...',
  ),

  HeartPart(
    id: '3',
    name: '...',
    description: '...',
    function: '...',
  ),

  // ...
];