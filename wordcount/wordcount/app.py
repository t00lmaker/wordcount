from flask import Flask
import wordcount.ext.site.main as site
import wordcount.ext.database.main as database 
#import wordcount.ext.configuration.main as configuration
import wordcount.ext.command.main as command

# application factory
def create_app():
    app = Flask(__name__)
    #configuration.init_app(app)
    site.init_app(app)
    database.init_app(app)
    command.init_app(app)
    return app