import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datos de Almacén',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const WarehousePage(),
    );
  }
}

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});

  @override
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  final String apiUrl =
      'https://disdelsagt.com/MyWsMaestro/api/Conteo/GetAlmacen/SBO_DISDELSA_2013';

  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _page = 1;
  final int _itemsPerPage = 5;

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          _data = jsonData.map((item) {
            var logData = item['Log'];

            return {
              'NombreAlmacen': item['NombreAlmacen'] ?? 'N/A',
              'WhsCode': item['WhsCode'] ?? 'N/A',
              'Descripcion': item['Descripcion'] ?? 'N/A',
              'Direccion': item['Direccion'] ?? 'N/A',
              'Bodeguero': item['Bodeguero'] ?? 'N/A',
              'Correo': item['Correo'] ?? 'N/A',
              'IdUsuario': item['IdUsuario'] ?? 'N/A',
              'FechaCreacion': logData?['<FechaCreacion>k__BackingField'] ?? 'N/A',
              'Activo': logData?['<Activo>k__BackingField'] ?? false,
              'DBSAP': logData?['<DBSAP>k__BackingField'] ?? 'N/A',
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Falla al recuperar la información');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al recuperar los registros: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List<Map<String, dynamic>> getPagedData() {
    int startIndex = (_page - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    return _data.sublist(startIndex, endIndex > _data.length ? _data.length : endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información de Almacén'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Detalle de Almacén:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                    : Expanded(
                        child: Column(
                          children: [
                            AnimatedOpacity(
                              opacity: _isLoading ? 0.0 : 1.0,
                              duration: const Duration(seconds: 1),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor:
                                      MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
                                  columns: const [
                                    DataColumn(label: Text('Almacén')),
                                    DataColumn(label: Text('WhsCode')),
                                    DataColumn(label: Text('Descripción')),
                                    DataColumn(label: Text('Dirección')),
                                    DataColumn(label: Text('Bodeguero')),
                                    DataColumn(label: Text('Correo')),
                                    DataColumn(label: Text('Fecha Creación')),
                                    DataColumn(label: Text('Activo')),
                                    DataColumn(label: Text('DBSAP')),
                                  ],
                                  rows: getPagedData()
                                      .asMap()
                                      .map((index, item) {
                                        return MapEntry(
                                          index,
                                          DataRow(
                                            color: MaterialStateProperty.resolveWith((states) {
                                              return index % 2 == 0
                                                  ? Colors.blueGrey.withOpacity(0.1)
                                                  : Colors.transparent;
                                            }),
                                            cells: [
                                              DataCell(Text(item['NombreAlmacen'].toString())),
                                              DataCell(Text(item['WhsCode'].toString())),
                                              DataCell(Text(item['Descripcion'].toString())),
                                              DataCell(Text(item['Direccion'].toString())),
                                              DataCell(Text(item['Bodeguero'].toString())),
                                              DataCell(Text(item['Correo'].toString())),
                                              DataCell(Text(item['FechaCreacion'].toString())),
                                              DataCell(Text(item['Activo'].toString())),
                                              DataCell(Text(item['DBSAP'].toString())),
                                            ],
                                          ),
                                        );
                                      })
                                      .values
                                      .toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Página $_page de ${((_data.length / _itemsPerPage).ceil())}'),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: _page > 1
                                          ? () {
                                              setState(() {
                                                _page--;
                                              });
                                            }
                                          : null,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward),
                                      onPressed: _page < (_data.length / _itemsPerPage).ceil()
                                          ? () {
                                              setState(() {
                                                _page++;
                                              });
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
