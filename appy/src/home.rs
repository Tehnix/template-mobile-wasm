use crate::i18n::*;
use leptos::*;
use leptos_router::*;

#[component]
pub fn Page() -> impl IntoView {
    let i18n = use_i18n();

    view! {
        <div class="grid place-content-center content-center h-screen">
            <h1 class="text-6xl">{t!(i18n, home.intro)}</h1>
            <div class="grid gap-4 grid-cols-2">
                <A href="/fr">"Go to fr"</A>
                <A href="/en">"Go to en"</A>
            </div>
        </div>
    }
}
