  



#declare top_view = camera {

	perspective

	location <3.25, 0.5, 4.50000000>

	sky <0.000000, 0.000000, 1.000000>

	right <-1, 0, 0>

	angle 60.000000

	look_at <3.2500000, 0.500000, 0.00000>

}

#declare side_view=camera {

	perspective

	location <2.500000, -5.5, 3.000000>

	sky <0.000000, 0.000000, 1.000000>

	right <-1, 0, 0>

	angle 45.000000

	look_at <2.500000, 0.000000, 1.000000>

}                

camera{side_view}
