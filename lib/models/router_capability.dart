enum RouterCapabilityState {
  available,
  manualOnly,
  notVerified,
  unavailable,
}

class RouterCapability {
  final String id;
  final String name;
  final RouterCapabilityState state;
  final String explanation;

  const RouterCapability({
    required this.id,
    required this.name,
    required this.state,
    required this.explanation,
  });
}
