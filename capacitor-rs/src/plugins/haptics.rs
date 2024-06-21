use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub struct ImpactOptions {
    /// Impact Feedback Style
    ///
    /// The mass of the objects in the collision simulated by a [UIImpactFeedbackGenerator](https://developer.apple.com/documentation/uikit/uiimpactfeedbackstyle) object.
    ///
    /// @default ImpactStyle.Heavy
    /// @since 1.0.0
    pub style: ImpactStyle,
}

#[wasm_bindgen]
#[derive(Clone, Copy)]
pub enum ImpactStyle {
    /// A collision between large, heavy user interface elements
    ///
    /// @since 1.0.0
    Heavy,
    /// A collision between moderately sized user interface elements
    ///
    /// @since 1.0.0
    Medium,
    /// A collision between small, light user interface elements
    ///
    /// @since 1.0.0
    Light,
}

impl ImpactStyle {
    pub fn as_str(&self) -> &'static str {
        match self {
            ImpactStyle::Heavy => "HEAVY",
            ImpactStyle::Medium => "MEDIUM",
            ImpactStyle::Light => "LIGHT",
        }
    }
}

#[wasm_bindgen(module = "/js-dist/haptics.js")]
extern "C" {
    // #[wasm_bindgen(typescript_type = "ImpactOptions")]
    // pub type ImpactOptions;

    /// Trigger a haptics "impact" feedback.
    #[wasm_bindgen]
    pub async fn haptics_impact(options: ImpactOptions);

    #[wasm_bindgen]
    /// Trigger a haptics medium "impact" feedback.
    pub async fn haptics_impact_medium();

    #[wasm_bindgen]
    /// Trigger a haptics light "impact" feedback.
    pub async fn haptics_impact_light();

    #[wasm_bindgen]
    /// Vibrate the device.
    pub async fn haptics_vibrate();

    #[wasm_bindgen]
    /// Trigger a selection started haptic hint.
    pub async fn haptics_selection_start();

    #[wasm_bindgen]
    /// Trigger a selection changed haptic hint. If a selection was started already, this
    /// will cause the device to provide haptic feedback.
    pub async fn haptics_selection_changed();

    #[wasm_bindgen]
    /// If selectionStart() was called, selectionEnd() ends the selection. For example,
    /// call this when a user has lifted their finger from a control.
    pub async fn haptics_selection_end();
}
