use toml::Value;
use toml::map::Map;
use serde::Deserialize;
use std::any::type_name;

fn type_of<T>(_: T) -> &'static str {
    type_name::<T>()
}

#[derive(Debug, Deserialize)]
struct WaveData {
    h_s: f64,
    t_z: f64,
    t_sd: f64,
    h_x: f64,
}

impl WaveData {
    fn h_dw(&self) -> f64 {
        1.67 * self.h_s
    }
    fn t_dw(&self) -> f64 {
        self.t_z
    }
    fn t_dsd(&self) -> f64 {
        self.t_sd
    }
    fn t_drange(&self) -> (f64, f64) {
        (self.t_dw() - 2.0 * self.t_dsd(),self.t_dw() + 2.0 * self.t_dsd())
    }
    fn h_xw(&self) -> f64 {
        self.h_x
    }
    fn t_xw(&self) -> f64 {
        self.t_dw() + self.t_dsd()
    }
    fn t_xrange(&self) -> (f64, f64) {
        (self.t_xw() - 1.5 * self.t_dsd(),self.t_xw() + 1.5 * self.t_dsd())
    }
}

#[derive(Debug, Deserialize)]
struct ServiceFactors {
    f_1: f64,
    f_2: f64,
}
#[derive(Debug, Deserialize)]
struct ServiceArea {
    wave_data: WaveData,
    service_factors: ServiceFactors,
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

    let service_area = service_area_notation(input.clone());
    let s: &str = &service_area[1..service_area.len()-1]; // This is required to strip the quote marks around the notation. 
    let service_area = return_service_area_data(s);
    let l_wl = input["ship"]["L_wl"].as_integer().expect("");
    let f_sl = get_operational_factor(input.clone());
    let f_s = (service_area.service_factors.f_1 + service_area.service_factors.f_2*(l_wl as f64 - 100.0)/1000.0)*f_sl as f64;

    println!("Service area notation is: {}", &s);
    println!("Wave data for service area is:");
    println!("H_s: {}", service_area.wave_data.h_s);
    println!("T_z: {}", service_area.wave_data.t_z);
    println!("T_sd: {}", service_area.wave_data.t_sd);
    println!("H_x: {}", service_area.wave_data.h_x);
    println!("Design criteria for normal assessment:");
    println!("H_dw: {}", service_area.wave_data.h_dw());
    println!("T_dw: {}", service_area.wave_data.t_dw());
    println!("T_dsd: {}", service_area.wave_data.t_dsd());
    println!("T_drange: {:?}", service_area.wave_data.t_drange());
    println!("Design criteria for ESA assessment:");
    println!("H_xw: {}", service_area.wave_data.h_xw());
    println!("T_xw: {}", service_area.wave_data.t_xw());
    println!("T_xrange: {:?}", service_area.wave_data.t_xrange());
    println!("Service factors for service area are:");
    println!("f_1: {}", service_area.service_factors.f_1);
    println!("f_2: {}", service_area.service_factors.f_2);
    println!("F_s: {:.2}", (f_s*20.0).ceil()/20.0) // F_s should be rounded up to nearest 0.05, minmax [0.5, 1.0]
}

fn get_operational_factor(input: Map<String, Value>) -> f64 {
    let op_life = input["ship"]["operational_life"].as_integer().expect("");
    let f_sl =
        if op_life == 20 {
            1.0
        } else if op_life == 25 {
            1.01
        } else if op_life == 30 {
            1.019
        } else { 
            1.0 
        };
        f_sl
}

fn service_area_notation(input: Map<String, Value>) -> String {
    let service_area: String = input["servicearea"]["service_area"].to_string();
    service_area
}

fn get_wave_data(serviceareas: &Map<String, Value>, s: &str) -> WaveData {
    let wavedata = serviceareas["wavedata"][s].clone();
    let out = wavedata.try_into::<WaveData>();
    out.expect("")
}

fn get_service_factors(serviceareas: &Map<String, Value>, s: &str) -> ServiceFactors {
    let factors = serviceareas["factors"][s].clone();
    let out = factors.try_into::<ServiceFactors>();
    out.expect("")
}

fn return_service_area_data(s: &str) -> ServiceArea {
    let path = std::path::Path::new("src/serviceareas.toml");
    let file = match std::fs::read_to_string(path) {
        Ok(f) => f,
        Err(e) => panic!("{}", e),
    };
    let serviceareas: Map<String,Value> = file.parse::<Value>().ok().and_then(|r| match r {
        Value::Table(table) => Some(table),
        _ => None
    }).unwrap_or(Map::new());
    let a = get_wave_data(&serviceareas, s);
    let b = get_service_factors(&serviceareas, s);
    let c = ServiceArea{wave_data: a, service_factors: b};
    c
}