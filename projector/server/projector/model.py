import math,re
from sqlobject import *
from turbogears.database import PackageHub
from datetime import datetime 
from sqlobject.main import SQLObjectNotFound
import _mysql_exceptions

hub = PackageHub("projector")
__connection__ = hub

def lastUpdate():
    results = Node._connection.queryOne("""
                SELECT MAX(changed)
                FROM node """)
    if results[0]:
        return datetime.fromtimestamp(results[0])
    else:
        return datetime.fromtimestamp(0)
        
def lastCommentUpdate():
    ### only count non gotchis (they have no filename)
    results = Node._connection.queryOne("""
                SELECT UNIX_TIMESTAMP(MAX(timestamp))
                FROM projector_upload 
                WHERE filename = '' """)
    if results[0]:
        return datetime.fromtimestamp(results[0])
    else:
        return datetime.fromtimestamp(0)

class Term(SQLObject):
    """
    """
    class sqlmeta:
        table = "term_data"
        idName = "tid"

    vocabulary = IntCol(dbName="vid")
    name = UnicodeCol()
    description = UnicodeCol()
    weight = IntCol()

    def _get_weight(self,forceUpdate=False):
        
        weight = self._SO_get_weight()
        if(not forceUpdate): return weight

        query = """ 
            SELECT COUNT(*) AS count, d.tid, d.name 
            FROM term_data d INNER JOIN term_node n ON d.tid = n.tid 
            WHERE d.vid IN (6)
            GROUP BY d.tid, d.name 
        """ 

        # Find minimum and maximum log-count.
        tmin = 1e9
        tmax = -1e9
        
        tags = []

        for row in Term._connection.queryAll(query):
            tag = [row[0],row[1],row[2]]
            tag[0] = math.log(tag[0])
            tmin = min(tmin,tag[0])
            tmax = max(tmax,tag[0])
            tags.append(tag)

        # Note: we need to ensure the range is slightly too large to make sure even
        # the largest element is rounded down.
        trange = max(0.01,tmax - tmin) * 1.0001

        for tag in tags: 
            if(tag[1] == self.id): 
                self._SO_set_weight(int(1 + math.floor(20 * (tag[0] - tmin) / trange)))
                break

        return self._SO_get_weight()
        
        
    def _get_nodes(self):
        results = Term._connection.queryAll("""
            SELECT n.nid 
            FROM node n 
            LEFT JOIN term_node tn on n.nid = tn.nid 
            LEFT JOIN term_data td ON td.tid = tn.tid 
            WHERE tn.tid = %d """ % int(self.id))
        return [Node.get(n[0]) for n in results]
            
class Node(SQLObject):
    """
    """
    class sqlmeta:
        table = "node"
        idName = "nid"

    user = ForeignKey('User',dbName='uid')

    title = UnicodeCol()
    version = IntCol(dbName="vid")

    type = UnicodeCol()
    created = IntCol()
    changed = IntCol()
    comment = IntCol()
    promote = IntCol()
    moderate = IntCol()
    sticky = IntCol()

    def _get_tags(self):
        results = Node._connection.queryAll("""
            SELECT tn.tid 
            FROM term_node tn 
            LEFT JOIN node n ON n.nid = tn.nid 
            WHERE n.nid = %d """ % int(self.id))
        return [Term.get(n[0]) for n in results]

class TermNode(SQLObject):
    
    class sqlmeta:
        table = "term_node"
        idName = "id"

    node = ForeignKey('Node',dbName='nid')
    term = ForeignKey('Term',dbName='tid')
    

class Profile(SQLObject):
    """ 
    """
    class sqlmeta:
        table = "profile_values"
        idName = "id"
    
    def _get_name(self):
        id = self._SO_get_fid()
        if id  == 2: return "name"
        elif id == 3: return "base"
        elif id == 4: return "sign"
        elif id == 6: return "path"
        elif id == 13: return "moons"
        elif id == 8: return "stars"
        elif id == 11: return "about"
        elif id == 12: return "url"
    
    fid = IntCol()
    user = ForeignKey('User',dbName='uid')
    value = UnicodeCol()
    
