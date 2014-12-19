from http://publiclab.org/notes/cfastie/08-26-2014/new-ndvi-colormap :
1. The left half of the colormap has three gradients between black and white. This does not allow you to discern the value from the tone, but the values of NDVI below zero indicate zero photosynthesis, so we generally do not care exactly what the value is. The multiple gradients preserve the detail of non-plants in the NDVI image. It just makes the NDVI image easier to look at because you can recognize objects and textures that are not foliage.
2. The boundary between grayscale and color is not at zero. Live foliage generally does not have NDVI values below 0.1, so that is the boundary between grayscale and color. With this colormap, anything in grayscale is probably not a plant. This allows a more precise differentiation between plant and non-plant when the NDVI values are calibrated.
3. There is a narrow band of violet between 0.1 and 0.2 which could represent very low photosynthetic activity, but might also be noise or error.
4. The primary gradient of photosynthetic activity is from NDVI values from 0.2 to 0.9, and that is represented with a classic heat map from green to yellow to red. It's a little bit counter intuitive because green does not represent the healthiest plants, but the heat map metaphor seems to work well for most people.
5. The highest values (> 0.9) are colored magenta. Foliage generally does not have NDVI values this high, so this color represents non-plants. I did not make it a gray so it can be distinguished from low values. In many cases, DIY NDVI values above 0.9 are artifacts where the image is very dark or very bright. .

i.e.:
-1.0 black
0.0 white
0.1 violet
0.2 green
0.6 yellow
0.8 red
0.9 magenta
1.0 magenta
