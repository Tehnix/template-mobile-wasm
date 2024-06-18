use leptos::*;

mod app;
mod home;

// Load our locales from the files defined in `Cargo.toml`.
leptos_i18n::load_locales!();

pub fn main() {
    // Register log and panich handlers.
    let _ = console_log::init_with_level(log::Level::Debug);
    console_error_panic_hook::set_once();

    mount_to_body(|| {
        view! { <app::Layout /> }
    });
}
