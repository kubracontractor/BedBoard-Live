bool isValidHospitalNumber(String input) {
  return RegExp(r'^\d{8}$').hasMatch(input);
}