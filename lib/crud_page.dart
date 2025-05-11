import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class CrudPage extends StatefulWidget {
  const CrudPage({Key? key}) : super(key: key);

  @override
  _CrudPageState createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<ParseObject> userDataList = [];
  ParseObject? currentEditingRecord;

  Future<void> fetchData({String? searchText}) async {
    QueryBuilder<ParseObject> query = QueryBuilder<ParseObject>(ParseObject('UserData'));
    if (searchText != null && searchText.trim().isNotEmpty) {
      query.whereContains('Name', searchText, caseSensitive: false);
    }
    List<ParseObject> fetchedData = await query.find();
    setState(() {
      userDataList = fetchedData;
    });
  }

  Future<void> addRecord() async {
    if (nameController.text.isNotEmpty && ageController.text.isNotEmpty) {
      final userData = ParseObject('UserData')
        ..set('Name', nameController.text)
        ..set('Age', int.tryParse(ageController.text));

      ParseResponse response = await userData.save();
      if (response.success) {
        nameController.clear();
        ageController.clear();
        fetchData();
      }
    }
  }

  Future<void> updateRecord(ParseObject userData) async {
    userData.set('Name', nameController.text);
    userData.set('Age', int.tryParse(ageController.text));

    ParseResponse response = await userData.save();
    if (response.success) {
      nameController.clear();
      ageController.clear();
      setState(() {
        currentEditingRecord = null;
      });
      fetchData();
    }
  }

  Future<void> deleteRecord(ParseObject userData) async {
    ParseResponse response = await userData.delete();
    if (response.success) {
      setState(() {
        userDataList.remove(userData);
      });
    }
  }

  void editRecord(ParseObject userData) {
    setState(() {
      currentEditingRecord = userData;
      nameController.text = userData.get<String>('Name') ?? '';
      ageController.text = userData.get<int>('Age')?.toString() ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final user = await ParseUser.currentUser() as ParseUser?;
              if (user != null) {
                await user.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(labelText: 'Search by name', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => fetchData(searchText: value),
            ),
            const SizedBox(height: 10),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: addRecord, child: const Text('Add Record')),
            if (currentEditingRecord != null)
              ElevatedButton(
                onPressed: () => updateRecord(currentEditingRecord!),
                child: const Text('Update Record'),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: userDataList.length,
                itemBuilder: (context, index) {
                  final userData = userDataList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Name: ${userData.get<String>('Name')}'),
                      subtitle: Text('Age: ${userData.get<int>('Age')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => editRecord(userData)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteRecord(userData)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
