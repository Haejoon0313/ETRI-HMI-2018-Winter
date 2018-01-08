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
    
    return str(time[0]) + ":" + str(time[1]) + ":" + str(time[2])


# make str list into float time list -> [float, float, float]
def unpack_time(time):
    
    real_time = []
    time = time.split(':')
    
    for t in time:
        real_time.append(float(t))
        
    return real_time


# main function

result_parse = time_parse("Render/Airplane/time_data.txt")

start_time = result_parse[0]
end_time = result_parse[1]

success = time_subtract_loop(start_time, end_time, "Render/Airplane/time_calculate.txt")

print(success)
