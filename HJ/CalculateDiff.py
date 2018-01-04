# -*- coding: cp949 -*-
from PIL import Image
from PIL import ImageChops

def compare_images(path_one, path_two, diff_save_location):
    """
    Compares to images and saves a diff image, if there
    is a difference
 
    @param: path_one: The path to the first image
    @param: path_two: The path to the second image
    """
    image_one = Image.open(path_one)
    image_two = Image.open(path_two)
 
    diff = ImageChops.difference(image_one, image_two)
 
    if diff.getbbox():
        diff.save(diff_save_location)
 
 
compare_images('C:\\Users\\sam96\\Desktop\\문서\\Data\\180103\\CPU\\balcony_2k.hdr\\20\\dddd.png',
               'C:\\Users\\sam96\\Desktop\\문서\\Data\\180103\\GPU\\balcony_2k.hdr\\20\\RGB_0001.png',
               'C:\\Users\\sam96\\Desktop\\문서\\Data\\diff.png')


