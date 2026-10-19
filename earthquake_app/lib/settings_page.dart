import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'providers/app_data_provider.dart';
import 'utils/helper_functions.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _selectDate(
    AppDataProvider provider, {
    required bool start,
  }) async {
    final value = start ? provider.startTime : provider.endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(value),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (!mounted || date == null) return;
    final formatted = DateFormat('yyyy-MM-dd').format(date);
    if (start) {
      provider.setStartTime(formatted);
    } else {
      provider.setEndTime(formatted);
    }
  }

  Future<void> _updateDates(AppDataProvider provider) async {
    try {
      EasyLoading.show(status: 'Loading earthquakes…', dismissOnTap: false);
      final success = await provider.applyDates();
      await EasyLoading.dismiss();
      if (mounted) {
        showMsg(
          context,
          success
              ? 'Times are updated'
              : provider.error ?? 'Could not update data',
        );
      }
    } on ArgumentError catch (error) {
      await EasyLoading.dismiss();
      if (mounted) showMsg(context, error.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Consumer<AppDataProvider>(
            builder: (context, provider, _) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Time Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dates are inclusive and use UTC. Select a range, then apply your changes.',
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Start Time'),
                        subtitle: Text(provider.startTime),
                        trailing: IconButton(
                          tooltip: 'Select start date',
                          onPressed: () => _selectDate(provider, start: true),
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ),
                      ListTile(
                        title: const Text('End Time'),
                        subtitle: Text(provider.endTime),
                        trailing: IconButton(
                          tooltip: 'Select end date',
                          onPressed: () => _selectDate(provider, start: false),
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: provider.isLoading || provider.isLocating
                      ? null
                      : () => _updateDates(provider),
                  child: const Text('Update Time Changes'),
                ),
                const SizedBox(height: 28),
                Text(
                  'Location Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Earthquakes near me'),
                        subtitle: Text(
                          'Within ${provider.maxRadiusKm.round()} km of your current location',
                        ),
                        value: provider.shouldUseLocation,
                        onChanged: provider.isLocating || provider.isLoading
                            ? null
                            : (value) async {
                                final message = await provider.setUseLocation(
                                  value,
                                );
                                if (context.mounted && message != null) {
                                  showMsg(context, message);
                                }
                              },
                      ),
                      if (provider.isLocating)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(child: Text('Getting your location…')),
                            ],
                          ),
                        ),
                      if (provider.shouldUseLocation)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            provider.currentCity ??
                                '${provider.latitude.toStringAsFixed(4)}, ${provider.longitude.toStringAsFixed(4)}',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'USGS PAGER alert colours describe estimated impact, not magnitude. An event without an alert has no coloured dot.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
