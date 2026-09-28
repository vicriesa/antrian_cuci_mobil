import 'dart:collection';
import 'dart:io';

const kapasitasPos = 3;
const kapasitasWaitingList = 2;

class AntrianMobil {
  AntrianMobil({
    required this.nomor,
    required this.namaPelanggan,
    required this.nomorPolisi,
    required this.jenisCuci,
  });

  final int nomor;
  final String namaPelanggan;
  final String nomorPolisi;
  final String jenisCuci;
}

void main() {
  final posPencucian = List<AntrianMobil?>.filled(kapasitasPos, null);
  final Queue<AntrianMobil> waitingList = Queue<AntrianMobil>();
  var nomorAntrian = 1;
  var jalan = true;

  while (jalan) {
    tampilMenu();
    final pilihan = bacaInput('Pilih menu: ');

    switch (pilihan) {
      case '1':
        final berhasil = tambahAntrian(
          posPencucian,
          waitingList,
          nomorAntrian,
        );
        if (berhasil) nomorAntrian++;
        break;
      case '2':
        tampilkanAntrian(posPencucian, waitingList);
        break;
      case '3':
        panggilMobil(posPencucian, waitingList);
        break;
      case '4':
        clearAntrian(posPencucian, waitingList);
        break;
      case '5':
        jalan = false;
        print('\nTerima kasih telah menggunakan sistem antrian.');
        break;
      default:
        print('\nPilihan menu tidak tersedia.');
    }
  }
}

void tampilMenu() {
  print("\n===============================================");
  print("          SISTEM ANTRIAN CUCI MOBIL           ");
  print("===============================================");
  print("1. Tambah antrian mobil");
  print("2. Lihat status pos dan waiting list");
  print("3. Panggil antrian berikutnya");
  print("4. Clear pos/antrian");
  print("5. Keluar Aplikasi");
}

String bacaInput(String pesan) {
  stdout.write(pesan);
  return stdin.readLineSync()?.trim() ?? '';
}

bool tambahAntrian(
  List<AntrianMobil?> posPencucian,
  Queue<AntrianMobil> waitingList,
  int nomor,
) {
  print('\n--- Tambah Antrian ---');
  final namaPelanggan = bacaInput('Nama pelanggan: ');
  final nomorPolisi = bacaInput('Nomor polisi: ');

  if (namaPelanggan.isEmpty || nomorPolisi.isEmpty) {
    print('Nama pelanggan dan nomor polisi wajib diisi.');
    return false;
  }

  print('Jenis cuci:');
  print('1. Cuci biasa');
  print('2. Cuci premium');
  print('3. Cuci salju');
  final pilihanCuci = bacaInput('Pilih jenis cuci: ');
  final jenisCuci = switch (pilihanCuci) {
    '1' => 'Cuci biasa',
    '2' => 'Cuci premium',
    '3' => 'Cuci salju',
    _ => '',
  };

  if (jenisCuci.isEmpty) {
    print('Jenis cuci tidak tersedia. Data tidak ditambahkan.');
    return false;
  }

  final mobil = AntrianMobil(
    nomor: nomor,
    namaPelanggan: namaPelanggan,
    nomorPolisi: nomorPolisi.toUpperCase(),
    jenisCuci: jenisCuci,
  );

  final indeksPosKosong = posPencucian.indexWhere((pos) => pos == null);
  if (indeksPosKosong != -1) {
    posPencucian[indeksPosKosong] = mobil;
    print('Mobil masuk ke Pos ${indeksPosKosong + 1} dengan nomor $nomor.');
  } else if (waitingList.length < kapasitasWaitingList) {
    waitingList.add(mobil);
    print('Pos penuh. Mobil masuk waiting list dengan nomor $nomor.');
  } else {
    print('Pos dan waiting list penuh. Data tidak ditambahkan.');
    return false;
  }

  return true;
}

void tampilkanAntrian(
  List<AntrianMobil?> posPencucian,
  Queue<AntrianMobil> waitingList,
) {
  print('\n--- Status Pos Pencucian ---');
  for (var indeks = 0; indeks < posPencucian.length; indeks++) {
    final mobil = posPencucian[indeks];
    if (mobil == null) {
      print('Pos ${indeks + 1}: kosong');
    } else {
      print(
        'Pos ${indeks + 1}: ${mobil.nomor}. ${mobil.namaPelanggan} | '
        '${mobil.nomorPolisi} | ${mobil.jenisCuci}',
      );
    }
  }

  print('\n--- Waiting List ---');
  if (waitingList.isEmpty) {
    print('Waiting list kosong.');
    return;
  }

  for (final mobil in waitingList) {
    print(
      '${mobil.nomor}. ${mobil.namaPelanggan} | '
      '${mobil.nomorPolisi} | ${mobil.jenisCuci}',
    );
  }
}

void panggilMobil(
  List<AntrianMobil?> posPencucian,
  Queue<AntrianMobil> waitingList,
) {
  if (posPencucian.every((pos) => pos == null)) {
    print('\nTidak ada mobil di pos pencucian.');
    return;
  }

  print('\n--- Pilih Pos yang Selesai ---');
  for (var indeks = 0; indeks < posPencucian.length; indeks++) {
    final mobil = posPencucian[indeks];
    print(
      'Pos ${indeks + 1}: '
      '${mobil == null ? 'kosong' : mobil.namaPelanggan}',
    );
  }

  final pilihanPos = int.tryParse(bacaInput('Masukkan nomor pos: '));
  if (pilihanPos == null || pilihanPos < 1 || pilihanPos > kapasitasPos) {
    print('Nomor pos tidak valid.');
    return;
  }

  final indeksPos = pilihanPos - 1;
  if (posPencucian[indeksPos] == null) {
    print('Pos $pilihanPos sedang kosong.');
    return;
  }

  final mobil = posPencucian[indeksPos]!;
  posPencucian[indeksPos] = null;
  print('\n--- Panggilan Antrian ---');
  print('Nomor antrian ${mobil.nomor} dipanggil.');
  print('Pelanggan: ${mobil.namaPelanggan}');
  print('Nomor polisi: ${mobil.nomorPolisi}');
  print('Layanan: ${mobil.jenisCuci}');

  if (waitingList.isNotEmpty) {
    final mobilBerikutnya = waitingList.removeFirst();
    posPencucian[indeksPos] = mobilBerikutnya;
    print(
      'Nomor antrian ${mobilBerikutnya.nomor} dari waiting list '
      'masuk ke Pos ${indeksPos + 1}.',
    );
  }
}

void clearAntrian(
  List<AntrianMobil?> posPencucian,
  Queue<AntrianMobil> waitingList,
) {
  if (posPencucian.every((pos) => pos == null) && waitingList.isEmpty) {
    print('\nPos dan waiting list sudah kosong.');
    return;
  }

  final jumlahDihapus =
      posPencucian.where((pos) => pos != null).length + waitingList.length;
  for (var indeks = 0; indeks < posPencucian.length; indeks++) {
    posPencucian[indeks] = null;
  }
  waitingList.clear();
  print('\nBerhasil menghapus $jumlahDihapus mobil dari antrian.');
}
