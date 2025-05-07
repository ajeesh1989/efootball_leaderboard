import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EntryListScreen extends StatefulWidget {
  const EntryListScreen({super.key});

  @override
  State<EntryListScreen> createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PlayerMatchResultProvider>().fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerMatchResultProvider>();
    final items = provider.items;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Data entries",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? const Center(
                child: Text(
                  "No results available",
                  style: TextStyle(color: Colors.white),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey.shade700,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            '#',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Player Name',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Result',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Time Stamp',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      rows: List.generate(items.length, (index) {
                        final item = items[index];
                        final date = item['date'];
                        String formattedDate = 'Not Available';

                        if (date != null) {
                          try {
                            DateTime parsedDate = DateTime.parse(
                              date.toString(),
                            );
                            formattedDate = DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format(parsedDate);
                          } catch (e) {
                            formattedDate = 'Invalid date';
                          }
                        }

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                item['name'] ?? 'Unnamed Item',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                item['detail'] ?? 'Not Available',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                formattedDate,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () => _editItem(context, item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () =>
                                            _confirmDelete(context, item['id']),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
    );
  }

  void _editItem(BuildContext context, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);
    final formController = TextEditingController(text: item['detail']);
    final _formKey = GlobalKey<FormState>();
    String selectedRank = item['rank'] ?? '1';

    final rankOptions = ['1', '2', '3', '4', '5'];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit Item"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRank,
                    decoration: const InputDecoration(labelText: 'Select Rank'),
                    items:
                        rankOptions.map((String rank) {
                          return DropdownMenuItem<String>(
                            value: rank,
                            child: Text(rank),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRank = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a rank';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an item name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: formController,
                    decoration: const InputDecoration(labelText: 'Detail'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a detail';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final updatedName = nameController.text.trim();
                    final itemId = item['id'];

                    try {
                      await context
                          .read<PlayerMatchResultProvider>()
                          .updateItem(
                            itemId,
                            updatedName,
                            formController.text.trim(),
                          );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item updated'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update item'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Item"),
            content: const Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await context.read<PlayerMatchResultProvider>().deleteItem(
                      itemId,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item deleted'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to delete item'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
