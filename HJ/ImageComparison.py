from PIL import Image, ImageChops
import numpy as np
import math

# global variable
WORK_PATH = "Render/Airplane/"
PLANE_PIXELS = 39105.0

im1 = Image.open("Render/Airplane/sample10/D2&G2/balcony_2k.hdr/AirPlane_0131.png")
im2 = Image.open("Render/Airplane/sample1280/D16&G16/balcony_2k.hdr/AirPlane_0131.png")

# image difference loop
def image_diff_loop():
    pass


# save diff image as png then return diff / pixels
def image_diff(a, b):
    
    result0 = 0.0
    result1 = 0.0
    result2 = 0.0
    
    point_table = ([0] + ([255] * 255))
    
    diff = ImageChops.difference(a, b)
    diff_rgb = np.array(diff)
    
    diff = diff.convert('L')
    diff = diff.point(point_table)
    
    diff.save(WORK_PATH + "diff.png")

    for i in range(480):
        for j in range(640):
            if(diff_rgb[i][j].all() != 0):
              
                result0 += math.pow(diff_rgb[i][j][0], 2)
                result1 += math.pow(diff_rgb[i][j][1], 2)
                result2 += math.pow(diff_rgb[i][j][2], 2)
    
    result0 = math.sqrt(result0 / (PLANE_PIXELS * 255))
    result1 = math.sqrt(result1 / (PLANE_PIXELS * 255))
    result2 = math.sqrt(result2 / (PLANE_PIXELS * 255))
    
    result = (result0 + result1 + result2) / 3.0
    
    return result

success = image_diff(im1, im2)
print(success)