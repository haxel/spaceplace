# -*- coding: utf-8 -*-

########################################################################
# script to check master for new 
# nodes and download them and all related information
#
# it should handle:
#   1. a semi bootstrap where we can start from an empty database that has all tables
#   2. getting down new nodes added
#   3. getting all files from the nodes and fetch them via http
#   4. updating altered nodes (checking files inlined, too)
#   5. downloading added comment on the drupal site
#   6. uploading posted comments (gotchis) from the projetor 
#           - this is either triggered by the projektor 
#           - and as a safety belt by the update script
#
#   CONCERNS:
#   the trigger from the projektor calls the upload as a thread 
#   that might be causing trouble
########################################################################
 
from model import Comment,File,Term,Node,TermNode,User,Profile,NodeRevision,lastUpdate,lastCommentUpdate,gotchisSince
import turbogears,os,urllib,shutil,re
import datetime,time
from sqlobject import *
from sqlobject.main import SQLObjectNotFound
from threading import Thread

import MySQLdb
import MySQLdb.cursors
from _mysql_exceptions import OperationalError

from turbogears.database import PackageHub

hub = PackageHub("projector")
DOWNLOAD = "path/to/dir"
REMOTE_CURSOR = None
DB = None

try:
    conn = Term._connection
except KeyError:
    turbogears.update_config(configfile="../devcfg.py",modulename="projector.config")


def connect():
    global REMOTE_CURSOR,DB
    try:
        DB = MySQLdb.connect(user="orbiter",passwd="...",db="orbit_production",host="...",use_unicode=1,cursorclass=MySQLdb.cursors.DictCursor)
        REMOTE_CURSOR = DB.cursor()
    except OperationalError:
        raise "NoConnection"

def getUser(id):
    global REMOTE_CURSOR
    """ """
    query = """ 
        SELECT *
        FROM users
        WHERE uid = %d 
    """ % int(id)
    r = REMOTE_CURSOR.execute(query)
    user = REMOTE_CURSOR.fetchone()
    profile = []
    query = """ 
        SELECT *
        FROM profile_values
        WHERE uid = %d 
    """ % int(id)
    r = REMOTE_CURSOR.execute(query)
    for res in REMOTE_CURSOR.fetchall():
        profile.append(res)
    return user,profile

def getNode(id):
    global REMOTE_CURSOR
    """ """
    query = """ 
        SELECT *
        FROM node
        WHERE nid = %d 
    """ % int(id)
    r = REMOTE_CURSOR.execute(query)
    node =  REMOTE_CURSOR.fetchone()
    query = """ 
        SELECT *
        FROM node_revisions
        WHERE nid = %d 
    """ % int(id)
    r = REMOTE_CURSOR.execute(query)
    noderevision =  REMOTE_CURSOR.fetchone()
    query = """ 
        SELECT *
        FROM term_node
        WHERE nid = %d 
    """ % int(id)
    r = REMOTE_CURSOR.execute(query)
    tags =  REMOTE_CURSOR.fetchall()
    
    return node,noderevision,tags

def getTag(id):
    global REMOTE_CURSOR
    """ """
    query = """ 
        SELECT *
        FROM term_data
        WHERE tid = %d 
    """ % int(id)
    r = REMOTE_CURSOR.execute(query)
    return REMOTE_CURSOR.fetchone()

def getFile(i):
    global REMOTE_CURSOR
    """ """
    query = """ 
        SELECT *
        FROM files
        WHERE fid = %d 
    """ % int(i)
    r = REMOTE_CURSOR.execute(query)
    file = REMOTE_CURSOR.fetchone()
    query = """ 
        SELECT *
        FROM file_revisions
        WHERE fid = %d 
    """ % int(i)
    r = REMOTE_CURSOR.execute(query)
    revision = REMOTE_CURSOR.fetchone()
    return file,revision
    

def getLastGotchiUpload():

    global REMOTE_CURSOR
    query = """ SELECT UNIX_TIMESTAMP(MAX(timestamp)) as ts
                FROM projector_upload  """

    r = REMOTE_CURSOR.execute(query)
    t = REMOTE_CURSOR.fetchone()
    return t['ts']
    

