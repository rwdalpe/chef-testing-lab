name 'server'
description 'An example role for the lab'
run_list "recipe[time_wrapper::timezone]", "recipe[time_wrapper::ntp]"