use crate::i18n::*;
use leptos::*;
use leptos_router::*;
use shared;

#[component]
#[allow(non_snake_case)]
pub fn Page() -> impl IntoView {
    let i18n = use_i18n();

    let route_to_other_locale = move || match i18n.get_locale() {
        Locale::en => "/fr".to_owned(),
        Locale::fr => "/en".to_owned(),
    };

    view! {
        <div class="grid place-content-center content-center h-screen">
            <h1 class="text-6xl text-center pb-8">{t!(i18n, home.emoji)}</h1>
            <div class="text-center">
            <A href=route_to_other_locale>
                {t!(i18n, home.ready)}
                {" "}
                {shared::eat_fruit(shared::Fruits::Watermelon)}
            </A>
            </div>
        </div>
    }
}
