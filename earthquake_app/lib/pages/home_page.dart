import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data_provider.dart';
import '../settings_page.dart';
import '../utils/helper_functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppDataProvider>().init();
    });
  }

  void _showSortingDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Consumer<AppDataProvider>(
          builder: (context, provider, _) => SizedBox(
            width: 340,
            child: RadioGroup<String>(
              groupValue: provider.orderBy,
              onChanged: (value) {
                if (value != null) provider.setOrder(value);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppDataProvider.orders.entries
                    .map(
                      (entry) => RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: entry.key,
                        title: Text(entry.value),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Earthquake App'),
      actions: [
        IconButton(
          tooltip: 'Sort',
          onPressed: _showSortingDialog,
          icon: const Icon(Icons.sort),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
          ),
          icon: const Icon(Icons.settings),
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Consumer<AppDataProvider>(
            builder: (context, provider, _) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${provider.appliedRange}\nMagnitude ≥ 4 • ${provider.shouldUseLocation ? "Within ${provider.maxRadiusKm.round()} km" : "Worldwide"} • UTC dates',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: provider.isLoading
                            ? null
                            : provider.getEarthquakeData,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _content(provider)),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Source: USGS • Up to 500 results • Times shown in device time',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _content(AppDataProvider provider) {
    if (provider.isLoading ||
        (!provider.hasDataLoaded && provider.error == null)) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait…'),
          ],
        ),
      );
    }
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40),
              const SizedBox(height: 12),
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.getEarthquakeData,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    final features = provider.earthquakeModel!.features;
    return RefreshIndicator(
      onRefresh: () async {
        await provider.getEarthquakeData();
      },
      child: features.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 90),
                Icon(Icons.public, size: 44),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No records found. Try a wider date range or turn off the location filter.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: features.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final data = features[index].properties;
                final knownAlert = [
                  'green',
                  'yellow',
                  'orange',
                  'red',
                ].contains(data.alert);
                return ListTile(
                  title: Text(data.place ?? data.title ?? 'Unknown location'),
                  subtitle: Text(
                    data.time == null
                        ? 'Time unavailable'
                        : getFormattedDateTime(
                            data.time!,
                            'EEE dd MMM yyyy, HH:mm',
                          ),
                  ),
                  trailing: Tooltip(
                    message: knownAlert
                        ? 'USGS PAGER alert: ${data.alert}'
                        : 'No PAGER alert reported',
                    child: Chip(
                      avatar: knownAlert
                          ? CircleAvatar(
                              backgroundColor: provider.getAlertColor(
                                data.alert!,
                              ),
                            )
                          : null,
                      label: Text('M ${data.mag?.toStringAsFixed(1) ?? "–"}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
