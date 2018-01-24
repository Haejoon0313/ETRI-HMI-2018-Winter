import os
import sys
import glob
import datetime
import bpy
import random
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
# several env & full scene
#

def renderScene(model_in_scene, env_in_scene, scene_num, sFlag, dFlag, gFlag):
    
    print("start object")
    print(datetime.datetime.now())
    
    hideModels()
    
    for m in model_in_scene:
        print(m.name)
        
        m.hide = False
        m.hide_render = False
    
    for i in env_in_scene:
        
        envtex.image = i
        env_name=os.path.splitext(i.name)[0]
        print("start envmap: " + env_name)
        print(datetime.datetime.now())
        render.filepath = os.path.join(render_dir, "scene"+scene_num, "sample"+sFlag, "D"+dFlag+"&G"+gFlag, envtex.image.name, "Animation_####.png")
        
        scene.frame_start = 105
        scene.frame_end = 105
        
        bpy.ops.render.render (animation = True)
        
        print("end envmap: " + env_name)
        print(datetime.datetime.now())
    
    print(datetime.datetime.now())
    print("end object" + "\n") 
    

#
# several env & full scene w/ camera rotating
#

def renderAnimation(model_in_scene, env_in_scene, scene_num, sFlag, dFlag, gFlag):
    
    print("start object")
    print(datetime.datetime.now())
    
    hideModels()
    D.objects['_Camera'].constraints['Follow Path'].mute = False
    
    for m in model_in_scene:
        print(m.name)
        
        m.hide = False
        m.hide_render = False
    
    for i in env_in_scene:
        
        envtex.image = i
        env_name=os.path.splitext(i.name)[0]
        print("start envmap: " + env_name)
        print(datetime.datetime.now())
        render.filepath = os.path.join(render_dir, "scene"+scene_num, "sample"+sFlag, "D"+dFlag+"&G"+gFlag, envtex.image.name, "Animation_####.png")
        
        scene.frame_start = 101
        scene.frame_end = 200
        D.objects['_Camera'].constraints['Follow Path'].target = D.objects["_CameraPath1"]
        D.objects['_Camera'].rotation_euler[0] = 7.2431
        
        bpy.ops.render.render (animation = True)
        
        scene.frame_start = 201
        scene.frame_end = 300
        D.objects['_Camera'].constraints['Follow Path'].target = D.objects["_CameraPath2"]
        D.objects['_Camera'].rotation_euler[0] = 7.8539
        
        bpy.ops.render.render (animation = True)
        
        print("end envmap: " + env_name)
        print(datetime.datetime.now())
    
    print(datetime.datetime.now())
    print("end object" + "\n") 
    

def cameraInit(camera):
    
    camera.location[0] = -0.3048
    camera.location[1] = -1.3344
    camera.location[2] = 0.7998
    camera.rotation_euler[0] = 7.2431
    camera.rotation_euler[1] = 0.0000
    camera.rotation_euler[2] = -0.1269
    camera.constraints['Follow Path'].mute = True
    

#
# Render Options
#
scene = bpy.data.scenes["Scene"]
scene.render.threads_mode = 'AUTO' # 'AUTO' or 'FIXED'
#scene.render.threads = 1
scene.cycles.film_transparent = False
#scene.compression = 90
scene.render.resolution_x = 640
scene.render.resolution_y = 480
scene.frame_step = 1

scene.cycles.device = 'CPU' # 'CPU' or 'GPU'
scene.render.resolution_percentage = 200
scene.cycles.samples = 20 # 20 or 100
scene.render.tile_x = 32
scene.render.tile_y = 32
scene.cycles.diffuse_bounces = 2
scene.cycles.glossy_bounces = 2
scene.frame_start = 101
scene.frame_end = 300
random.seed(180124) # test date for seed
scene_num = 1

scene.cycles.max_bounces = 4 # glossy + diffuse
scene.cycles.min_bounces = 3


#   
# Main function
#

sample_index = [10, 20, 40, 80, 160, 320]
diffuse_index = [2, 4, 8, 16]
glossy_index = [2, 4, 8, 16]

model_index = [2, 6, 19, 0] # 0: table

# camera initialize
cameraInit(D.objects['_Camera'])

# scenes location & rotation
scenes_inform = []

for i in range(scene_num):
    scenes_inform.append([[(random.uniform(-0.80, 0.45), random.uniform(-0.45, 0.08), random.uniform(0.30, 0.70)), # location for Airplane
      (random.uniform(-0.80, 0.45), random.uniform(-0.45, 0.08), random.uniform(0.30, 0.70)), # location for Cheezit
      (random.uniform(-0.80, 0.45), random.uniform(-0.45, 0.08), random.uniform(0.30, 0.70))], # location for Mustard
     [(random.uniform(-3.14, 3.14), random.uniform(-3.14, 3.14), random.uniform(-3.14, 3.14)), # rotation for Airplane
      (random.uniform(-3.14, 3.14), random.uniform(-3.14, 3.14), random.uniform(-3.14, 3.14)), # rotation for Cheezit
      (random.uniform(-3.14, 3.14), random.uniform(-3.14, 3.14), random.uniform(-3.14, 3.14))]]) # rotation for Mustard


scene_file = open(render_dir+"/scene_information.txt", 'w')
scene_file.write(str(scenes_inform))
scene_file.close()

# models in scene diffuse
model_list = []
for i in model_index:
    model_list.append(models[i])

env_in_scene = [envmap_images[1], envmap_images[7], envmap_images[18]]

log_file = open(render_dir+"/time_data.txt", 'w')
log_file.close()

for scene_index in range(scene_num):
    
    for j in range(3):

        model_list[j].location = scenes_inform[scene_index][0][j]
        model_list[j].rotation_euler = scenes_inform[scene_index][1][j]
    
    override = {'scene': C.scene,
                'point_cache': C.scene.rigidbody_world.point_cache}
    # bake to current frame
    bpy.ops.ptcache.free_bake_all(override)
    bpy.ops.ptcache.bake(override, bake=True)    
    
    for s_i in sample_index:
        
        scene.cycles.samples = s_i
        
        for d_i in diffuse_index:
            for g_i in glossy_index:
                
                log_file = open(render_dir+"/time_data.txt", 'a')
                
                scene.cycles.diffuse_bounces = d_i
                scene.cycles.glossy_bounces = g_i
                scene.cycles.max_bounces = d_i + g_i # glossy + diffuse
                
                log_file.write("start object\n")
                log_file.write(str(datetime.datetime.now()))
                log_file.write("\n")                
                
                renderScene(model_list, env_in_scene, str(scene_index), str(s_i), str(d_i), str(g_i))
                
                log_file.write(str(datetime.datetime.now()))
                log_file.write("\n")
                log_file.write("end object\n")
            
                log_file.close()


