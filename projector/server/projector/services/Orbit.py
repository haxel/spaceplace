import cherrypy, traceback
from projector.model import Profile,Term,Node,User,NodeRevision,File,Stack,Comment,makeStack
from flashticle.amf import to_amf, typedobject
from sqlobject.main import SQLObjectNotFound
from turbogears.database import PackageHub

from projector.sync import uploadGotchi,critical

hub = PackageHub("projector")

@to_amf.when("isinstance(obj, Stack)")
def to_amf_Stack(obj):
    """
    """
    return to_amf(dict(
        id=obj.file.id,
        filename=obj.file.filename,
    ))


@to_amf.when("isinstance(obj, Comment)")
def to_amf_Comment(obj):
    """
    """
    return to_amf(typedobject("org.roteroktober.zkmax.model.Comment",dict(
        id=obj.id,
        filename = obj.filename,
        comment = obj.comment,
        timestamp = obj.timestamp,
        node = obj.node,
    )))

@to_amf.when("isinstance(obj, User)")
def to_amf_User(obj):
    """
    """
    return to_amf(typedobject("org.roteroktober.zkmax.model.Person",dict(
        id=obj.id,
        name=obj.name,
        signature=obj.signature,
        img=obj.picture,
    )))

@to_amf.when("isinstance(obj, Node)")
def to_amf_Node(obj):
    """
    """
    nr = NodeRevision.get(obj.id)
    
    stack = makeStack(nr)    
    
    return to_amf(typedobject("org.roteroktober.zkmax.model.Entry", dict(
        id=obj.id,
        name=obj.title,
        teaser=nr.teaser,
        body=nr.body,
        author=obj.user,
        files=[file.filepath for file in stack],
    )))

@to_amf.when("isinstance(obj, Term)")
def to_amf_Term(obj):
    """
    """
    return to_amf(typedobject("org.roteroktober.zkmax.model.Tag", dict(    
        id=obj.id,
        name=obj.name,
        weight=obj.weight,
        gotchis=[o.user.id for o in obj.nodes],
    )))

class Orbit(object):
    
    @cherrypy.expose()
    def getTags(self):
        terms = list(Term.select())
        return terms

    @cherrypy.expose()
    def getTagsByEntry(self,nid):
        return list(Node.get(nid).tags)

    @cherrypy.expose()
    def getEntriesForTag(self,tid):        
        return [(tid,n.id,n.title,n.user.id) for n in Term.get(tid).nodes]

    @cherrypy.expose()
    def getGotchisForTag(self,tid):        
        return [n.user for n in Term.get(tid).nodes]

    @cherrypy.expose()
    def getEntriesOfPerson(self,id):
        person = User.get(id)
        return list(Node.selectBy(user=person))

    @cherrypy.expose()
    def getProfileOfPerson(self,id):
        person = User.get(id)
        profile = {}
        for p in Profile.selectBy(user=person):
            profile[p.name] = p.value
        return profile

    @cherrypy.expose()
    def getPerson(self,id):        
        return User.get(id)

    @cherrypy.expose()
    def getAuthorForEntry(self,nid):        
        return Node.get(nid).user

    @cherrypy.expose()
    def getEntry(self,nid):        
        return Node.get(nid)

    @cherrypy.expose()
    def getComments(self,nid):
        node = Node.get(nid)
        return list(Comment.selectBy(node=node))

    @cherrypy.expose()
    def getStack(self):        
        return list(Stack.select())
    
    @cherrypy.expose()
    def getFilesOfEntry(self,nid):
        nr = NodeRevision.get(nid)
        return [file.filepath for file in nr.files]
        
    @cherrypy.expose()
    def setFile(self,args):     
        hub.begin() 
        try:  
            node = Node.get(args[1])
        except:
            node = None
        c = Comment(filename=args[0],node=node,comment="",user=None)
        hub.commit()   
        try:
            uploadGotchi(c)
        except:
            critical(traceback.format_exc())
            return None
        return c


