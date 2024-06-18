use crate::i18n::*;
use leptos::*;
use leptos_meta::*;
use leptos_router::*;

use crate::home;

const DEFAULT_LOCALE: &str = "en";

#[derive(Params, PartialEq, Clone, Debug)]
pub struct LayoutParams {
    locale: String,
}

#[component(transparent)]
fn LocalizedRoute<P, F, IV>(path: P, view: F) -> impl IntoView
where
    P: std::fmt::Display,
    F: Fn() -> IV + 'static,
    IV: IntoView,
{
    view! {
        <Route path=format!("/:locale{}", path) view=move || {
            // Extract the locale from the path.
            let i18n = use_i18n();
            let params = use_params::<LayoutParams>();
            let chosen_locale = move || params().map(|params| params.locale).unwrap_or(DEFAULT_LOCALE.to_string());

            create_effect(move |_| {
                // Figure out what the current locale is, and if it matches the chosen locale from path.
                let current_locale = i18n();
                let new_locale = match chosen_locale().as_str() {
                    "fr" => Locale::fr,
                    "en" => Locale::en,
                    _ => Locale::en,
                };
                // Update the locale if necessary.
                if current_locale != new_locale {
                    i18n(new_locale);
                }
            });

            view! {
                {view()}
            }
        }/>
    }
}

#[component]
pub fn Layout() -> impl IntoView {
    provide_meta_context();
    provide_i18n_context();

    view! {
        <Router>
            <main>
                <Routes>
                    <Route path="" view=move || view! { <Redirect path=format!("/{}", DEFAULT_LOCALE)/> }/>
                    <LocalizedRoute path="" view=move || view! { <home::Page/> }/>
                </Routes>
            </main>
        </Router>
    }
}
