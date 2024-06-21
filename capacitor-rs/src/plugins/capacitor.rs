use wasm_bindgen::prelude::*;

#[wasm_bindgen(module = "/js-dist/capacitor.js")]
extern "C" {
    #[wasm_bindgen]
    pub fn convert_file_src(file_path: &str) -> String;

    #[wasm_bindgen]
    pub fn get_platform() -> String;

    #[wasm_bindgen]
    pub fn is_native_platform() -> bool;

    #[wasm_bindgen]
    pub fn is_plugin_available(plugin_name: &str) -> bool;
}
