from random import randint 
from matplotlib import pyplot 


class show_annotation(object): 
    def __init__(self, annotations): 
        '''"fake" class, mostly a "function with memory"''' 
        self.annotations = annotations 

    def __call__(self, mouse_event): 
        ax = mouse_event.inaxes 
        if not ax: 
            return 
        line = ax.get_lines()[0] 
        contained, infos = line.contains(mouse_event) 
        if not contained:                                # eventually exited 
            for annotation in self.annotations.values(): 
                annotation.set_visible(False) 
        else: 
            xdata, ydata = line.get_data() 
            ind = infos['ind'][0] 
            annotation = self.annotations[xdata[ind], ydata[ind]] 
            if not annotation.get_visible():             # is entered 
                annotation.set_visible(True) 
        ax.figure.canvas.draw() 

def main():
    
    x = range(10) 
    y = [ randint(0, i) for i in x ] 
    labels = [ 'label_%d' % i for i in x ] 

    
    fig = pyplot.figure() 
    ax = fig.add_subplot(1, 1, 1) 
    ax.plot(x, y) 

    # waiting for a "dict comprehension" sintax 
    annotations = {} 
    for label, xe, ye in zip(labels, x, y): 
        annotations[xe,ye] = ax.annotate(label, (xe,ye), visible=False) 

    fig.canvas.mpl_connect('motion_notify_event', 
            show_annotation(annotations)) 
    pyplot.show()

main()
