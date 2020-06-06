#version 3.7;

#include "functions.inc"

// Background color to black for what's outside the field of view of
// the camera
background { color rgb 0.0 }

// Seed for the random generators
#declare seedAll = seed(clock);

// Random generator for each component of the scene
#declare seedStars = seed(rand(seedAll) * 1000);
#declare seedMilkyway = seed(rand(seedAll) * 1000);
#declare seedSunset = seed(rand(seedAll) * 1000);
#declare seedMountains = seed(rand(seedAll) * 1000);
#declare seedShootingstar = seed(rand(seedAll) * 1000);
#declare seedGrass = seed(rand(seedAll) * 1000);

// Standard fisheye camera looking upward (y-axis) with x-axis as right
camera {
  fisheye
  location 0.0
  look_at y
  up y
  right x
  sky z
  angle 180.0
}

// Skysphere to setup a not-completely-black background color of what's
// inside the field of view of the camera
sky_sphere {
  pigment { color 0.001 }
}

// Stars
#declare stars = union {
  #local nbStars = 5000 * (1.0 + 9.0 * rand(seedStars));
  #local iStar = 0;
  #while (iStar < nbStars)
    sphere {
      // Uniformly distributed position the sphere
      #local theta = 360.0 * rand(seedStars);
      #local phi = acos(1.0 - 2.0 * rand(seedStars));
      #local pos = <sin(phi) * cos(theta), sin(phi) * sin(theta), cos(phi)>;
      #local radiusStar = rand(seedStars) * 2.0;
      pos * 1000.0 * (0.5 + rand(seedStars)), radiusStar
      #local strengthStar = rand(seedStars);
      #local rgbStar = <rand(seedStars), rand(seedStars), rand(seedStars)>;
      texture {
        pigment { color rgb rgbStar }
        finish { ambient strengthStar }
      }
    }
    #declare iStar = iStar + 1;
  #end
}

object { stars }

// Milky way
#declare smoothstep = function(_v) {
  3.0 * pow(_v, 2.0) - 2.0 * pow(_v, 3.0)
}
#local minRadius = 40.0 * (1.0  + 0.5 * rand(seedMilkyway));
#local majRadius = 100.0;
#declare MilkywayPatternA = function {
  smoothstep(f_torus(x, y, z, 1.0, minRadius / majRadius) * f_bozo(x, y, z))
}
#declare MilkywayPatternB = function {
  #local coeff = 10.0;
  smoothstep(f_torus(x, y, z, 1.0, minRadius / majRadius) *
    f_bozo(x * coeff, y * coeff, z * coeff))
}
#declare milkyway = union {
  torus {
    1.0, minRadius / majRadius
    hollow
    texture {
      pigment {color rgbt 1.0}
    }
    interior {
      media {
        emission 0.05 * <rand(seedMilkyway), rand(seedMilkyway), rand(seedMilkyway)>
        density {
          function {MilkywayPatternA(x, y, z)}
          color_map {
            [0.0  rgb 0]
            [0.1  rgb 0]
            [0.25 rgb 0.1]
            [0.5  rgb 1]
            [0.75 rgb 0.1]
            [0.9  rgb 0]
            [1.0  rgb 0]
          }
          turbulence 0.2
        }
      }
    }
    rotate y * rand(seedMilkyway) * 180.0
  }
  torus {
    1.0, minRadius / majRadius + 0.001
    hollow
    texture {
      pigment {color rgbt 1.0}
    }
    interior {
      media {
        absorption 0.5
        density {
          function {MilkywayPatternB(x, y, z)}
          color_map {
            [0.0  rgb 0]
            [0.1  rgb 0]
            [0.25 rgb 0.8]
            [0.5  rgb 1]
            [0.75 rgb 0.8]
            [0.9  rgb 0]
            [1.0  rgb 0]
          }
          turbulence 0.2
        }
      }
    }
    rotate y * rand(seedMilkyway) * 180.0
  }
  rotate x * rand(seedMilkyway) * 180.0
  rotate z * rand(seedMilkyway) * 180.0
  scale majRadius
}
object { milkyway }

// Sunset/Sunrise
sphere {
  0.0, 1.0
  hollow
  texture {
    pigment {
      gradient y
      color_map {
        [0.0    rgbt <0.0, 0.0, 0.0, 1.0>]
        [0.25   rgbt <0.0, 0.0, 0.0, 1.0>]
        [0.85   rgbt <0.1, 0.1, 0.5, 0.5>]
        [0.999  rgbt <1.0, 0.0, 0.0, 0.15>]
        [0.9995 rgbt <0.8, 0.8, 0.0, 0.1>]
        [1.0    rgbt <3.0, 3.0, 3.0, 0.0>]
      }
      scale 2.0
      translate -y
    }
    finish {
      diffuse 1.0
    }
  }
  scale majRadius - minRadius - 1.0
  rotate x * (90.0 + rand(seedSunset) * 90.0)
  rotate y * rand(seedSunset) * 360.0
}

