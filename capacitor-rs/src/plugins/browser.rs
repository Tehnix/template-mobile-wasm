use wasm_bindgen::prelude::*;

#[wasm_bindgen(typescript_custom_section)]
const OPEN_OPTIONS: &'static str = r#"
/**
 * Represents the options passed to `open`.
 *
 * @since 1.0.0
 */
export interface OpenOptions {
    /**
     * The URL to which the browser is opened.
     *
     * @since 1.0.0
     */
    url: string;
    /**
     * Web only: Optional target for browser open. Follows
     * the `target` property for window.open. Defaults
     * to _blank.
     *
     * Ignored on other platforms.
     *
     * @since 1.0.0
     */
    windowName?: string;
    /**
     * A hex color to which the toolbar color is set.
     *
     * @since 1.0.0
     */
    toolbarColor?: string;
    /**
     * iOS only: The presentation style of the browser. Defaults to fullscreen.
     *
     * Ignored on other platforms.
     *
     * @since 1.0.0
     */
    presentationStyle?: 'fullscreen' | 'popover';
    /**
     * iOS only: The width the browser when using presentationStyle 'popover' on iPads.
     *
     * Ignored on other platforms.
     *
     * @since 4.0.0
     */
    width?: number;
    /**
     * iOS only: The height the browser when using presentationStyle 'popover' on iPads.
     *
     * Ignored on other platforms.
     *
     * @since 4.0.0
     */
    height?: number;
}
"#;

#[wasm_bindgen(module = "/js-dist/browser.js")]
extern "C" {
    #[wasm_bindgen(typescript_type = "OPEN_OPTIONS")]
    /// Represents the options passed to open.
    pub type OpenOptions;

    #[wasm_bindgen]
    /// Open a page with the specified options.
    pub async fn open_website(url: &str, options: Option<OpenOptions>);

    #[wasm_bindgen]
    /// Web & iOS only: Close an open browser window.
    ///
    /// No-op on other platforms.
    pub async fn close_browser();

    #[wasm_bindgen]
    /// Android & iOS only: Listen for the browser finished event. It fires when the
    /// Browser is closed by the user.
    pub async fn listen_browser_finished();

    #[wasm_bindgen]
    /// Android & iOS only: Listen for the page loaded event. It's only fired when the
    /// URL passed to open method finish loading. It is not invoked for any subsequent
    /// page loads.
    pub async fn listen_page_loaded();

}
