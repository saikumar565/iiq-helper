from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_CONNECTOR_TYPE
from pptx.oxml.ns import qn
from lxml import etree

RECT=1; OVAL=9; DIAMOND=4; RRECT=5; CAN=13

def rgb(r,g,b): return RGBColor(r,g,b)

# -- Color scheme ------------------------------
NAVY       = rgb(31,  73,  125)   # header bar
START_END  = rgb(226, 245, 228)   # light green  � ovals, trigger rounded-rects
PROCESS    = rgb(189, 215, 238)   # light blue   � rectangles, cylinders
DECISION   = rgb(255, 242, 204)   # light yellow � diamonds
WHITE      = rgb(255, 255, 255)   # slide background
TEXT_DARK  = rgb(0,   0,   0)     # black text
BORDER     = rgb(31,  73,  125)   # navy border

prs = Presentation()
prs.slide_width  = Inches(10)
prs.slide_height = Inches(7.5)

def new_slide():
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    S = slide.shapes
    bg = S.add_shape(RECT, Inches(0), Inches(0), Inches(10), Inches(7.5))
    bg.fill.solid(); bg.fill.fore_color.rgb = WHITE
    bg.line.color.rgb = WHITE
    return slide, S

def box(S, l, t, w, h, text, fill=None, stype=RECT, fs=9):
    fill = fill or PROCESS
    s = S.add_shape(stype, Inches(l), Inches(t), Inches(w), Inches(h))
    s.fill.solid(); s.fill.fore_color.rgb = fill
    s.line.color.rgb = BORDER; s.line.width = Pt(1.0)
    tf = s.text_frame; tf.word_wrap = True
    p = tf.paragraphs[0]; p.alignment = PP_ALIGN.CENTER
    run = p.add_run(); run.text = text
    run.font.size = Pt(fs); run.font.color.rgb = TEXT_DARK
    return s

def header(S, title, num, total=4):
    h = S.add_shape(RECT, Inches(0), Inches(0), Inches(10), Inches(0.55))
    h.fill.solid(); h.fill.fore_color.rgb = NAVY; h.line.color.rgb = NAVY
    p = h.text_frame.paragraphs[0]; p.alignment = PP_ALIGN.LEFT
    r = p.add_run(); r.text = f"  {title}"
    r.font.size = Pt(11); r.font.bold = True; r.font.color.rgb = WHITE
    tb = S.add_textbox(Inches(8.6), Inches(0.1), Inches(1.3), Inches(0.35))
    p2 = tb.text_frame.paragraphs[0]; p2.alignment = PP_ALIGN.RIGHT
    r2 = p2.add_run(); r2.text = f"Slide {num} / {total}"
    r2.font.size = Pt(9); r2.font.color.rgb = WHITE

def note(S, text):
    tb = S.add_textbox(Inches(0.25), Inches(7.1), Inches(9.5), Inches(0.32))
    p = tb.text_frame.paragraphs[0]; p.alignment = PP_ALIGN.LEFT
    r = p.add_run(); r.text = text
    r.font.size = Pt(8); r.font.italic = True; r.font.color.rgb = rgb(60,60,60)

def lbl(S, l, t, w, h, text, fs=8, center=True):
    tb = S.add_textbox(Inches(l), Inches(t), Inches(w), Inches(h))
    p = tb.text_frame.paragraphs[0]
    p.alignment = PP_ALIGN.CENTER if center else PP_ALIGN.LEFT
    r = p.add_run(); r.text = text
    r.font.size = Pt(fs); r.font.color.rgb = TEXT_DARK
    return tb

def arrow(S, x1, y1, x2, y2, label=""):
    c = S.add_connector(MSO_CONNECTOR_TYPE.STRAIGHT,
                        Inches(x1), Inches(y1), Inches(x2), Inches(y2))
    c.line.color.rgb = rgb(50,50,50); c.line.width = Pt(1.25)
    tail = etree.SubElement(c.line._ln, qn("a:tailEnd"))
    tail.set("type","arrow"); tail.set("w","med"); tail.set("len","med")
    if label:
        lbl(S, (x1+x2)/2-0.35, min(y1,y2)-0.22, 0.9, 0.28, label, fs=7.5)

