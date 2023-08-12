use toml::Value;
use toml::map::Map;
use serde::Deserialize;
use std::any::type_name;


#[derive(Debug, Deserialize)]
struct WaveData {
    h_s: f32,
    t_z: f32,
    t_sd: f32,
    h_x: f32,
}

fn type_of<T>(_: T) -> &'static str {
    type_name::<T>()
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
    println!("Service area notation is: {}", &service_area);
    let wave_data = get_wave_data(service_area);
    println!("Wave data for service area is: {:#?}", &wave_data);
}

fn service_area_notation(input: Map<String, Value>) -> String {
    let service_area: String = input["servicearea"]["service_area"].to_string();
    service_area
}

fn get_wave_data(service_area: String) -> WaveData {
    let path = std::path::Path::new("src/serviceareas.toml");
    let file = match std::fs::read_to_string(path) {
        Ok(f) => f,
        Err(e) => panic!("{}", e),
    };
    let serviceareas: Map<String,Value> = file.parse::<Value>().ok().and_then(|r| match r {
        Value::Table(table) => Some(table),
        _ => None
    }).unwrap_or(Map::new());
    let s: &str = &service_area[1..service_area.len()-1]; // This is required to strip the quote marks around the notation. 
    let wavedata = serviceareas["wavedata"][s].clone();
    // println!("{}",type_of(serviceareas["wavedata"][s].clone()))
    let out = wavedata.try_into::<WaveData>();
    out.expect("")

}
