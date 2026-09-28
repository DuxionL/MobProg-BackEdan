import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

/// Every tappable row on the Backup screen.
/// Add the real logic for each one inside [_BackupPageState._onItemTap].
enum BackupAction {
  googleDriveAutoBackup,
  backupRestoreOnDevice,
  exportBackupToEmail,
  exportToExcel,
  importExcel,
  exportPhotoFiles,
  importPhotoFiles,
  helpBackupRestore,
  completeReset,
  resetContentsOnly,
}

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  /// Shown on the right of the Google Drive row ("Off" / "On").
  /// Wire this to a saved setting later.
  String _googleDriveStatus = 'Off';

  /// One place to plug in functionality later. Nothing happens for now.
  void _onItemTap(BackupAction action) {
    switch (action) {
      case BackupAction.googleDriveAutoBackup:
        // TODO: toggle / configure Google Drive automated backup.
        break;
      case BackupAction.backupRestoreOnDevice:
        // TODO: backup / restore on device.
        break;
      case BackupAction.exportBackupToEmail:
        // TODO: export backup file and share by e-mail.
        break;
      case BackupAction.exportToExcel:
        // TODO: export data to Excel.
        break;
      case BackupAction.importExcel:
        // TODO: import Excel file.
        break;
      case BackupAction.exportPhotoFiles:
        // TODO: export photo files.
        break;
      case BackupAction.importPhotoFiles:
        // TODO: import photo files.
        break;
      case BackupAction.helpBackupRestore:
        // TODO: open backup/restore help.
        break;
      case BackupAction.completeReset:
        // TODO: confirm, then reset everything.
        break;
      case BackupAction.resetContentsOnly:
        // TODO: confirm, then reset contents only.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: ListView(
        children: [
          _buildItem(
            'Google Drive automated backup',
            BackupAction.googleDriveAutoBackup,
            textColor,
            isDark,
            value: _googleDriveStatus,
          ),
          _buildItem('Backup/restore on device',
              BackupAction.backupRestoreOnDevice, textColor, isDark),
          _buildItem('Export backup files to e-mail',
              BackupAction.exportBackupToEmail, textColor, isDark),
          _buildItem('Export data to Excel', BackupAction.exportToExcel,
              textColor, isDark),
          _buildItem(
              'Import Excel File', BackupAction.importExcel, textColor, isDark),
          _buildItem('Export Photo Files', BackupAction.exportPhotoFiles,
              textColor, isDark),
          _buildItem('Import Photo Files', BackupAction.importPhotoFiles,
              textColor, isDark),
          _buildItem('Help (backup/restore)', BackupAction.helpBackupRestore,
              textColor, isDark),
          _buildSectionHeader('Reset', isDark),
          _buildItem(
              'A complete reset', BackupAction.completeReset, textColor, isDark),
          _buildItem('Reset contents only (Others remain)',
              BackupAction.resetContentsOnly, textColor, isDark),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF151518) : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.grey : Colors.grey.shade700,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItem(
    String title,
    BackupAction action,
    Color textColor,
    bool isDark, {
    String? value,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => _onItemTap(action),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: textColor, fontSize: 15),
                  ),
                ),
                if (value != null)
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppTheme.accentRed,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Divider(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}