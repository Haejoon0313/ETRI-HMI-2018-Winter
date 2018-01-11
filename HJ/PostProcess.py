import csv
import ctypes
import os
import sys
import math
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image, ImageChops


# global variable
WORK_PATH = "Render/Airplane/"
PLANE_PIXELS = 39105.0
OPTIONS = 3
ENV_FOLDER = ["balcony_2k.hdr", "bathroom_2k.hdr", "bergen_2k.hdr", "blinds_2k.hdr", "brick_lounge_2k.hdr", "cabin_2k.hdr", 
              "courtyard_2k.hdr", "courtyard_night_2k.hdr", "delta_2k.hdr", "fish_eagle_hill_2k.hdr", "garage_2k.hdr", "golden_gate_2k.hdr", 
              "lapa_2k.hdr", "leafy_knoll_2k.hdr", "northcliff_2k.hdr", "oribi_2k.hdr", "parking_lot_2k.hdr", "st_lucia_beach_2k.hdr", "st_lucia_interior_2k.hdr"]


# font information
STD_INPUT_HANDLE   = -10
STD_OUTPUT_HANDLE  = -11
STD_ERROR_HANDLE   = -12

std_out_handle = ctypes.windll.kernel32.GetStdHandle(STD_OUTPUT_HANDLE)


# open time data txt -> parsing
def time_parse(data_path):
    
    if(os.path.exists(data_path) == False):
        return False
    
    data = open(data_path,'r')
    D_lines = data.readlines()
    
    start_time = []
    end_time = []
    
    for index in range(len(D_lines)):
        if(D_lines[index].find("start object") != -1):
            start_time.append(D_lines[index+1].rsplit(" ")[1].strip("\n")) # if find start flag, only save time
        if(D_lines[index].find("end object") != -1):
            end_time.append(D_lines[index-1].rsplit(" ")[1].strip("\n")) # if find end flag, only save time
    
    data.close()
    
    return [start_time, end_time]


# time subtract between start time & end time -> save as txt file
def time_subtract_loop(start, end, result_path):
    
    result = open(result_path, 'w')
    
    if(len(start) != len(end)):
        return False
    
    sub_num = len(start)
    
    for i in range(sub_num):
        start_time = unpack_time(start[i])
        end_time = unpack_time(end[i])
        
        play_time = time_subtract(start_time, end_time)
        
        result.write(pack_time(play_time))
        result.write("\n")
    
    result.close()
    
    return True


# calculate subtraction
def time_subtract(start_time, end_time):
    
    sub_result_time = []
    
    if(start_time[0] > end_time[0]):
        end_time[0] += 24.0
    
    for i in reversed(range(3)):
        if(end_time[i] >= start_time[i]):
            temp = end_time[i] - start_time[i]
        else:
            temp = end_time[i] + 60.0 - start_time[i] # borrow
            end_time[i-1] = end_time[i-1] - 1
        
        if(i == 2):
            temp = float(temp) # second
        else:
            temp = int(temp) # hour or minute
        
        sub_result_time.insert(0, temp)
    
    return sub_result_time


# make float and int list into str time -> "int:int:float"
def pack_time(time):
    
    minute = time[0] * 60 + time[1]
    
    return str(minute) + " : " + str(time[2])


# make str list into float time list -> [float, float, float]
def unpack_time(time):
    
    real_time = []
    time = time.split(':')
    
    for t in time:
        real_time.append(float(t))
        
    return real_time


# save diff image as png then return diff / pixels
def image_diff(x, ref):
    
    image_x = Image.open(x + "AirPlane_0131.png")
    image_ref = Image.open(ref)
    
    result0 = 0.0
    result1 = 0.0
    result2 = 0.0
    
    point_table = ([0] + ([255] * 255))
    
    diff = ImageChops.difference(image_x, image_ref)
    diff_rgb = np.array(diff)
    
    diff = diff.convert('L')
    diff = diff.point(point_table)
    
    diff.save(x + "diff.png")

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


# create csv file as arranged data
def createCSV(data):
    
    f = open(WORK_PATH + "data.csv",'w')
    csvWriter = csv.writer(f)
    
    csvWriter.writerow(["Device", "Resolution", "Samples", "Tile Size", "Diffuse Bounces", "Glossy Bounces", "Frame", "Time", "ImageDiff"])
    
    for d in data:
        csvWriter.writerow(d)
    
    f.close()
    
    return True


# change options into data table
def data_from_options(options):
    
    result = []
    
    for i0 in options[0]:
        for i1 in options[1]:
            for i2 in options[2]:
                for i3 in options[3]:
                    for i4 in options[4]:
                        for i5 in options[5]:
                            for i6 in options[6]:
                                
                                temp = [i0, i1, i2, i3, i4, i5, i6]
                                result.append(temp)
    
    return result


# change time txt file into data table
def data_from_time():
    
    result = []
    
    data = open(WORK_PATH + "time_calculate.txt",'r')
    
    D_lines = data.readlines()
    
    for d in D_lines:
        temp = d.strip("\n")
        result.append(str(temp)+" (s)")
    
    data.close()
    
    return result


