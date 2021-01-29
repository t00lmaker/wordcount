import sys
import requests
import traceback
from bs4 import BeautifulSoup
from flask import request, render_template 
from flask import Blueprint
from wordcount.ext.engine.main import process, words, no_stop_words
from wordcount.ext.database.main import db
from wordcount.ext.database.models import Result
from collections import Counter

site_bp = Blueprint("site", __name__)

@site_bp.route('/', methods=['GET'])
def index():
  errors = []
  results = {}
  return render_template('index.html', **locals())

@site_bp.route('/', methods=['POST'])
def count():
  errors = []
  results = {}
  try:
    url = request.form['url']
    content_url = requests.get(url)
    if content_url:
      # text processing
      text = BeautifulSoup(content_url.text, 'html.parser').get_text()
  
      text_words = words(text)
      stop_words = no_stop_words(text_words)

      text_word_count = Counter(text_words)
      stop_words_count = Counter(stop_words)      
      
      results = process(stop_words_count)

      try:
          result = Result(
              url=url,
              result_all=text_word_count,
              result_no_stop_words=stop_words_count
          )
          db.session.add(result)
          db.session.commit()
      except Exception as e: 
          print(e)         
          errors.append("Unable to add item to database.")
  except Exception as e:
      traceback.print_exc()
      print("Unexpected error:", e)
      errors.append(
          "Unable to get URL. Please make sure it's valid and try again."
      )

  return render_template('index.html', errors=errors, results=results)

def init_app(app):
  app.register_blueprint(site_bp)