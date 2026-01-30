module uim.kubernetes.interfaces.watcher;

interface IK8SWatcher {
  /// Gets the next event from the watch stream.
  bool next(out WatchEvent event);

  IK8SWatcher close();
}
