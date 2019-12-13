model WaterSource

import '../models/Main.gaml'

species WaterSource {
	float daily_supply; //dayly limit to withdraw (Q95 of the day)
	float daily_demand update: calculate_daily_demand();
	float total_demand update: total_demand + daily_demand;
	matrix flow_data;
	list<Field> irrigated_fields;
	action calculate_daily_demand type: float {
		if (irrigated_fields = nil) { return 0; }
		return sum(collect(irrigated_fields, each.water_demand));
	}
	reflex calculate_daily_supply {
		float monthly_flow <- flow_data[1, month_of_year] as float;
		daily_supply <- monthly_flow * shape.area * 0.0864 * water_multiplier;
	}
}

species CorregoRato parent: WaterSource {
	geometry shape <- shape_file('../includes/shapes/cor_rato.shp') as geometry;
	matrix flow_data <- csv_file('../includes/data/flow_rato.csv') as matrix;
	aspect {
		draw shape color: #lightgreen border: #black;
	}
}

species SamambaiaNorte parent: WaterSource {
	geometry shape <- shape_file('../includes/shapes/sam_norte.shp') as geometry;
	matrix flow_data <- csv_file('../includes/data/flow_norte.csv') as matrix;
	aspect {
		draw shape color: #lightyellow border: #black;
	}
}

species SamambaiaSul parent: WaterSource {
	geometry shape <- shape_file('../includes/shapes/sam_sul.shp') as geometry;
	matrix flow_data <- csv_file('../includes/data/flow_sul.csv') as matrix;
	aspect {
		draw shape color: #lightblue border: #black;
	}
}