uniffi::setup_scaffolding!();

#[derive(uniffi::Enum)]
pub enum Fruits {
    Watermelon,
    Cranberry,
    Cherry,
}

#[derive(uniffi::Record)]
pub struct Person {
    pub name: String,
    pub age: u8,
}

#[uniffi::export]
pub fn say_hi() -> String {
    "Hello from Rust Again!".to_string()
}

#[uniffi::export]
pub fn eat_fruit(fruit: Fruits) -> String {
    match fruit {
        Fruits::Watermelon => "Eating Watermelon".to_string(),
        Fruits::Cranberry => "Eating Cranberry".to_string(),
        Fruits::Cherry => "Eating Cherry".to_string(),
    }
}

#[uniffi::export]
pub fn get_person() -> Person {
    Person {
        name: "John".to_string(),
        age: 25,
    }
}
