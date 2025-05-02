import 'package:bri_cek/models/bank_branch.dart';

// Sample data for bank branches with local images
final List<BankBranch> branches = [
  BankBranch(
    id: '1',
    name: 'KK Genteng Kali Surabaya',
    address: 'Jl. Genteng Besar No.26, Surabaya, Jawa Timur',
    imageUrl: 'assets/images/genteng_kali.jpg',
    isLocalImage: true,
    city: 'Surabaya',
    phoneNumber: '(031) 5345678',
    operationalHours: 'Senin-Jumat: 08.00-15.00',
  ),
  BankBranch(
    id: '2',
    name: 'KK Gubeng Surabaya',
    address: 'Jl. Raya Gubeng No.8, Gubeng, Surabaya, Jawa Timur 60281',
    imageUrl: 'assets/images/gubeng.jpg',
    isLocalImage: true,
    city: 'Surabaya',
    phoneNumber: '(031) 5033214',
    operationalHours: 'Senin-Jumat: 08.00-15.00, Sabtu: 08.00-12.00',
  ),
  BankBranch(
    id: '3',
    name: 'KK Bulog Surabaya',
    address:
        'Jl. Ahmad Yani No.146-148, Gayungan, Kec. Gayungan, Surabaya, Jawa Timur',
    imageUrl: 'assets/images/bulog.jpg',
    isLocalImage: true,
    city: 'Surabaya',
    phoneNumber: '(031) 8290123',
    operationalHours: 'Senin-Jumat: 08.00-15.00',
  ),
  BankBranch(
    id: '4',
    name: 'KK Kodam Surabaya',
    address: 'Jl. Raya Kodam V Brawijaya, Surabaya, Jawa Timur',
    imageUrl: 'assets/images/kodam.jpg',
    isLocalImage: true,
    city: 'Surabaya',
    phoneNumber: '(031) 8432678',
    operationalHours: 'Senin-Jumat: 08.00-15.00',
  ),
];
