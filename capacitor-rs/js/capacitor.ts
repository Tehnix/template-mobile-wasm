/**
 * https://capacitorjs.com/docs/basics/utilities
 *
 * Capacitor has several JavaScript functions available to ensure apps run successfully
 * across multiple platforms with the same codebase.
 */
import { Capacitor } from "@capacitor/core";

/**
 * Converts a device filepath into a Web View-friendly path.
 *
 * Capacitor apps are served on a different protocol than device files. To avoid
 * difficulties between these protocols, paths to device files must be rewritten. For
 * example, on Android, file:///path/to/device/file must be rewritten as
 * http://localhost/_capacitor_file_/path/to/device/file before being used in the
 * Web View.
 *
 * Example:
 * ```typescript
 * // file:///path/to/device/photo.jpg
 * const rawPhotoUri = await Filesystem.writeFile({
 *   path: "myFile.jpg",
 *   data: base64Data,
 *   directory: FilesystemDirectory.Data
 * });
 *
 * // http://localhost/path/to/device/photo.jpg
 * const fixedPhotoUri = Capacitor.convertFileSrc(rawPhotoUri.uri),
 * ```
 */
export const convert_file_src = (filePath: string): string => {
  return Capacitor.convertFileSrc(filePath);
};

/**
 * Get the name of the Platform the app is currently running on. This will return
 * a value of "web", "ios", or "android" depending on the device the
 * app is running on.
 *
 * Example:
 * ```typescript
 * if (Capacitor.getPlatform() === 'ios') {
 *   console.log('iOS!');
 * } else if (Capacitor.getPlatform() === 'android') {
 *   console.log('Android!');
 * } else {
 *   console.log('Web!');
 * }
 * ```
 */
export const get_platform = (): string => {
  return Capacitor.getPlatform();
};

/**
 * Check whether the currently running platform is native. This function returns a value
 * of true if the app is running as a native, installed Capacitor app, or false if it
 * is served via a browser or installed as a PWA.
 *
 * Example:
 * ```typescript
 * if (Capacitor.isNativePlatform()) {
 *   console.log("I'm a native app!");
 * } else {
 *   console.log("I'm a PWA or Web app!");
 * }
 * ```
 */
export const is_native_platform = (): boolean => {
  return Capacitor.isNativePlatform();
};

/**
 * Check if a plugin is available on the currently running platform. The plugin name is
 * used in the plugin registry, which means it also works with custom plugins.
 *
 * Example:
 * ```typescript
 * if (!isAvailable) {
 *   // Have the user upload a file instead
 * } else {
 *   // Otherwise, make the call:
 *   const image = await Camera.getPhoto({
 *     resultType: CameraResultType.Uri,
 *   });
 * }
  ```
 */
export const is_plugin_available = (pluginName: string): boolean => {
  return Capacitor.isPluginAvailable(pluginName);
};