# search through folder for return image different
def data_from_diff(options_list):
    
    print("\n")
    
    diff_option_list = []
    result = []
    diff_len = 1.0
    
    for o in options_list:
        if(len(o) > 1):
            diff_option_list.append(o)
    
    for i in range(3):
        diff_len = diff_len * len(diff_option_list[i])
    
    diff_len = diff_len * 19
    flag = 0.0
    
    for i0 in diff_option_list[0]:
        for i1 in diff_option_list[1]:
            for i2 in diff_option_list[2]:
                
                result_temp = 0.0
                
                for i3 in ENV_FOLDER:
                    
                    print("\rImage Difference Processing...   " + str(int(flag)) + "/" + str(int(diff_len)) + "  (" + str(round(flag*100.0/diff_len, 2)) + " %)"),
                    
                    temp = image_diff(WORK_PATH + "sample" + i0 + "/D" + i1 + "&G" + i2 + "/" + i3 + "/", "Data/Reference/100/" + i3 + "/AirPlane_0131.png")
                    result_temp += temp
                    
                    flag += 1.0
                
                result.append(str(temp))
    
    return result


# combine 3 data into one
def combine_data(oData, tData, dData):
    
    print("Options: "+str(len(oData)))
    print("Time: "+str(len(tData)))
    print("Difference: "+str(len(dData)))
    
    if(len(oData) != len(tData)):
        return False
    
    if(len(oData) != len(dData)):
        return True
    
    result = oData
    
    for i in range(len(oData)):
        
        result[i].append(tData[i])
        result[i].append(dData[i])
    
    return result


# input each options type
def options_input():
    
    result = []
    
    temp1 = raw_input("Device?   ").split(" ") # CPU or GPU
    result.append(temp1)
    
    temp2 = raw_input("Resolution?   ").split(" ") # resoltion set
    result.append(temp2)
    
    temp3 = raw_input("Samples?   ").split(" ") # rendering sample set
    result.append(temp3)    
    
    temp4 = raw_input("Tile Size?   ").split(" ") # tile size set (x&y same)
    result.append(temp4)    
    
    temp5 = raw_input("Diffuse Bounces?   ").split(" ") # diffuse bounces set
    result.append(temp5)
    
    temp6 = raw_input("Glossy Bounces?   ").split(" ") # glossy bounces set
    result.append(temp6)
    
    temp7 = raw_input("Frame?   ").split(" ") # number of frames
    result.append(temp7)
    
    return result


# black 0/blue 1/green 2/red 12/yellow 14/white 7
def set_color(color, handle=std_out_handle):
    bool = ctypes.windll.kernel32.SetConsoleTextAttribute(handle, color)
    return bool


# read csv file then draw graph for each
def draw_graph(data, save_path):
    
    return True
 

# main function
def main():
    
    # time calculation function
    result_parse = time_parse(WORK_PATH + "time_data.txt")
    
    if(result_parse == False):
        set_color(14)
        print("No Time Data File!\n")
        set_color(7)
        
        return False
    
    print("Data file is found.\n")
    
    start_time = result_parse[0]
    end_time = result_parse[1]
    
    success1 = time_subtract_loop(start_time, end_time, WORK_PATH + "time_calculate.txt")    

    if(success1 == False):
        set_color(12)
        print("Calculation Error!\n")
        set_color(7)
    
        return False
    
    print("Time calculation is Done.\n")
    
    
    # data create function
    options_list = options_input()
    
    option_table = data_from_options(options_list)
    time_table = data_from_time()
    diff_table = data_from_diff(options_list)
    
    if(diff_table == False):
        
        set_color(12)
        print("Image difference Error!\n")
        set_color(7)
        
        return False
    
    print("\nImage comparsion is Done.\n")
    
    
    # data combination & csv file function
    result_table = combine_data(option_table, time_table, diff_table)
    
    if(result_table == False):
        
        set_color(14)
        print("\nDismatch between options and time!\n")
        set_color(7)
        
        return False
    
    if(result_table == True):
        
        set_color(14)
        print("\nDismatch between options and image difference!\n")
        set_color(7)
        
        return False    
    
    success2 = createCSV(result_table)
    
    if(success2 == False):
        set_color(12)
        print("\nCreate CSV file Error!\n")
        set_color(7)
        
        return False
    
    print("\nCreating CSV file is Done.\n")      
    
    
    # graph function
    success3 = draw_graph(result_table, WORK_PATH + "scatter_graph.png")
    
    if(success3 == False):
        set_color(12)
        print("\nGraph drawing Error!\n")
        set_color(7)
        
        return False
    
    print("\nGraph drawing is Done.\n")    
    
    # finish
    return True


# process
print("\n------------------------------------Post processing START------------------------------------\n\n")
main()
print("\n------------------------------------Post processing END--------------------------------------\n\n")
raw_input("Press Enter to Exit")

