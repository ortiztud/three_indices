# Experiment 1a

_pending_

# Experiment 1b

_pending_

# Experiment 2

_pending_

# Experiment 3

_pending_

# Joint analysis (all experiments)
- Detection accuracy: 		`cd_acc ~ congruity + (congruity | sub_code) + (congruity | obj_file) 	-> Chisq(1) = 15.787, p= 7.09e-05`
- Detection speed: 			`cd_rt ~ congruity + (1 | sub_code) + (congruity | obj_file) 			-> Chisq(1) = 45.91  p = 1.238e-11`
- Identification accuracy: 	`id_acc ~ congruity + (congruity | sub_code) + (congruity | obj_file) 	-> Chisq(1) = 14.762, p = 0.000122`
- Recognition accuracy: 	`rec_acc ~ congruity + (1 | sub_code) + (1 | obj_file) 					-> Chisq(1) = 10.499, p = 0.001194`

# Interpretation of the significance of model components
Fun table to play around (to satisfy some undiagnosed OCD)

| Fixed effect | IV impact on participants as random effect | IV impact on objects as random effect | Found it? | Interpretation |
| ------ | ------ | ------ | ------ |
| no | yes | yes | no | There is no overall effect of IV as there is too much variability in how DV is affected by IV between participants and objects |
| yes | no | yes | Exp3 | xxxxx |
| yes | yes | no | xxxxx | xxxxx |
| no | no | yes | xxxxx | xxxxx |
| no | yes | no | xxxxx | xxxxx |
| no | no | yes | Exp1a | xxxxx |
| no | no | no | xxxxx | ...well |
