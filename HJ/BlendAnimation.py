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
# Batch render animation frames of all objects for multiple env maps
#
def renderAnimationEnv(model_test, scene_num, sFlag, dFlag, gFlag, film_transparent):
    """Render for 19 env maps"""
    print("start animation")
    print(datetime.datetime.now())
    hideModels()
    for m in model_test:
        m.hide = False
        m.hide_render = False
        # D.objects['_Camera'].constraints['Track To'].target = model
    scene.cycles.film_transparent=film_transparent
    for i in envmap_images:
        envtex.image = i
        env_name=os.path.splitext(i.name)[0]
        print("start envmap: " + env_name)
        print(datetime.datetime.now())
        render.filepath = os.path.join(render_dir, "scene"+scene_num, "sample"+sFlag, "D"+dFlag+"&G"+gFlag, envtex.image.name, "Animation_####.png")
        bpy.ops.render.render (animation = True)
        print("end envmap: " + env_name)
        print(datetime.datetime.now())
    print(datetime.datetime.now())
    print("end animation" + "\n")

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
# several env & full scene
#

def renderScene(model_in_scene, env_in_scene, scene_num, sFlag, dFlag, gFlag):
    
    print("start object")
    print(datetime.datetime.now())
    
    hideModels()
    
    for m in model_in_scene:
        
        m.hide = False
        m.hide_render = False
    
    for i in env_in_scene:
        envtex.image = i
        env_name=os.path.splitext(i.name)[0]
        print("start envmap: " + env_name)
        print(datetime.datetime.now())
        render.filepath = os.path.join(render_dir, "scene"+scene_num, "sample"+sFlag, "D"+dFlag+"&G"+gFlag, envtex.image.name, "Animation_####.png")
        bpy.ops.render.render (animation = True)
        print("end envmap: " + env_name)
        print(datetime.datetime.now())   
    
    print(datetime.datetime.now())
    print("end object" + "\n")    
    
    
    

#
# Render Options
#
scene = bpy.data.scenes["Scene"]
scene.render.threads_mode = 'AUTO' # 'AUTO' or 'FIXED'
#scene.render.threads = 1
scene.cycles.film_transparent = True
#scene.compression = 90
scene.render.resolution_x = 640
scene.render.resolution_y = 480
scene.frame_start = 501
scene.frame_end = 501

scene.cycles.device = 'CPU' # 'CPU' or 'GPU'
scene.render.resolution_percentage = 100
scene.cycles.samples = 20 # 20 or 100
scene.render.tile_x = 32
scene.render.tile_y = 32
scene.cycles.diffuse_bounces = 2
scene.cycles.glossy_bounces = 2
scene.frame_step = 1

scene.cycles.max_bounces = 4 # glossy + diffuse
scene.cycles.min_bounces = 3


#
# Main function
#

sample_index = [10, 20, 40, 80, 160, 320]
diffuse_index = [2, 4, 8, 16]
glossy_index = [2, 4, 8, 16]

model_index = [1, 5, 19]

# scenes location & rotation
scenes_inform = [
    [[(0.0032, -0.2327, 0.4297), (0.0475, -0.1831, 0.2019), (0.0482, -0.3529, 0.1172)],
     [(0.0000, 0.0000, -0.0603), (0.6873, 0.0000, 0.0000), (-0.9947, -0.0883, -0.5178)]],
    [[(-0.3925, -0.2327, 0.1867), (-0.1303, -0.2234, 0.2004), (-0.2507, -0.2166, 0.3766)],
     [(-0.0525, 0.7150, -0.0800), (0.4864, 0.5910, -0.8126), (-0.9947, -0.0883, -0.5178)]],
    [[(-0.1512, -0.1341, 0.2544), (-0.1006, -0.2039, 0.4338), (-0.2157, -0.2296, 0.3918)],
     [(-3.0309, -0.1065, 2.3284), (-3.0309, -0.1065, 2.3284), (-1.5662, -0.0686, -0.3457)]],
    [[(0.0348, -0.1903, 0.1960), (-0.1006, -0.2039, 0.0036), (-0.1314, -0.1905, 0.0823)],
     [(-5.1828, 0.7068, 1.2528), (-1.5296, -0.0975, -2.4419), (-1.5296, -0.0975, -2.4419)]],
    [[(-0.1702, -0.1500, 0.2257), (-0.2233, -0.1766, 0.0350), (-0.1068, -0.1236, 0.0143)],
     [(0.2311, -0.0261, -4.6634), (0.0000, 0.0000, -4.6780), (0.0000, -0.0000, -2.4530)]]
]

# models in scene
model_list = []
for i in model_index:
    model_list.append(models[i])

env_in_scene = [envmap_images[0], envmap_images[7], envmap_images[18]]

log_file = open(render_dir+"/time_data.txt", 'w')
log_file.close()

for scene_index in range(5):
    
    override = {'scene': C.scene,
                'point_cache': C.scene.rigidbody_world.point_cache}
    # bake to current frame
    bpy.ops.ptcache.bake(override, bake=False)    
    
    for s_i in sample_index:
        
        scene.cycles.samples = s_i
        
        for d_i in diffuse_index:
            for g_i in glossy_index:
                
                log_file = open(render_dir+"/time_data.txt", 'a')
                
                scene.cycles.diffuse_bounces = d_i
                scene.cycles.glossy_bounces = g_i
                scene.cycles.max_bounces = d_i + g_i # glossy + diffuse
                
                for j in range(3):
                    
                    model_list[j].location = scenes_inform[scene_index][0][j]
                    model_list[j].rotation_euler = scenes_inform[scene_index][1][j]
                
                log_file.write("start object\n")
                log_file.write(str(datetime.datetime.now()))
                log_file.write("\n")                
                
                renderScene(model_list, env_in_scene, str(scene_index), str(s_i), str(d_i), str(g_i))
                
                log_file.write(str(datetime.datetime.now()))
                log_file.write("\n")
                log_file.write("end object\n")
            
                log_file.close()

