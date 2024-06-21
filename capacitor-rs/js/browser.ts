/**
 * https://capacitorjs.com/docs/apis/browser
 */
import type { OpenOptions } from "@capacitor/browser";
import { Browser } from "@capacitor/browser";
import type { PluginListenerHandle } from "@capacitor/core";

/**
 * Open a page with the specified options.
 */
export const open_website = async (url: string, options?: OpenOptions) => {
  await Browser.open({ ...options, url });
};

/**
 * Web & iOS only: Close an open browser window.
 *
 * No-op on other platforms.
 */
export const close_browser = async () => {
  await Browser.close();
};

/**
 * Android & iOS only: Listen for the browser finished event. It fires when the
 * Browser is closed by the user.
 */
export const listen_browser_finished = async (
  listenerFunc: () => void
): Promise<PluginListenerHandle> => {
  return Browser.addListener("browserFinished", listenerFunc);
};

/**
 * Android & iOS only: Listen for the page loaded event. It's only fired when the
 * URL passed to open method finish loading. It is not invoked for any subsequent
 * page loads.
 */
export const listen_page_loaded = async (
  listenerFunc: () => void
): Promise<PluginListenerHandle> => {
  return Browser.addListener("browserFinished", listenerFunc);
};
