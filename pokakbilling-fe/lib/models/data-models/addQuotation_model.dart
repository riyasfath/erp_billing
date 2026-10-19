class AddQuotationModel {
  int tabId;
  int itemNumber;
  int productId;
  String selectedProduct;
  String quantity;
  String unitPrice;
  String total;
  String sgst;
  String cgst;
  String subTotal;

  AddQuotationModel({
    this.tabId = 0,
    required this.itemNumber,
    this.productId = 0,
    this.selectedProduct = "",
    this.quantity = "",
    this.unitPrice = "",
    this.total = "",
    this.sgst = "",
    this.cgst = "",
    this.subTotal = "",
  });
}
