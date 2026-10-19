class AddProductQuotationModel {
  int tabId;
  int itemNumber;
  int itemRowId; // ✅ item row ID from API (e.g. 153) — used for delete
  int productId; // ✅ actual product ID (e.g. 26) — used in PATCH payload
  String selectedProduct;
  String quantity;
  String unitPrice;
  String total;
  String sgst;
  String cgst;
  String subTotal;

  AddProductQuotationModel({
    this.tabId = 0,
    required this.itemNumber,
    this.itemRowId = 0,
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
