#
# Options for Blender Command Line Rendering form ModMan.SLS
#   ModMan: Project Modular Manipulator
#   SLS: Synthetic Learnign Set
#
# 2017-03-08
# 
# Joo-Haeng Lee (joohaeng@gmail.com)
#
# Example command:
# > blender -b Drill.blend -P option.py -a
#
import bpy

#bpy.context.scene.cycles.device = 'CPU'
scene = bpy.data.scenes["Scene"]
scene.cycles.device = 'CPU' # 'CPU' or 'GPU'
scene.render.threads_mode = 'AUTO' # 'AUTO' or 'FIXED'
scene.render.threads = 1
scene.render.resolution_x = 640
scene.render.resolution_y = 480
scene.render.tile_x = 32
scene.render.tile_y = 32
scene.frame_start = 1
scene.frame_end = 5616
scene.frame_step = 1

#
# OpenEXR
#
# bpy.context.scene.file_format = 'OPEN_EXR' # Strangely, it's not working (2017-03-10)
scene.render.image_settings.file_format = 'OPEN_EXR'
scene.render.use_overwrite = True 
scene.render.image_settings.color_mode = 'RGBA' # 'BW' for Depth; 'RGBA' for others
scene.render.image_settings.color_depth = '32'
scene.render.image_settings.exr_codec = 'ZIP'
scene.render.image_settings.use_zbuffer = True
scene.render.image_settings.use_preview = False # True or False; True will generate separate jpg images. 

#
# Link ¡®Alpha¡¯ between ¡®Render Layers¡¯ and ¡®Composite¡¯
# Required for depth rendering, not for XYZ nor Normal.
#
# scene.use_nodes = True
# tree = scene.node_tree
# node_r = tree.nodes['Render Layers']
# node_c = tree.nodes['Composite']
# tree.links.new(node_r.outputs[1], node_c.inputs[1])
# tree.links.remove(node_c.inputs[1].links[0]) # Uncomment this line to render the background

#scene.render.filepath = "//Drill Test//Drill_GPU_####.png"
