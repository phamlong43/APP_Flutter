class Employee {
  final String id;
  final String employeeCode;
  final String fullName;
  final String position;
  final String department;
  final String email;
  final String? gender;
  final String? dateOfBirth;
  final String? placeOfBirth;
  final String? nationality;
  final String? ethnicity;
  final String? religion;
  final String? maritalStatus;
  final String? education;
  final String? idNumber;
  final String? idIssuedPlace;
  final String? idIssuedDate;
  final String? permanentAddress;
  final String? temporaryAddress;
  final String? address;
  final String? phone;
  final String? mobile;
  final String? workStatus;
  final String? createdAt;
  final String? updatedAt;

  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.position,
    required this.department,
    required this.email,
    this.gender,
    this.dateOfBirth,
    this.placeOfBirth,
    this.nationality,
    this.ethnicity,
    this.religion,
    this.maritalStatus,
    this.education,
    this.idNumber,
    this.idIssuedPlace,
    this.idIssuedDate,
    this.permanentAddress,
    this.temporaryAddress,
    this.address,
    this.phone,
    this.mobile,
    this.workStatus,
    this.createdAt,
    this.updatedAt,
  });
}
