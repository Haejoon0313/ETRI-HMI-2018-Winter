import csv

# create csv file as arranged data
def createCSV(data):
    
    f = open("Render/Airplane/data.csv",'w')
    csvWriter = csv.writer(f)
    
    csvWriter.writerow(["Device", "Threads Mode", "Tile Size", "Resolution", "Samples", "Diffuse Bounces", "Glossy Bounces", "Frame", "Time"])
    
    for d in data:
        csvWriter.writerow(d)
        
    return True

# change options into data table
def data_from_options(options):
    
    pass
    



# change time txt file into data table
def data_from_time():
    
    data = open("Render/Airplane/time_calculate.txt",'r')
    D_lines = data.readlines()


