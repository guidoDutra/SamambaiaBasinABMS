model Basin

import '../species/Crop.gaml'
import '../species/Field.gaml'

global {
//	geometry shape;
	geometry shape <- shape_file("../includes/shapes/bacia_samambaia.shp") as geometry; //delimitating simulation area
	float step <- 1 #day;
	
	float pumping_cost <- 0.0002;
	
	list<Crop> crops;
	list<WaterSource> water_sources;

	float daily_water_demand update: calculate_daily_water_demand();
	float total_water_demand update: total_water_demand + daily_water_demand;
	
	int year_count update: floor(cycle / 360) as int;
	int month_count <- 0 update: floor(cycle / 30) as int;
	int month_of_year <- 1 update: mod(month_count + 1, 12); // 1 to 12

	list<float> total_production <- list_with(9, 0.0);
	list<float> total_revenue <- list_with(9, 0.0);
	
	action calculate_daily_water_demand type: float {
		return sum(collect(water_sources, each.daily_demand));
	}
	
	float price_tolerance_base <- 0.05;
	float price_tolerance_per_field <- 0.005;
	
	float water_multiplier <- 1.0;

	matrix monthly_prices <- csv_file("../includes/data/monthly_prices.csv") as matrix;
	
	matrix daily_weather <- csv_file("../includes/data/daily_weather.csv") as matrix;
	matrix monthly_weather <- csv_file("../includes/data/monthly_weather.csv") as matrix;

	float max_temp update: daily_weather[2, cycle] as float;
	float min_temp update: daily_weather[3, cycle] as float;
	
	float daily_rain update: daily_weather[1, cycle] as float;

	float evapotranspiration update: calculate_evapotranspiration();

	action calculate_evapotranspiration type: float {
		return 0.00017136 * (max_temp - min_temp) ^ (0.96) * (((max_temp + min_temp) / 2) + 17.38);
	}

	init {
		create Soy;
		create Cotton;
		create Corn;
		create Bean;
		create Potato;
		create Garlic;
		create Onion;
		create Tomato;
		add Soy[0] to: crops;
		add Corn[0] to: crops;
		add Cotton[0] to: crops;
		add Bean[0] to: crops;
		add Potato[0] to: crops;
		add Garlic[0] to: crops;
		add Onion[0] to: crops;
		add Tomato[0] to: crops;

		create CorregoRato;
		create SamambaiaNorte;
		create SamambaiaSul;
		add CorregoRato[0] to: water_sources;
		add SamambaiaNorte[0] to: water_sources;
		add SamambaiaSul[0] to: water_sources;
		
		create Field from: shape_file("../includes/shapes/pivos_bacia_2016.shp");

		// relate fields to water sources
		loop field over: Field {
			loop water_source over: water_sources {
				if (water_source overlaps field) {
					field.water_source <- water_source;
					add field to: water_source.irrigated_fields;
				}
			}
		}
		
		create Farmer number: 2 { // farmers in samambaia sul
			number_of_fields <- 50;
			price_tolerance <- price_tolerance_base + number_of_fields * price_tolerance_per_field;
			location <- any_location_in(4000 around Field(118));
		}
		create Farmer number: 5 { // farmers in samambaia norte
			number_of_fields <- 30;
			price_tolerance <- price_tolerance_base + number_of_fields * price_tolerance_per_field;
			location <- any_location_in(4000 around Field(9));
		}
		create Farmer number: 3 { // farmers in corrego do rato
			number_of_fields <- 10;
			price_tolerance <- price_tolerance_base + number_of_fields * price_tolerance_per_field;
			location <- any_location_in(4000 around Field(246));
		}
		
		// relate farmers to fields
		loop farmer over: Farmer {
			list<Field> empty_fields <- Field where (each.farmer = nil);
			farmer.fields <- empty_fields closest_to (farmer, farmer.number_of_fields);
			loop field over: farmer.fields {
				field.farmer <- farmer;
			}
		}
	}

	reflex end_simulation when: cycle = 1320 { //pause simulation after 10 years
//		save [total_av_water, total_dem_water, total_cash] to: "../results/total_result.csv" type: "csv" rewrite: false;
//		ask farmerA {
//			save [name, my_area, total_water_demand, cash] to: "../results/each_result.csv" type: "csv" rewrite: false;
//		}
//
//		ask farmerB {
//			save [name, my_area, total_water_demand, cash] to: "../results/each_result.csv" type: "csv" rewrite: false;
//		}
//
//		ask farmerC {
//			save [name, my_area, total_water_demand, cash] to: "../results/each_result.csv" type: "csv" rewrite: false;
//		}

		do pause;
	}
}
