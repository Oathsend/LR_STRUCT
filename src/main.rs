use toml::Value;
use toml::map::Map;
use serde::Deserialize;
use std::any::type_name;

fn type_of<T>(_: T) -> &'static str {
    type_name::<T>()
}

#[derive(Debug, Deserialize)]
struct WaveData {
    h_s: f32,
    t_z: f32,
    t_sd: f32,
    h_x: f32,
}

fn main() {
    read_input();
    
}
fn read_input() {
    let path = std::path::Path::new("src/input.toml");
    let file = match std::fs::read_to_string(path) {
        Ok(f) => f,
        Err(e) => panic!("{}", e),
    };

    let input: Map<String, Value> = file.parse::<Value>().ok().and_then(|r| match r {
        Value::Table(table) => Some(table),
        _ => None
    }).unwrap_or(Map::new());
    let service_area = service_area_notation(input);
    let s: &str = &service_area[1..service_area.len()-1]; // This is required to strip the quote marks around the notation. 
    println!("Service area notation is: {}", &s);
    let wave_data = get_wave_data(s);
    println!("Wave data for service area is:");
    println!("H_s: {}", wave_data.h_s);
    println!("T_z: {}", wave_data.t_z);
    println!("T_sd: {}", wave_data.t_sd);
    println!("H_x: {}", wave_data.h_x);
}

fn service_area_notation(input: Map<String, Value>) -> String {
    let service_area: String = input["servicearea"]["service_area"].to_string();
    service_area
}

fn get_wave_data(s: &str) -> WaveData {
    let path = std::path::Path::new("src/serviceareas.toml");
    let file = match std::fs::read_to_string(path) {
        Ok(f) => f,
        Err(e) => panic!("{}", e),
    };
    let serviceareas: Map<String,Value> = file.parse::<Value>().ok().and_then(|r| match r {
        Value::Table(table) => Some(table),
        _ => None
    }).unwrap_or(Map::new());
    let wavedata = serviceareas["wavedata"][s].clone();
    let out = wavedata.try_into::<WaveData>();
    out.expect("")
}
