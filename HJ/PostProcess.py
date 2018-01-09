import csv
import ctypes

# open time data txt -> parsing
def time_parse(data_path):
    
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


# create csv file as arranged data
def createCSV(data):
    
    f = open("Render/Airplane/data.csv",'w')
    csvWriter = csv.writer(f)
    
    csvWriter.writerow(["Device", "Resolution", "Samples", "Tile Size", "Diffuse Bounces", "Glossy Bounces", "Frame", "Time"])
    
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
    
    data = open("Render/Airplane/time_calculate.txt",'r')
    
    D_lines = data.readlines()
    
    for d in D_lines:
        temp = d.strip("\n")
        result.append(str(temp)+" (s)")
    
    data.close()
    
    return result


# combine two types of data into one
def combine_data(oData, tData):
    
    print("\nOptions: "+str(len(oData)))
    print("Time: "+str(len(tData)))
    
    if(len(oData) != len(tData)):
        return False
    
    result = oData
    
    for i in range(len(oData)):
        
        result[i].append(tData[i])
    
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

# font information
STD_INPUT_HANDLE   = -10
STD_OUTPUT_HANDLE  = -11
STD_ERROR_HANDLE   = -12

std_out_handle = ctypes.windll.kernel32.GetStdHandle(STD_OUTPUT_HANDLE)


# black 0/blue 1/green 2/red 4/yellow 14/white 7
def set_color(color, handle=std_out_handle):
    bool = ctypes.windll.kernel32.SetConsoleTextAttribute(handle, color)
    return bool


# main function (cal)
print("\n------------------------------------Post processing START------------------------------------\n\n")

result_parse = time_parse("Render/Airplane/time_data.txt")

start_time = result_parse[0]
end_time = result_parse[1]

success1 = time_subtract_loop(start_time, end_time, "Render/Airplane/time_calculate.txt")

if(success1):
    print("Time calculation is Done.\n")
else:
    set_color(4)
    print("Calculation Error!\n")
    set_color(7)


# main function (csv)
options_list = options_input()

option_table = data_from_options(options_list)
time_table = data_from_time()

result_table = combine_data(option_table, time_table)

if(result_table == False):
    set_color(14)
    print("\nDismatch between options and time!\n")
    set_color(7)
else:
    success2 = createCSV(result_table)
    if(success2):
        print("\nCreating CSV file is Done.\n")
    else:
        set_color(4)
        print("\nCreate CSV file Error!\n")
        set_color(7)

print("\n------------------------------------Post processing END------------------------------------\n\n")
raw_input("Press Enter to Exit")