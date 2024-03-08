// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// import '../data/users.dart';

// void _fetchRecords() async { 

//   QuerySnapshot snap = await FirebaseFirestore.instance
//           .collection("Employee")
//           .where('name', isEqualTo: Users.empName)
//           .get();
//       DocumentSnapshot snap2 = await FirebaseFirestore.instance
//           .collection("Employee")
//           .doc(snap.docs[0].id)
//           .collection("Records")
//           .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
//           .get();


//   await FirebaseFirestore.instance
//                                                   .collection("Employee")
//                                                   .doc(snap.docs[0].id)
//                                                   .collection('Records')
//                                                   .doc(DateFormat(
//                                                           'dd MMMM yyyy')
//                                                       .format(DateTime.now()))
//                                                   .update({
//                                                 'date': Timestamp.now(),
//                                                 'checkOut':
//                                                     DateFormat('hh:mm:ss a')
//                                                         .format(DateTime.now()),
//                                               });

                                             
                                             
                                          
                                        
//                                       );
//                                     },
//                                   );
//                                 } else {
//                                   await FirebaseFirestore.instance
//                                       .collection("Employee")
//                                       .doc(snap.docs[0].id)
//                                       .collection('Records')
//                                       .doc(DateFormat('dd MMMM yyyy')
//                                           .format(DateTime.now()))
//                                       .update({
//                                     'date': Timestamp.now(),
//                                     'checkOut': DateFormat('hh:mm:ss a')
//                                         .format(DateTime.now()),
//                                   });

//                                   setState(() {
//                                     checkOut = DateFormat('hh:mm:ss a')
//                                         .format(DateTime.now());
//                                   });
//                                 }
//                               } catch (e) {
//                                 await FirebaseFirestore.instance
//                                     .collection("Employee")
//                                     .doc(snap.docs[0].id)
//                                     .collection("Records")
//                                     .doc(DateFormat('dd MMMM yyyy')
//                                         .format(DateTime.now()))
//                                     .set({
//                                   'date': Timestamp.now(),
//                                   'checkIn': DateFormat('hh:mm:ss a')
//                                       .format(DateTime.now()),
//                                   'checkOut': '00:00:00 AM',
//                                   'wfo': phuket,
//                                   'wfh': krabi,
//                                   'agenda': agendaController.text.trim(),
//                                   'assignedtask': assignedTask,
//                                   'myLocation': myLocation
//                                 });
// }