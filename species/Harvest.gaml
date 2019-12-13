model Harvest

import '../models/Main.gaml'
import './Crop.gaml'

species Harvest {
	Crop crop;
	int current_days <- 0 update: current_days + 1;
	int current_stage <- 0 update: calculate_current_stage();
	bool has_changed_stage update: false;
	float current_water_demand
		update: calculate_water_demand();
	
	action calculate_current_stage type: int {
		int previous_stage <- current_stage;
		if current_days < crop.stage_change_days[0] {
			return 0;
		} else if current_days < crop.stage_change_days[1] {
			return 1;
		} else if current_days < crop.stage_change_days[2] {
			return 2;
		} else {
			return 3;
		}
		if (previous_stage != current_stage) {
			has_changed_stage <- true;
		}
	}
	
	action calculate_water_demand type: float {
		return max(evapotranspiration * crop.coefficient[current_stage] - daily_rain / 1000, 0.0);
	}
}
