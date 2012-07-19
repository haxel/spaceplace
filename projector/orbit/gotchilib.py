#!/usr/bin/env python
import dircache,os,re,shutil

def makeGotchilib(path):

    gotchis = dircache.listdir(path) 

    xml = """<?xml version="1.0" encoding="iso-8859-1" ?>

    <movie width="128" height="128" framerate="12" version="7">
     <background color="#333333"/>
     <!-- first frame -->
     <frame>

       <!-- add some assets to the library -->
       <library>
        %s
        </library>
        </frame>
    </movie>"""

    clip = """    <clip id="gotchi_%s" import="%s/%s"/>"""
    frame = """    <frame><place id="gotchi_%s" depth="1"/></frame>"""

    lib = ""
    fra = ""

    for g in gotchis:
        if g[0] == ".": continue
        lib += clip % (g[8:-4],path,g)
        fra += frame % (g[8:-4])
    

    f = open("gotchis.xml","w")
    f.writelines(xml % (lib,))
    f.close()
    return "gotchis.xml"

if __name__ == "__main__":
    path = "/path/to/gotchis/gotchis"
    cmd = 'swfmill -v simple %s assets/gotchis.swf 2>&1'
    warnRE = re.compile(r'WARNING: could not import '+path+'/picture-([0-9]+)\.png',re.MULTILINE)
    while 1:
        warn = None
        xml = makeGotchilib(path)
        errors = os.popen(cmd % xml).readlines()
        
        
        for line in errors:
            warn = warnRE.match(line)
            if warn:
                break

        if warn:
            gotchi = warn.groups()[0]
            if gotchi:
                print "removing gotchi %s" % gotchi
                os.unlink("%s/picture-%s.png" % (path,gotchi))
                continue
        
        break
    
    shutil.copy("assets/gotchis.swf","public/gotchis.swf")
    print "gotchis have been saved"