// Mountains
#declare Mountains = function {
  #local _coeff = rand(seedMountains) * 20.0;
  #local _shiftX = rand(seedMountains);
  #local _shiftY = rand(seedMountains);
  #local _shiftZ = rand(seedMountains);
  #local _d = sqrt(pow(0.5 - x.x, 2.0) + pow(0.5 - y.y, 2.0) + pow(0.5 - z.z, 2.0));
  f_bozo(x + _shiftX, y + _shiftY, z + _shiftZ) *
    pow(_d, 4.0) * pow(f_bozo(x * _coeff, y * _coeff, z * _coeff), 2.0)
}
#declare mountains = difference {
  height_field {
    function 100, 100 { Mountains(x, y, z) }
    translate <-0.5, 0.0, -0.5>
    rotate y * rand(seedMountains) * 360.0
    scale <50.0, 10.0, 50.0>
    texture {
      pigment { rgb 0.0 }
      finish { ambient 0.0 }
    }
  }
  cylinder {
    -y * 10.0, y * 10.0, 10.0
  }
}
object{ mountains }

// Shooting star
#if (rand(seedAll) < 0.1)
  cylinder {
    #local length = (15.0 + 10.0 * rand(seedShootingstar));
    0.0, x * length, 1.0
    texture {
      pigment { 
        gradient x
        color_map {
          [0.0 rgbt <1.0, 1.0, 1.0, 0.0>]
          [0.1 rgbt <1.0, 1.0, 1.0, 0.0>]
          [0.9 rgbt <0.0, 0.0, 0.0, 1.0>]
          [1.0 rgbt <0.0, 0.0, 0.0, 1.0>]
        }
        turbulence 0.2
      }
      finish { ambient 1.0 }
      scale length
    }
    scale <1.0, 0.15, 0.15>
    translate y * (majRadius - minRadius - 2.0)
    rotate y * 360.0 * rand(seedShootingstar)
    rotate z * (-45.0 + 90.0 * rand(seedShootingstar))
    rotate x * (-45.0 + 90.0 * rand(seedShootingstar))
  }
#end

// Grass
#macro GrassPatch(_u, _v, _w, _c)
  <_w * (-1.0 + _u * 2.0) * (1.0 - _v), sin(_v * 3.14159 * (0.4 + 0.4 * _c)), _v>
#end

#declare nbGrass = rand(seedGrass) * 1000;
#declare grass = union {
  #declare iGrass = 0;
  #while(iGrass < nbGrass)
    bicubic_patch {
      type 1
      u_steps 4
      v_steps 4
      #local _w = 0.01;
      #local _c = rand(seedGrass);
      GrassPatch(0.0      , 0.0      , _w, _c),
      GrassPatch(1.0 / 3.0, 0.0      , _w, _c),
      GrassPatch(2.0 / 3.0, 0.0      , _w, _c),
      GrassPatch(1.0      , 0.0      , _w, _c)
      GrassPatch(0.0      , 1.0 / 3.0, _w, _c),
      GrassPatch(1.0 / 3.0, 1.0 / 3.0, _w, _c),
      GrassPatch(2.0 / 3.0, 1.0 / 3.0, _w, _c),
      GrassPatch(1.0      , 1.0 / 3.0, _w, _c)
      GrassPatch(0.0      , 2.0 / 3.0, _w, _c),
      GrassPatch(1.0 / 3.0, 2.0 / 3.0, _w, _c),
      GrassPatch(2.0 / 3.0, 2.0 / 3.0, _w, _c),
      GrassPatch(1.0      , 2.0 / 3.0, _w, _c)
      GrassPatch(0.0      , 1.0      , _w, _c),
      GrassPatch(1.0 / 3.0, 1.0      , _w, _c),
      GrassPatch(2.0 / 3.0, 1.0      , _w, _c),
      GrassPatch(1.0      , 1.0      , _w, _c)
      texture {
        pigment {
          color rgb 0.0
        }
      }
      rotate y * rand(seedGrass) * 360.0
      scale <1.0, 1.0 + rand(seedGrass), 1.0>
      translate <20.0 * (rand(seedGrass) - 0.5), 0.0, 20.0 * (rand(seedGrass) - 0.5)>
    }
    #declare iGrass = iGrass + 1;
  #end
};

object { grass }
