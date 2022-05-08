
import os
import matplotlib
import matplotlib.pyplot as plt

COLORS=["r", "k", "b", "g", "y", "purple", "cyan"]
MARKERS = ['.', '>', '<', '*', 'v', '^', 'D', 'X', 'P', 'p', 's']
LINE_STYLES=[":","-.","--","-"]

IS_PDF = False
NOSHOW = False

SLIDES_FONT_SIZE = 18

SLIDE_PLOT = False
SMALL_PLOT = False
WIDE_PLOT = False
HIDDEN = []

if os.environ.get("PDF") is not None:
    IS_PDF = True

if os.environ.get("OUTFNAME") is not None:
    OUTFNAME = os.environ.get("OUTFNAME")
else:
    OUTFNAME = "figure"

if os.environ.get("FONT_SIZE") is not None:
    SLIDES_FONT_SIZE = int(os.environ.get("FONT_SIZE"))
    matplotlib.rcParams.update({'font.size': SLIDES_FONT_SIZE})

if os.environ.get("SLIDE_PLOT") is not None:
    SLIDE_PLOT = True

if os.environ.get("WIDE_PLOT") is not None:
    WIDE_PLOT = True

if os.environ.get("HIDDEN") is not None:
    HIDDEN = os.environ.get("HIDDEN").split(',')

if os.environ.get("SMALL_PLOT") is not None:
    SMALL_PLOT = True

if os.environ.get("NOSHOW") is not None:
    NOSHOW = True

def _figsize():
    if os.environ.get("SMALL_PLOT") is not None:
        return (3, 2.5)
    elif os.environ.get("HALF_SLIDE_PLOT") is not None:
        # Side-effect: increase font size, set title
        matplotlib.rcParams.update({'font.size': SLIDES_FONT_SIZE})
        return (8, 3.5)
    elif os.environ.get("SLIDE_PLOT") is not None:
        # Side-effect: increase font size, set title
        matplotlib.rcParams.update({'font.size': SLIDES_FONT_SIZE})
        plt.title(os.environ.get("SLIDE_PLOT"))

        return (8, 5)
    elif os.environ.get("SHORT_PLOT") is not None:
        return (5, 2.0)
    elif WIDE_PLOT:
        return (8, 3)
    else:
        return (5, 3.5)

def SetPlotRC():
    #If fonttype = 1 doesn't work with LaTeX, try fonttype 42.
    plt.rc('pdf',fonttype = 42)
    plt.rc('ps',fonttype = 42)

def ApplyFont(ax):

    ticks = ax.get_xticklabels() + ax.get_yticklabels()

    text_size = 14.0

    for t in ticks:
        t.set_fontname('Times New Roman')
        t.set_fontsize(text_size)

    txt = ax.get_xlabel()
    txt_obj = ax.set_xlabel(txt)
    txt_obj.set_fontname('Times New Roman')
    txt_obj.set_fontsize(text_size)

    txt = ax.get_ylabel()
    txt_obj = ax.set_ylabel(txt)
    txt_obj.set_fontname('Times New Roman')
    txt_obj.set_fontsize(text_size)

    txt = ax.get_title()
    txt_obj = ax.set_title(txt)
    txt_obj.set_fontname('Times New Roman')
    txt_obj.set_fontsize(text_size)

FIGSIZE=_figsize()

# Use type1 fonts
SetPlotRC()

"""
Given the output of `hash`, return a (r, g, b) tuple usable with matplotlib.
"""
def hash_to_color(h, alpha = 1):
    # Get a 3-byte number. Each byte will be a color component.
    mod = h % (1<<24)

    r = (mod >> 16) & 0xFF
    g = (mod >>  8) & 0xFF
    b =  mod        & 0xFF

    return (r/256., g/256., b/256., alpha)