def getNewComments(all=0):
    
    global REMOTE_CURSOR
    if all==1:
        query = """ 
            SELECT cid 
            FROM comments
            WHERE timestamp>0
        """
    else:
        query = """ 
            SELECT cid 
            FROM comments
            WHERE timestamp>%d
        """ % time.mktime(lastCommentUpdate().timetuple())

        
    r = REMOTE_CURSOR.execute(query)
    return REMOTE_CURSOR.fetchall()

def getNewNodes(all=0):
    print "last update %s" % lastUpdate()
    global REMOTE_CURSOR
    if all==1:
        query = """ 
            SELECT n.nid,n.uid,t.tid,n.changed
            FROM node n INNER JOIN term_node t ON t.nid = n.nid
            WHERE n.changed>0
        """
    else:
        query = """ 
            SELECT n.nid,n.uid,t.tid,n.changed
            FROM node n INNER JOIN term_node t ON t.nid = n.nid
            WHERE n.changed>%d
        """ % time.mktime(lastUpdate().timetuple())

    r = REMOTE_CURSOR.execute(query)
    return REMOTE_CURSOR.fetchall()

""" 
 I add new tags
"""
def addTags(tags): 
    terms = []  
    for id in tags:
        tag = getTag(id)
        tag['vocabulary'] = tag['vid']
        tag['id'] = tag['tid']
        del(tag['vid'])
        del(tag['tid'])
        terms.append(Term(**tag))
        print "Tag %d made!" % id
    return terms
    
""" 
 new users!
"""
def addUsers(users):
    for id in users:
        user,profiles =getUser(id)
        user['id'] = user['uid']
        user['password'] = user['pass']
        del(user['uid'])
        del(user['pass'])
        del(user['data'])
        user = User(**user)
        for profile in profiles:
            profile['user'] = user
            del(profile['uid'])
            Profile(**profile)
        print "User %d made!" % id
        downloadGotchi(id)

def downloadGotchi(id):
    """ """
    download_to = "%s/gotchis/picture-%s.png" % (DOWNLOAD,id)
    if not os.path.isfile(download_to):
        print "Gotchi %s loaded" % (id)
        urllib.urlretrieve("http://master/files/gotchi/orbit/picture-%s.png" % id, download_to)        

""" 
 new nodes!
"""
def addNodes(nodes):
    added = []
    for id in nodes:
        node,revision,tags = getNode(id)
        
        node['version'] = node['vid']
        node['user'] = node['uid']
        node['id'] = node['nid']
        revision['user'] = revision['uid']
        revision['id'] = revision['vid']
        revision['node'] = revision['nid']
        del(node['status'])
        del(node['uid'])
        del(node['nid'])
        del(node['vid'])
        del(revision['uid'])
        del(revision['nid'])
        del(revision['vid'])
        # add the nodes
        try:
            dbnode = Node.get(node['id']) 
            del(node['id'])
            dbnode.set(**node)
        except SQLObjectNotFound:
            dbnode = Node(**node)

        try:
            dbnoder = NodeRevision.get(revision['id'])
            del(revision['id'])
            dbnoder.set(**revision)
        except SQLObjectNotFound:
            dbnoder = NodeRevision(**revision)
        # add the termnodes
        for tag in tags:
            tag['node'] = tag['nid']
            tag['term'] = tag['tid']
            del(tag['nid'])
            del(tag['tid'])
            try:
                dbtag = Term.get(tag['term'])
            except SQLObjectNotFound:
                dbtag = addTags([tag['term']])[0]
            terms = list(TermNode.selectBy(node=dbnode,term=dbtag))
            if not terms:
                term = TermNode(**tag)
            else:
                term = terms[0]

        print "Node %d made!" % id
        added.append(id)
    return added
    