# -------------------------------------------
# SLIDE 1 � GO-LIVE
# -------------------------------------------
sl1, S1 = new_slide()
header(S1, "Step 1 of 4  �  Go-Live  (One-Time Full Load)", 1)
lbl(S1, 0.4, 0.72, 9.2, 0.4,
    "YODA Reconciliation Task is run ONCE in Full mode.  All data from YODA Target loads directly into YODA Master table.", fs=9, center=False)

box(S1, 1.2, 1.7, 2.2, 0.85, "YODA Target System", START_END, OVAL)
box(S1, 6.2, 1.7, 2.2, 0.85, "YODA Master Table",  PROCESS,   CAN)
arrow(S1, 3.4, 2.125, 6.2, 2.125, "Full Load")

box(S1, 0.5, 3.4, 9.0, 0.65,
    "YODA Master:  Primary key = Cost Center.  Columns include legacy_busnode_06, legacy_busnode_name_05, etc.", PROCESS, fs=9)
box(S1, 0.5, 4.3, 9.0, 0.65,
    "LDAP Application Create Rule reads legacy level attributes (e.g. level06) directly from YODA Master at provisioning time.", PROCESS, fs=9)
note(S1, "After go-live, task is scheduled at 4AM daily in Delta mode  ->  See Slide 2")

# -------------------------------------------
# SLIDE 2 � DAILY DELTA
# -------------------------------------------
sl2, S2 = new_slide()
header(S2, "Step 2 of 4  �  Daily Delta  �  YODA Reconciliation Task @ 4AM", 2)

box(S2, 0.2,  1.075, 1.7, 0.7,  "Change in YODA\nTarget System",       START_END, OVAL)
box(S2, 3.1,  1.1,   1.5, 0.65, "Loads data into\nYODA Staging Table", PROCESS,   CAN)
box(S2, 5.3,  0.975, 1.75,0.9,  "Any changed\nrecords?",               DECISION,  DIAMOND)
box(S2, 7.4,  1.1,   2.4, 0.65, "No action.\nClear Staging",           START_END, RRECT)

box(S2, 5.3,  2.3,  1.75, 0.7,  "Identify delta rows\nper cost center",   PROCESS)
box(S2, 5.3,  3.3,  1.75, 0.7,  "Update impacted rows\nin YODA Master",   PROCESS)
box(S2, 2.9,  3.3,  1.8,  0.65, "Clear / Empty\nYODA Staging",            PROCESS)
box(S2, 7.4,  3.2,  2.4,  0.85, "Set refresh_status = Pending\n(impacted cost centers in Master)", PROCESS)

arrow(S2, 1.9,  1.425, 3.1,  1.425, "YODA Delta Runs")
arrow(S2, 4.6,  1.425, 5.3,  1.425, "Compares with Master Table")
arrow(S2, 7.05, 1.425, 7.4,  1.425, "No")
arrow(S2, 6.175,1.875, 6.175,2.3)
lbl(S2, 6.25, 1.97, 0.5, 0.28, "Yes", fs=8)
arrow(S2, 6.175,3.0,   6.175,3.3)
arrow(S2, 5.3,  3.65,  4.7,  3.65)
arrow(S2, 7.05, 3.65,  7.4,  3.65)
note(S2, "refresh_status = Pending triggers Pre-Refresh Optimization Task  ->  See Slide 3")

# -------------------------------------------
# SLIDE 3 � PRE-REFRESH OPTIMIZATION
# -------------------------------------------
sl3, S3 = new_slide()
header(S3, "Step 3 of 4  �  Pre-Refresh Optimization Task  (Checkbox: Sync Yoda Changes to Account)", 3)

