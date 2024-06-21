use wasm_bindgen::prelude::*;

#[wasm_bindgen(typescript_custom_section)]
#[allow(non_upper_case_globals)]
/// https://capacitorjs.com/docs/apis/app#urlopenlistenerevent
const URLOpenListenerEvent: &'static str = r#"
interface URLOpenListenerEvent {
    // The URL the app was opened with.
    url: String
    // The source application opening the app (iOS only)
    iosSourceApplication: Any
    // Whether the app should open the passed document in-place or must copy it first.
    iosOpenInPlace: Bool
}
"#;

#[wasm_bindgen(module = "/defined-in-js.js")]
extern "C" {
    #[wasm_bindgen(js_name = App)]
    type CapacitorApp;

    #[wasm_bindgen(typescript_type = "URLOpenListenerEvent")]
    pub type URLOpenListenerEvent;

    #[wasm_bindgen(js_namespace = App, js_name = addListener)]
    fn add_listener(eventName: &str, eventFn: Fn(URLOpenListenerEvent) -> ()) -> CapacitorApp;
}
