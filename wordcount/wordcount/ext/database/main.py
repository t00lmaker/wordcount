import os
from flask_sqlalchemy import SQLAlchemy

db=SQLAlchemy()

def init_app(app):
  app.config['SQLALCHEMY_DATABASE_URI'] = os.environ['DATABASE_URL']
  app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
  db.init_app(app)