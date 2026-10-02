void main() {
  final baseUrl = Uri.parse('http://10.0.2.2:5137/api');
  print('Resolving "/api/Invoice/by-customer/1":');
  print(baseUrl.resolve('/api/Invoice/by-customer/1'));
  
  print('Resolving "api/Invoice/by-customer/1":');
  print(baseUrl.resolve('api/Invoice/by-customer/1'));

  print('Resolving "/Invoice/by-customer/1":');
  print(baseUrl.resolve('/Invoice/by-customer/1'));

  print('Resolving "Invoice/by-customer/1":');
  print(baseUrl.resolve('Invoice/by-customer/1'));
}