def addFiles(files):
    print "have to check %d files" % len(files)
    errors = []
    base = re.compile("^(.*)\.([\w]+)$")

    for file in files:
        if isinstance(file, File): continue
        f,revision = getFile(file)
        if not f: 
            print "%s not found!" % file
            continue
        path = f['filepath']
        f['id'] = f['fid']
        f['filepath'] = f['filename']
        f['filename'] = revision['description']
        f['node'] = f['nid']
        del(f['fid'])
        del(f['nid'])
        
        try:
            File.get(f['id'])
            print "file %s already there" % f['id']
            continue
        except SQLObjectNotFound:
            file = File(**f)
            
        match = base.match(file.filepath)
        if not match: 
            print "%s odd filename" % file.filename
            continue
        
        basename,ext = match.groups()
        
        if file.filemime[:5] == "video":
            download_from = "http://master/files/orbit/%s.flv" % urllib.quote(basename)
            download_to = "%s/movies/%s.flv" % (DOWNLOAD,basename)
            filename = basename + ".flv"
            alt = "%s/files/orbit/%s" % (DOWNLOAD,filename)
        
        elif file.filemime[:5] == "image":
            download_from = "http://master/%s" % urllib.quote(path)
            filename = basename + "." + ext
            download_to = "%s/images/%s" % (DOWNLOAD,filename)
            alt = "%s/%s" % (DOWNLOAD,path)            

        elif file.filemime[:5] == "audio":
            download_from = "http://master/%s" % urllib.quote(path)
            filename = basename + "." + ext
            download_to = "%s/audio/%s" % (DOWNLOAD,filename)
            alt = "%s/%s" % (DOWNLOAD,path)
    
        if not os.path.isfile(download_to) and os.path.isfile(alt):
            print "copy %s" % basename 
            shutil.copy(alt,download_to)
        elif not os.path.isfile(download_to):
            print "download %s" % basename 
            urllib.urlretrieve(download_from, download_to)
    
        if not os.path.isfile(download_to):
            print "could not fetch %s!" % download_to
            errors.append(file)
            continue
        
        if file.filemime[:5] == "image":
            if file.filemime[6:] == "gif":
                print "convert gif"
                movie = '%s/movies/%s.flv' % (DOWNLOAD,basename)
                cmd1 = "ffmpeg -f gif -i '%s' -s 320x240 -y %s" % (download_to,movie)
                os.popen(cmd1)
                if not os.path.isfile(movie):
                    print "%s cont execute!" % cmd1
                    errors.append(file)
                    continue
                else: 
                    os.unlink(download_to)
                file.filemime = "video/flv"
                filename = basename + ".flv"
            else:
                download_to_old = ""
                if file.filemime[6:] != "jpeg":
                    download_to_old = download_to
                    download_to = download_to + ".jpg"
                    filename = filename + ".jpg"
                    shutil.move(download_to_old,download_to)
                    
                cmd1 = "sips --getProperty pixelWidth '%s'" % download_to
                cmd2 = "sips --setProperty format jpeg --resampleWidth 400 '%s'" % download_to
                
                try:
                    if int(os.popen(cmd1).readlines()[1][14:-1]) <> 400:
                        os.popen(cmd2)
                        file.filemime = "image/jpeg"
                except IndexError:
                    print "%s cont execute!" % cmd2
                    errors.append(file)
                    continue
            
        file.filepath = filename

    for e in errors:
        e.destroySelf()    

def setWeight():
    # set weight    
    for tag in Term.select():
        tag._get_weight(True)


def syncUserGotchis():
    print "add missing gotchis"
    for person in User.select():
        downloadGotchi(person.id)


def syncNodes():
    print "syncing nodes"
    tags_checked = []
    users_checked = []
    nodes_checked = []
    tags_new = []
    users_new = []
    nodes_new = []
    
    for node in getNewNodes():
        tid = node['tid']
        nid = node['nid']
        changed = node['changed']
        uid = node['uid']

        if tid not in tags_checked:
            try:
                term = Term.get(tid)
            except SQLObjectNotFound:
                tags_new.append(tid)
            tags_checked.append(tid)

        if uid not in users_checked:
            try:
                node = User.get(uid)
            except SQLObjectNotFound:
                users_new.append(uid)
            users_checked.append(uid)

        if nid not in nodes_checked:
            try:
                node = Node.get(nid)
                if node.changed < changed:
                    nodes_new.append(nid)                    
            except SQLObjectNotFound:
                nodes_new.append(nid)
            nodes_checked.append(nid)
    
    
    hub.begin()    
    # add new db information
    addTags(tags_new)
    addUsers(users_new)
    nodes = addNodes(nodes_new)
    setWeight()
    hub.commit()
    
    return nodes

