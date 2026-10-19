// ---- country dropdown in customer
// Consumer<CountryStateProvider>(
                              //   builder: (context, provider, child) {
                              //     return DropdownButtonFormField<String>(
                              //       decoration: const InputDecoration(
                              //         label: CustomText(
                              //           text: 'Country',
                              //           isMandatory: false,
                              //         ),
                              //         contentPadding:
                              //             EdgeInsets.symmetric(vertical: 8),
                              //       ),
                              //       value: provider.selectedCountry,
                              //       items: provider.countryList.map((country) {
                              //         return DropdownMenuItem<String>(
                              //           value: country.name,
                              //           child: Text(
                              //             country.name,
                              //             style: const TextStyle(
                              //               fontWeight: FontWeight.w400,
                              //             ),
                              //           ),
                              //         );
                              //       }).toList(),
                              //       onChanged: (String? newValue) {
                              //         provider.selectCountry(newValue);
                              //       },
                              //     );
                              //   },
                              // ),

// ---- state dropdown in customer
// Consumer<CountryStateProvider>(
                              //   builder: (context, provider, child) {
                              //     return DropdownButtonFormField<String>(
                              //       decoration: const InputDecoration(
                              //         label: CustomText(
                              //           text: 'State',
                              //           isMandatory: false,
                              //         ),
                              //         contentPadding:
                              //             EdgeInsets.symmetric(vertical: 8),
                              //       ),
                              //       value: provider.selectedState,
                              //       items: provider.stateList.map((state) {
                              //         return DropdownMenuItem<String>(
                              //           value: state.name,
                              //           child: Text(
                              //             state.name,
                              //             style: const TextStyle(
                              //               fontWeight: FontWeight.w400,
                              //             ),
                              //           ),
                              //         );
                              //       }).toList(),
                              //       onChanged: (String? newValue) {
                              //         provider.selectState(newValue);
                              //       },
                              //     );
                              //   },
                              // ),



// ---------- text with mandatory symbol * ==============

// Widget buildLabel(String text) {
//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: text,
//             style: const TextStyle(
//               color: AppColors.violetblue,F
//               fontSize: 16,
//             ),
//           ),
//           const TextSpan(
//             text: ' *',
//             style: TextStyle(
//               color: AppColors.red,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }