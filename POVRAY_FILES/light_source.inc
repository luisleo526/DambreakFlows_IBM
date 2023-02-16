#declare ss=sky_sphere{
 pigment{ gradient <0,1,1>
          color_map{   
            [0.2 color Gray10  ]
            [0.25 color Gray40 ] 
            [0.35 color Gray60 ]
            [0.4 color  Gray90  ]
                   } // end color_map
     scale 3
     rotate <0,60,30>
     translate <60,800,0>
 } 
} 


sky_sphere{ss}            

light_source{
    <-5,3,5> 
    color Yellow
    spotlight    
    point_at <3, 0.5, 0>
}    



light_source{
    <5,-2,5> 
    color White
    spotlight    
    point_at <7, 0.5, 0>
}    