from turbogears import controllers
from flashticle.turbogateway import FlashRemotingGateway

class Root(controllers.RootController):
    def __init__(self):
        self.gateway = Gateway()
        
class Gateway(FlashRemotingGateway):
    def __getattr__(self, name):        
        # automagically load anything in the services dir
        if name.startswith('_') or '.' in name or '/' in name: raise AttributeError
        m = __import__('services.' + name, globals(), globals(), ['services'])        
        return getattr(m, name)()
                        
