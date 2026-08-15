import 'package:bk_pos/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/network/dio_client.dart';
import 'core/storage/cache_service.dart';
import 'core/storage/token_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: ".env");
  await CacheService.init(); 
  await TokenManager.init();

  DioClient.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'BK POS',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const AppRouter(),
      ),
    );
  }
}
 
//==============================================================================
//PERNYATAAN
//==============================================================================
//1. kalau transaklsinya partial dibuat tgl 5 lalu pelunasanya tgl 6 (berarti omzet nya tgl 6)?? iya
//2. jika penjualan kan ada harga total prodyk, discon, ongkir , point // itu omzet dihitung apa saja. apkaah cuma nominal total barang?? nggak, tapi semua total transaksi

//po surat jalan(SJ)
//di SJ ada list    tapi dibarang datang gaada (yaudah relakan)
//di SJ ga ada list tapi ada barang (dibuatkan po lagi unutk barang itu)
//di SJ ada list    tapi qty barang kurang (kita terima apa adanya nominal itu)



//21 Juli 2026
//1. di apk agar di menu transaction yg ditampilkan transaction hari ini aja. tapi diberi filter bisa tampil transaction bulan ini
//2. perbaiki keyStatus  di app_router.dart
//3. di gambar hp yg PO finish tanyakn elsa sulastri ini siapa?? orang toko ini
//4. tambah scan ktp (auto input data di ktp) lalau di table customer tambah kolom email,  nik, alamat lengkap



//Informa 
//pdf nota
//add produk pada transaksi unpaid
//nomor kasir di nota , email di nota tiap toko
//settlement transfer, cash, uang cash toko dikirm by pdf ke pusat
//di nota beri tulisan "Batas waktu return max 7 hari. Syarat dan ketentuan berlaku"

//UPGRADE FITUR NANTI AJA PENTING POS JALAN DULU
//1. buat aplikasi unutk customer , aplikasi buat driver juga


//================================================================================
//Persiapan ke pak sony
//Setiap ada perubahan data beri notif (Penjualan/settlement, Mutasi, PO, )
//aksi yang merubah data bee dari toko cuma penjualan (update:stok berkurang) dan settlement (create:data settlement) update dan create ini liat poin 5
//================================================================================
//1. minta id nya user tiap kasir. buat di relasikan sama user versi database ku(biar login pakai email)

//2. liat hasil PO foto sbelum finish dan sudah finish (data apa saja yang dipakai)

//3. settlement itu ada per api an? kan kirim data/pdf yg isisnya nominal transfer, cash, sama uang kas toko 300.000 (ini per hari)

//4. cek gambar di hp gambar pertama itu (yg atas PO belum finish) (yg bawah PO sudah finish) - pusat buat po - pos ceklis po - masuk web pos - diinputkan ke bee
//data PO yg di buat API
//    a. no order
//    b. tanggal, supplier
//    c. kode item/produk
//    d. nama item/produk
//    e. qty, 

//5. cek gambar di hp gambar kedua itu settlement, toko kirim settlement datanya berupa lanjut 6 (berarti settlement itu sekaligus memperbarui data di bee, menyesuaikan pengurangan dari penjualan tiap toko)

//6. Transfer 
//    a. tipe pembayaran (yaitu transfer/BTRF)
//    b. nama kas/bank (minta daftar nama ke mbak ve)
//    c. jumlah
//    d. keterangan
//7. Cash
//    a. cara bayar (yaitu cash)
//    b. kas/bank   (Kas nama_toko)
//    c.jumlah
//    d. keterangan
// 

//8. kalau pusat lakukan mutasi dari toko A ke toko B, maka bee kirim api
// {
//   from: code toko A,
//   to: code toko B
// }
//biar dibaca oleh admin WEB POS biar dilakukan hit api (pembaruan data toko A dan B) atau biar scheduler aja yg lakukan 

//10. request api jadi 1 di get_price_all
// [
//   {
//     "itemid": "PBG4,5X5J",
//     "itemdesc": "Paku Beton Galvanis 4,5 x 5\" Jason",
//     "itgrpid": "000010",
//     "itgrpname": "Paku",
//     "qty": 6,
//     "price": 25766  //kayak gaperlu

//     //tambahan 
//     "unit": "LBR",
//     "prices": [
//        {
//         "prclvlid": "5",
//         "level": "Grosir",
//         "mu": "IDR",
//         "harga1": 0,          //kalau ini harag jual? 
//         "disc1": "",
//         "harga1nett": 0,      //ini harga apa? apakah harga hpp (klw iya mending gausa)

//         //dibawah ini semua unutk apa? hapus?
//         "harga2": 0,
//         "disc2": "",
//         "harga2nett": 0,
//         "harga3": 0,
//         "disc3": "",
//         "harga3nett": 0,
//         "pricedate": null,
//         "lastupd": null
//       },
//       ..dst
//     ]
//   },
// ]



