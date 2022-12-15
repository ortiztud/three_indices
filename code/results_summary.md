# Joint analysis (all experiments)
- Detection accuracy: 		`cd_acc ~ congruity + (congruity | sub_code) + (congruity | obj_file) 	-> Chisq(1) = 15.787, p= 7.09e-05`
- Detection speed: 			`cd_rt ~ congruity + (1 | sub_code) + (congruity | obj_file) 			-> Chisq(1) = 45.91  p = 1.238e-11`
- Identification accuracy: 	`id_acc ~ congruity + (congruity | sub_code) + (congruity | obj_file) 	-> Chisq(1) = 14.762, p = 0.000122`
- Recognition accuracy: 	`rec_acc ~ congruity + (1 | sub_code) + (1 | obj_file) 					-> Chisq(1) = 10.499, p = 0.001194`