def syncFiles(nodes):
    # download new files - check body text for links to file
    print "syncing files"
    files = []
    for node in nodes:
        files += NodeRevision.get(node).files
    hub.begin()
    addFiles(files)
    hub.commit()

def syncComments():

    hub.begin()
    for id in getNewComments(0):  # get non gotchis
        query = """ 
            SELECT cid,uid,nid,subject,comment,timestamp
            FROM comments
            WHERE cid = %d 
        """ % int(id['cid'])
        r = REMOTE_CURSOR.execute(query)
        c = REMOTE_CURSOR.fetchone()
        c['user'] = c['uid']
        c['node'] = c['nid']
        c['comment'] = unicode(c['subject'] + "\n" + c['comment'])
        c['timestamp'] = datetime.datetime.fromtimestamp(c['timestamp'])
        c['filename'] = ""
        del(c['cid'])
        del(c['uid'])
        del(c['subject'])
        del(c['nid'])
        comment = Comment(**c)
        print "added " + str(comment.id)

    hub.commit()

def buildProject():
    # at the end make a new gotchi shared lib
    #if len(users_new):
    print "building project"
    os.chdir("/orbit/")
    cmd = "ant complete"
    print os.popen(cmd).read()

class AsyncUploadGotchi(Thread):

   def __init__ (self,cursor,id,filename,timestamp):
      Thread.__init__(self)
      self.cursor = cursor
      self.id = id
      self.filename = filename
      self.timestamp = timestamp

   def run(self):
       if self.id: 
           query = """ 
           INSERT INTO projector_upload (nid,comment,filename,timestamp)
           VALUES (%d,'','%s',"%s")
           """ % (self.id,self.filename,self.timestamp)
       else:
           query = """ 
           INSERT INTO projector_upload (comment,filename,timestamp)
           VALUES ('','%s',"%s")
           """ % (self.filename,self.timestamp)
       ## redirecting stdin to dev/null and stderr to stdin so we read only errors
       cmd = """scp '/uploads/%s.png' 'axel@master://uploads/' 2>&1 1>/dev/null""" % self.filename
       error = os.popen(cmd).read()
       if error == "":
           r = self.cursor.execute(query)

def uploadGotchi(comment):
    global REMOTE_CURSOR
    if not REMOTE_CURSOR: 
        connect()
    if comment.node:
        node = int(comment.node.id)
    else:
        node = None
    AsyncUploadGotchi(REMOTE_CURSOR,node,comment.filename,comment.timestamp.isoformat()).start()

def syncGotchisUpload():
    ts = getLastGotchiUpload()
    gotchis = gotchisSince(ts)
    for g in gotchis:
        uploadGotchi(g)

def critical(msg):    
    import smtplib
    from email.Utils import COMMASPACE, formatdate
    from email import Encoders

    def sendMail(to, subject, text ,server="localhost"):
        assert type(to)==list
        fro = "Projector <projector@...>"
        msg = "From: %s\n" % fro
        msg += "To: %s\n" % COMMASPACE.join(to)
        msg += "Date: %s\n" % formatdate(localtime=True)
        msg += "Subject: %s\n" % subject
        msg += "____________\n"
        msg += "%s\n" % text
        msg += "____________\n"
        smtp = smtplib.SMTP(server)
        smtp.sendmail(fro, to, msg)
        smtp.close()

    sendMail(["axel@..."],"CRITICAL ERROR",msg,"...")

    
if __name__ == "__main__":

    import sys
    try:
        connect() 
    except "NoConnection":
        sys.exit(0)
     
    try:
        # that should not trigger any action in normal operation
        # however in case the upload in realtime was not sucessful, it tries to at least 
        # sync all that have a timestamp newer than the last successful uploaded one
        syncGotchisUpload()
        # now i get all gottchiimages not already in the lib / that is merely a check for broken gotchis
        # todo synchronize all changed?      
        syncUserGotchis()
        # and now i fetch all newly added nodes with their corresponding tags and users. if they have any
        nodes = syncNodes()
        # fetch the files given in the nodes (that crawls through all nodes!)
        syncFiles(nodes)
        # and now i get all new comments posted down to the projektor
        syncComments()
        # finally make the projekt
        buildProject()
    except:
        # catch everything as it really should not trigger any exception not catched inside
        import traceback
        critical(traceback.format_exc())
    
   
