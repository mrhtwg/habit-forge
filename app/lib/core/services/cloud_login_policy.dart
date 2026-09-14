/// Pure policy for cloud-account linking conflict checks.
///
/// When the player already has local progress and signs into an **existing**
/// cloud account (one that already has a character), continuing replaces the
/// in-app state with the cloud save. Cancel must skip login / sync entirely.
class CloudLoginPolicy {
  CloudLoginPolicy._();

  /// Whether to show the overwrite confirmation dialog.
  static bool shouldConfirmOverwrite({
    required bool hasLocalProgress,
    required bool isExistingCloudAccount,
  }) =>
      hasLocalProgress && isExistingCloudAccount;

  /// Local progress = character created and/or any tasks exist.
  static bool hasLocalProgress({
    required bool hasCharacter,
    required int taskCount,
  }) =>
      hasCharacter || taskCount > 0;
}
