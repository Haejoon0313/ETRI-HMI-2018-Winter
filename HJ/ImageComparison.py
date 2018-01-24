from PIL import Image, ImageChops
import numpy as np
import math

# global variable
PLANE_PIXELS = 13730.0
CHEEZIT_PIXELS = 48256.0
MUSTARD_PIXELS = 17467.0


im1 = Image.open("Render/scene0/sample20/D16&G16/bathroom_2k.hdr/Diffuse_0105.png")
im2 = Image.open("Render/scene0/sample20/D16&G16/bathroom_2k.hdr/Principled_0105.png")

# image difference loop
def image_diff_loop():
    pass


# save diff image as png then return diff / pixels
def image_diff(a, b):
    
    result0 = 0.0
    result1 = 0.0
    result2 = 0.0
    temp = 0
    temp2 = 0
    point_table = ([0] + ([255] * 255))
    
    diff = ImageChops.difference(a, b)
    diff_rgb = np.array(diff)
    
    diff = diff.convert('L')
    diff = diff.point(point_table)
    
    diff.save("Render/scene0/sample20/D16&G16/bathroom_2k.hdr/diff.png")
    
    for i in range(480):
        for j in range(640):
            if(diff_rgb[i][j][0:3].any() != 0):
                
                temp +=1
              
                result0 += math.pow(diff_rgb[i][j][0] / 255.0, 2)
                result1 += math.pow(diff_rgb[i][j][1] / 255.0, 2)
                result2 += math.pow(diff_rgb[i][j][2] / 255.0, 2)
                
            else:
                
                temp2 += 1
    
    
    result = (result0 + result1 + result2) / 3.0
    
    print(temp)
    print(temp2)
    print(temp + temp2)
    print(480*640)
    
    return result

success = image_diff(im1, im2)
print(success)