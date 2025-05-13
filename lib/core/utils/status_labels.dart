/// Traduce el estado interno del partido a una etiqueta visual amigable
String gameStatusLabel(String status) {
  switch (status) {
    case 'confirmed':
      return 'Game Confirmed';
    case 'full':
      return 'Full';
    case 'cancelled':
      return 'Cancelled';
    case 'finished':
      return 'Finished';
    default:
      return 'Open';
  }
}
