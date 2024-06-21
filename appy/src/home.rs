use log::info;

use crate::i18n::*;
use capacitor_rs::plugins::*;
use leptos::*;
use leptos_router::*;
use shared;

#[component]
#[allow(non_snake_case)]
pub fn Page() -> impl IntoView {
    let i18n = use_i18n();

    let platform = capacitor::get_platform();

    let route_to_other_locale = move || match i18n.get_locale() {
        Locale::en => "/fr".to_owned(),
        Locale::fr => "/en".to_owned(),
    };

    let haptic_feedback = create_action(|_: &()| {
        info!("Testing haptic_feedback");
        async move {
            let style = haptics::ImpactStyle::Light;
            haptics::haptics_impact(haptics::ImpactOptions {
                style: style.into(),
            })
        }
    });

    let open_browser = create_action(|_: &()| {
        info!("Testing browser plugin");
        async move { browser::open_website("https://google.com", None) }
    });

    view! {
        <div class="grid place-content-center content-center h-screen">
            <h1 class="text-6xl text-center pb-8">{t!(i18n, home.emoji)}</h1>
            <div class="text-center">
            <A href=route_to_other_locale>
                <span on:click=move |_| { haptic_feedback.dispatch(()) }>
                    {t!(i18n, home.ready)}
                    {" "}
                    {shared::eat_fruit(shared::Fruits::Watermelon)}
                </span>
            </A>
            </div>
            <button class="text-center pt-12 text-xs" on:click=move |_| { open_browser.dispatch(()) }>
                {"We're on "} {platform} {" btw"}
            </button>
        </div>
    }
}
