import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class PreferenceDialog extends StatefulWidget {
  final String title;
  final List<Widget> preferences;
  final String submitText;
  final String cancelText;

  final bool onlySaveOnSubmit;

  const PreferenceDialog(this.preferences,
      {this.title,
      this.submitText,
      this.onlySaveOnSubmit = false,
      this.cancelText});

  PreferenceDialogState createState() => PreferenceDialogState();
}

class PreferenceDialogState extends State<PreferenceDialog> {
  @override
  void initState() {
    super.initState();

    if (widget.onlySaveOnSubmit) {
      PrefService.rebuildCache();
      PrefService.enableCaching();
    }
  }

  @override
  void dispose() {
    PrefService.disableCaching();
    PrefService.rebuildCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.preferences;

    final alert = AlertDialog(
      title: widget.title == null ? null : Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          children: settings,
        ),
      ),
      actions: <Widget>[]
        ..addAll(widget.cancelText == null
            ? []
            : [
                FlatButton(
                  child: Text(widget.cancelText),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ])
        ..addAll(widget.submitText == null
            ? []
            : [
                FlatButton(
                  child: Text(widget.submitText),
                  onPressed: () {
                    if (widget.onlySaveOnSubmit) {
                      PrefService.applyCache();
                    }
                    Navigator.of(context).pop();
                  },
                )
              ]),
    );

    // Check if we already have a BasePrefService
    final service = PrefService.of(context);
    if (service != null) {
      return PrefService(
        service: service,
        child: alert,
      );
    }

    // Fallback to SharedPreferences
    return FutureBuilder(
      future: SharedPrefService.init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        return PrefService(
          service: service,
          child: snapshot.data,
        );
      },
    );
  }
}
