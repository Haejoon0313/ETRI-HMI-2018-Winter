from PIL import Image, ImageChops
import numpy as np
import math

# global variable
PLANE_PIXELS = 13730.0
CHEEZIT_PIXELS = 48256.0
MUSTARD_PIXELS = 17467.0


im1 = Image.open("Data/180125/scene0/sample10/D2&G2/bathroom_2k.hdr/Animation_0105.png")
im2 = Image.open("Render/scene0/sample1280/D16&G16/bathroom_2k.hdr/Animation_0105.png")

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
    
    diff.save("Render/diff.png")
    
    for i in range(480):
        for j in range(640):
            if(diff_rgb[i][j][0:3].any() != 0):

                result0 += math.pow(diff_rgb[i][j][0] / 255.0, 2)
                result1 += math.pow(diff_rgb[i][j][1] / 255.0, 2)
                result2 += math.pow(diff_rgb[i][j][2] / 255.0, 2)

    result0 = math.sqrt(result0 / (480 * 640))
    result1 = math.sqrt(result1 / (480 * 640))
    result2 = math.sqrt(result2 / (480 * 640))

    result = (result0 + result1 + result2) / 3.0

    return result

success = image_diff(im1, im2)
print(success)