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
        // Define a custom theme for text
        textTheme: const TextTheme(
          headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 16),
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
  int _itemsPerPage = 5; // Number of items per page

  // Fetch data from the API
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
            var logData = item['<Log>k__BackingField'];
            return {
              'NombreAlmacen': item['<NombreAlmacen>k__BackingField'],
              'WhsCode': item['<WhsCode>k__BackingField'] ?? 'N/A',
              'Descripcion': item['<Descripcion>k__BackingField'],
              'Direccion': item['<Direccion>k__BackingField'],
              'Bodeguero': item['<Bodeguero>k__BackingField'] ?? 'N/A',
              'Correo': item['<Correo>k__BackingField'] ?? 'N/A',
              'IdUsuario': item['<IdUsuario>k__BackingField'],
              'FechaCreacion': logData['<FechaCreacion>k__BackingField'],
              'IdUsuarioCreacion': logData['<IdUsuarioCreacion>k__BackingField'] ?? 'N/A',
              'IdHostCreacion': logData['<IdHostCreacion>k__BackingField'] ?? 'N/A',
              'FechaModificacion': logData['<FechaModificacion>k__BackingField'],
              'IdUsuarioModificacion': logData['<IdUsuarioModificacion>k__BackingField'] ?? 'N/A',
              'IdHostModificacion': logData['<IdHostModificacion>k__BackingField'] ?? 'N/A',
              'Browser': logData['<Browser>k__BackingField'] ?? 'N/A',
              'SO': logData['<SO>k__BackingField'] ?? 'N/A',
              'Pantalla': logData['<Pantalla>k__BackingField'] ?? 'N/A',
              'Dispositivo': logData['<Dispositivo>k__BackingField'] ?? 'N/A',
              'FechaSistema': logData['<FechaSistema>k__BackingField'],
              'Activo': logData['<Activo>k__BackingField'],
              'Eliminado': logData['<Eliminado>k__BackingField'],
              'Estatus': logData['<Estatus>k__BackingField'],
              'DBSAP': logData['<DBSAP>k__BackingField'],
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
    fetchData(); // Fetch the data when the page loads
  }

  // Paginate the data
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
                    ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
                    : Expanded(
                        child: Column(
                          children: [
                            AnimatedOpacity(
                              opacity: _isLoading ? 0.0 : 1.0,
                              duration: const Duration(seconds: 1),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor:
                                      MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
                                  columns: const [
                                    DataColumn(label: Text('Almacen')),
                                    DataColumn(label: Text('WhsCode')),
                                    DataColumn(label: Text('Descripcion')),
                                    DataColumn(label: Text('Direccion')),
                                    DataColumn(label: Text('Bodeguero')),
                                    DataColumn(label: Text('Correo')),
                                    DataColumn(label: Text('Fecha Creacion')),
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
                                              DataCell(Text(item['NombreAlmacen'])),
                                              DataCell(Text(item['WhsCode'])),
                                              DataCell(Text(item['Descripcion'])),
                                              DataCell(Text(item['Direccion'])),
                                              DataCell(Text(item['Bodeguero'])),
                                              DataCell(Text(item['Correo'])),
                                              DataCell(Text(item['FechaCreacion'])),
                                              DataCell(Text(item['Activo'].toString())),
                                              DataCell(Text(item['DBSAP'])),
                                            ],
                                          ),
                                        );
                                      })
                                      .values
                                      .toList(),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Página $_page of ${((_data.length / _itemsPerPage).ceil())}'),
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