box(S3, 0.2,  0.825,1.4, 0.65, "Task\nRuns",                               START_END, RRECT)
box(S3, 1.9,  0.775,2.0, 0.75, "Query YODA Master\nfor refresh_status\n= Pending", PROCESS)
box(S3, 4.4,  0.7,  1.6, 0.9,  "Identities\nfound?",                       DECISION,  DIAMOND)
box(S3, 6.6,  0.825,3.0, 0.65, "Nothing to process",                       START_END, RRECT)

box(S3, 4.4,  1.9,  1.6, 0.9,  "Count\n\u2264 2000?",                      DECISION,  DIAMOND)

box(S3, 0.3,  3.0,  2.8, 0.7,  "Mark needsRefresh = true\nfor ALL identities", PROCESS)
box(S3, 5.5,  3.0,  3.5, 0.7,  "Mark first 2000\nneedsRefresh = true",         PROCESS)

box(S3, 0.3,  4.2,  4.3, 0.75, "Set refresh_status = Completed\nin YODA Master",  PROCESS)
box(S3, 5.5,  4.2,  3.5, 0.75, "Store remaining identities\nin Custom Object",     PROCESS)

box(S3, 5.5,  5.35, 3.5, 0.65, "Next run: picks from Custom Object first",  START_END, RRECT)

arrow(S3, 1.6,  1.15,  1.9,  1.15)
arrow(S3, 3.9,  1.15,  4.4,  1.15)
arrow(S3, 6.0,  1.15,  6.6,  1.15, "No")
arrow(S3, 5.2,  1.6,   5.2,  1.9,  "Yes")
arrow(S3, 4.4,  2.35,  1.65, 3.0,  "Yes \u22642000")
arrow(S3, 6.0,  2.35,  7.25, 3.0,  "No >2000")
arrow(S3, 1.65, 3.7,   2.3,  4.2)
arrow(S3, 5.5,  3.35,  4.6,  4.2)
arrow(S3, 7.25, 3.7,   7.25, 4.2)
arrow(S3, 5.5,  4.575, 4.6,  4.575)
arrow(S3, 7.25, 4.95,  7.25, 5.35)
note(S3, "Identities with needsRefresh = true are picked up by Process Events Task  ->  See Slide 4")

# -------------------------------------------
# SLIDE 4 � PROCESS EVENTS
# -------------------------------------------
sl4, S4 = new_slide()
header(S4, "Step 4 of 4  �  Process Events Task", 4)
lbl(S4, 0.4, 0.72, 9.2, 0.38,
    "Picks identities flagged needsRefresh = true and triggers Attribute Sync to update LDAP legacy attributes from YODA Master.", fs=9, center=False)

box(S4, 0.3,  2.1, 2.2, 0.9,  "Picks identities with\nneedsRefresh = true",       START_END, RRECT)
box(S4, 3.2,  2.1, 1.9, 0.9,  "Triggers\nAttribute Sync",                          PROCESS)
box(S4, 5.7,  2.1, 2.0, 0.9,  "Reads updated legacy\nvalues from YODA Master",     PROCESS)
box(S4, 8.3,  2.0, 1.45,1.1,  "LDAP Application\nupdated with new\nlegacy attributes", PROCESS, CAN)

arrow(S4, 2.5, 2.55, 3.2,  2.55)
arrow(S4, 5.1, 2.55, 5.7,  2.55)
arrow(S4, 7.7, 2.55, 8.3,  2.55)

box(S4, 0.3, 4.0, 9.4, 2.6,
    "End-to-End Summary\n\n"
    "1.  Go-Live:  Full load  YODA Target  ->  YODA Master\n"
    "2.  Daily Delta @ 4AM:  Changed records detected  ->  Master updated  ->  refresh_status = Pending\n"
    "3.  Pre-Refresh Task:  Marks needsRefresh = true (max 2000 / run; overflow stored in Custom Object)\n"
    "4.  Process Events:  Attribute Sync triggered  ->  LDAP legacy attributes updated from YODA Master",
    PROCESS, fs=9)

note(S4, "Flow complete.  LDAP legacy attributes are now in sync with YODA Master.")

prs.save("YODA_Flowchart.pptx")
print("Saved: YODA_Flowchart.pptx  (4 slides)")
