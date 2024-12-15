import 'package:flutter/material.dart';
import 'package:sales_force/database/gets_database.dart';

class FilterGroups extends StatefulWidget {
  const FilterGroups({super.key});

  @override
  State<FilterGroups> createState() => _FilterGroupsState();
}

class _FilterGroupsState extends State<FilterGroups> {
  String? sgrupo;
  Future<dynamic>? futureClients;

  @override
  void initState() {
    super.initState();
    futureClients = getClientsByGroup();
  }

  Future<dynamic> getClientsByGroup() async {
    return await getClientsOnlyGroupName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureClients,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los datos'));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        var clients = snapshot.data;
        List<String> groups = clients
            .map<String>((client) => client['group_bp_name'] as String)
            .toSet()
            .toList();
        groups.insert(0, "Todos");

        return AlertDialog(
          title: const Text('Filtrar por Grupo'),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Grupo'),
                value: sgrupo,
                onChanged: (selectedGrupo) {
                  setState(() {
                    sgrupo = selectedGrupo;
                  });
                },
                items: groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(
                      group,
                      style: const TextStyle(fontFamily: 'Poppins Regular'),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(sgrupo);
              },
              child: const Text(
                'Filtrar',
                style: TextStyle(
                    fontFamily: 'Poppins SemiBold', color: Color(0xFF7531FF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                    fontFamily: 'Poppins SemiBold', color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FilterRegions extends StatefulWidget {
  const FilterRegions({super.key});

  @override
  State<FilterRegions> createState() => _FilterRegionsState();
}

class _FilterRegionsState extends State<FilterRegions> {
  String? sgrupo;
  Future<dynamic>? futureClients;

  @override
  void initState() {
    super.initState();
    futureClients = getClientsByGroup();
  }

  Future<dynamic> getClientsByGroup() async {
    return await getClientsOnlyRegionName();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureClients,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los datos'));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }
//c_bpartner_location_id
        var regions = snapshot.data;
        List<String> groups = regions
            .map<String>((region) => region['name'] as String)
            .toSet()
            .toList();
        groups.insert(0, "Todos");

        return AlertDialog(
          title: const Text('Filtrar por Region'),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Region'),
                value: sgrupo,
                onChanged: (selectedGrupo) {
                  setState(() {
                    sgrupo = selectedGrupo;
                  });
                },
                items: groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(
                      group,
                      style: const TextStyle(fontFamily: 'Poppins Regular'),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(sgrupo);
              },
              child: const Text(
                'Filtrar',
                style: TextStyle(
                    fontFamily: 'Poppins SemiBold', color: Color(0xFF7531FF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                    fontFamily: 'Poppins SemiBold', color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