class User(SQLObject):
    """ 
    """
    class sqlmeta:
        table = "users"
        idName = "uid"
    
    name = UnicodeCol()
    password = UnicodeCol(dbName='pass')
    mail = UnicodeCol()
    mode = IntCol()
    sort = IntCol()
    threshold  = IntCol()
    theme = UnicodeCol()
    signature = UnicodeCol()
    created = IntCol()
    access = IntCol()
    login = IntCol()
    status = IntCol()
    timezone = UnicodeCol()
    language = UnicodeCol()
    picture = UnicodeCol()
    init = UnicodeCol()  

class File(SQLObject):
    """ 
    """
    class sqlmeta:
        table = "files"
        idName = "fid"

    node = ForeignKey('Node',dbName='nid')
    filename = UnicodeCol()
    filemime = UnicodeCol()
    filepath = UnicodeCol()
    filesize = IntCol()

class Stack(SQLObject):
    """ """
    class sqlmeta:
        table = "stack"
        idName = "id"
    
    file = ForeignKey('File',dbName='fid',cascade=None)

def empty_stack():
    Stack._connection.query("""DELETE FROM stack""")


def makeStack(nr):
    stack = []
    hub.begin()
    empty_stack()
    for file in nr.files:
        if not isinstance(file, File): continue
        try:
            s = Stack(file=file)
            stack.append(s.file)
        except SQLObjectNotFound,e:
            pass
    hub.commit()
    return stack
            
class Comment(SQLObject):
    """ """
    class sqlmeta:
        table = "projector_upload"
        idName = "pid"
    
    filename = UnicodeCol()
    comment = UnicodeCol()
    timestamp = DateTimeCol(default=datetime.now) 
    node = ForeignKey('Node',dbName='nid')
    user = ForeignKey('User',dbName='uid')

def gotchisSince(ts):                
    return list(Comment.select(AND(Comment.q.timestamp>datetime.fromtimestamp(ts),Comment.q.filename!="")))
        
class NodeRevision(SQLObject):
    """ 
    """
    class sqlmeta:
        table = "node_revisions"
        idName = "vid"

    def _init(self, *args, **kw):
        SQLObject._init(self, *args, **kw)
        self._files = []
        self.translated_body = ""
        self.translated_teaser = ""
        
    node = ForeignKey('Node',dbName='nid')
    user = ForeignKey('User',dbName='uid')
    title = UnicodeCol()
    body = UnicodeCol()
    teaser = UnicodeCol()
    log = UnicodeCol()
    timestamp = IntCol()
    format  = IntCol()
        
    def _get_files(self):
        if not self._files:
            self._files,body = translate(self._SO_get_body())
        files = []
        for file in self._files:
            try:
                files.append(File.get(file))
            except SQLObjectNotFound:
                files.append(file)
        return files
            
    def _get_body(self):
        if not self.translated_body:
            self._files,b = translate(self._SO_get_body())
            b.lstrip()
            b.rstrip()
            b = b.replace("\r","")
            self.translated_body = b.replace("\n\n\n","\n\n")
        return self.translated_body

    def _get_teaser(self):
        if not self.translated_teaser:
            f,b = translate(self._SO_get_teaser())
            b.lstrip()
            b.rstrip()
            #body = body.replace("\n","")
            b = b.replace("\r","")
            self.translated_teaser = b.replace("\n\n\n","\n\n")
        return self.translated_teaser

def translate(str):
    """ extract images """
    pattern = re.compile("(\[file:)(\d+)(\s*.*?\])")
    f = []
    def set_file(match):
        f.append(match.groups()[1])
        return ""
    return (f,pattern.sub(set_file,str))
    