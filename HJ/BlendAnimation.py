import os
import sys
import glob
import datetime
import bpy
from pprint import pprint

import functools
print = functools.partial(print, flush=True)

C = bpy.context
D = bpy.data

C.space_data.font_size = 20

work_dir = os.path.dirname(bpy.data.filepath)
render_dir = os.path.join(work_dir, "Render")

w = D.worlds[0]
world = w
nodes = w.node_tree.nodes
bg = nodes['Background']
envtex = nodes['Environment Texture']

scene =  D.scenes[0]
render = scene.render

images = D.images

objects = D.objects

C.scene.cycles.shading_system = True

#
# Env Map -- Organize in Memory
#
envmap_images=[]
for i in images:
    if i.file_format == "HDR":
        envmap_images.append(i)

envtex.image = envmap_images[0]
envmap = envtex.image

#
# Models -- Organize in Memory
#
models = []
for m in objects:
    if m.type == "MESH":
        models.append(m)
        m.hide = True
        m.hide_render = True

model_names=[]
for m in models: model_names.append(m.name)

#
# Render all objects for one env map light
#
for m in models:
    m.hide = True
    m.hide_render = True

#
# Definitions
# 

def hideModels():
    """Hide all models"""
    for m in models:
        m.hide = True
        m.hide_render = True

def showModels():
    """show all models"""
    for m in models:
        m.hide = False
        m.hide_render = False

#
# Render the current frame of an object for multiple env maps
#
def renderCurrentEnv(model, film_transparent):
    """Render for 19 env maps"""
    hideModels()
    model.hide = False
    model.hide_render = False
    scene.cycles.film_transparent=film_transparent
    for i in envmap_images:
        envtex.image = i
        env_name=os.path.splitext(i.name)[0]
        render.filepath = os.path.join(
                render_dir, 
                model.name, 
                i.name, 
                str(scene.cycles.samples),
                #"FT" + str(scene.cycles.film_transparent), 
                "RGB_"+'{0:04d}'.format(scene.frame_current)+".png")
        bpy.ops.render.render(write_still=True)

#
# Batch render animation frames of an object for multiple env maps
#
def renderAnimationEnv(model, film_transparent, try_num, flag, flag2):
    """Render for 19 env maps"""
    print("start object: " + model.name)
    print(datetime.datetime.now())
    hideModels()
    model.hide = False
    model.hide_render = False
    D.objects['_Camera'].constraints['Track To'].target = model
    scene.cycles.film_transparent=film_transparent
    for i in envmap_images:
        envtex.image = i
        env_name=os.path.splitext(i.name)[0]
        print("start envmap: " + env_name)
        print(datetime.datetime.now())
        render.filepath = os.path.join(render_dir,model.name, try_num, flag, envtex.image.name, flag2+"_AirPlane_####.png")
        bpy.ops.render.render (animation = True)
        print("end envmap: " + env_name)
        print(datetime.datetime.now())
    print(datetime.datetime.now())
    print("end object" + "\n")

#
# RGB
#
def renderModel(model):
    print("start: " + model.name)
    print(datetime.datetime.now())
    hideModels()
    model.hide = False
    model.hide_render = False
    D.objects['_Camera'].constraints['Track To'].target = model
    render.filepath = os.path.join(render_dir, "RGB",model.name, envtex.image.name, str(scene.cycles.samples), "RGB_####.png")
    bpy.ops.render.render (animation = True)
    print(datetime.datetime.now())
    print("end" + "\n")
#
# XYZ
#
def renderXYZ(model):
    print("start: " + model.name)
    print(datetime.datetime.now())
    hideModels()
    model.hide = False
    model.hide_render = False
    D.objects['_Camera'].constraints['Track To'].target = model
    render.filepath = os.path.join(render_dir, "XYZ", model.name, str(scene.cycles.samples), "XYZ_####.exr")
    bpy.ops.render.render (animation = True)
    print(datetime.datetime.now())
    print("end" + "\n")

#
# Render Options
#
scene = bpy.data.scenes["Scene"]
scene.cycles.device = 'CPU' # 'CPU' or 'GPU'
scene.cycles.samples = 20 # 20 or 100
scene.render.threads_mode = 'AUTO' # 'AUTO' or 'FIXED'
#scene.render.threads = 1
scene.cycles.film_transparent = False
#scene.compression = 90
scene.render.resolution_x = 640
scene.render.resolution_y = 480
scene.render.resolution_percentage = 200
scene.render.tile_x = 32
scene.render.tile_y = 32
scene.frame_start = 131
scene.frame_end = 131
scene.frame_step = 1

#
# Main function
#


for j in range(10):
    
    i = 16
    
    while(i<1500):
        scene.cycles.device = 'CPU' # 'CPU' or 'GPU'
        renderAnimationEnv(models[1], False, "try_num_"+str(j), str(i)+"size", "CPU")
        scene.cycles.device = 'GPU' # 'CPU' or 'GPU'
        renderAnimationEnv(models[1], False, "try_num_"+str(j), str(i)+"size", "GPU")
        
        i = i*2


