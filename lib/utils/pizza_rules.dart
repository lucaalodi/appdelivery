int maxFlavorsBySize(String size) {
  switch (size) {
    case 'Pequena':
      return 2;
    case 'Média':
      return 3;
    case 'Grande':
      return 4;
    default:
      return 1;
  }
}
