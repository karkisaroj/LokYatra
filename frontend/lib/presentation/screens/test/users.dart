// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
//
// import 'Bloc/userEvent.dart';
// import 'Bloc/userState.dart';
// import 'Bloc/usersBloc.dart';
//
// class Posts extends StatefulWidget {
//   const Posts({super.key});
//
//   @override
//   State<Posts> createState() => _PostsState();
// }
//
// class _PostsState extends State<Posts> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<UserBloc>(
//       create: (context) => UserBloc()..add(ButtonClicked()),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('LokYatra Users'),
//           backgroundColor: Colors.grey,
//         ),
//         body: BlocBuilder<UserBloc, UserState>(
//           builder: (context, state) {
//             if (state is UserLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is UserLoaded) {
//               if (state.users.isEmpty) {
//                 return const Center(child: Text('No users found'));
//               }
//               return ListView.builder(
//                 itemCount: state.users.length,
//                 itemBuilder: (context, index) {
//                   final user = state.users[index];
//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: ListTile(
//                       leading: Text(user.name),
//                       title: Text(user.role),
//                       subtitle: Text(user.createdAt!=null?DateFormat('yyyy-MM-dd HH:mm:ss').format(user.createdAt!.toLocal()):"No Date" ),
//                       trailing: Chip(
//                         label: Text(user.role ),
//                         backgroundColor: user.role == 'admin' ? Colors.red : Colors.orange,
//                       ),
//                     ),
//                   );
//                 },
//               );
//             } else if (state is UserError) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(state.message, textAlign: TextAlign.center),
//                     ElevatedButton(
//                       onPressed: () {
//                         context.read<UserBloc>().add(ButtonClicked());
//                       },
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             // Initial state - show a button to load users
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Tap to load users'),
//                   ElevatedButton(
//                     onPressed: () {
//                       context.read<UserBloc>().add(ButtonClicked());
//                     },
//                     child: const Text('Load Users'),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }