use csv; // 1.0.5

static CSV_FILE: &[u8] = include_bytes!("/wddata.csv");

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut rdr = csv::ReaderBuilder::new()
        .delimiter(b'\t')
        .from_reader(CSV_FILE);

    for result in rdr.records() {
        let record = result?;
        println!("{:?}", record);
    }

    Ok(())
}