uniffi::setup_scaffolding!();

#[derive(uniffi::Enum)]
enum Fruits {
    Watermelon,
    Cranberry,
    Cherry,
}

#[derive(uniffi::Record)]
struct Person {
    name: String,
    age: u8,
}

#[uniffi::export]
fn say_hi() -> String {
    "Hello from Rust Again!".to_string()
}

#[uniffi::export]
fn eat_fruit(fruit: Fruits) -> String {
    match fruit {
        Fruits::Watermelon => "Eating Watermelon".to_string(),
        Fruits::Cranberry => "Eating Cranberry".to_string(),
        Fruits::Cherry => "Eating Cherry".to_string(),
    }
}

#[uniffi::export]
fn get_person() -> Person {
    Person {
        name: "John".to_string(),
        age: 25,
    }
}
