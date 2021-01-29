import operator
import re
import nltk

from .stop_words import stops
from collections import Counter

def words(text):
    nltk.data.path.append('./nltk_data/')  # set the path
    tokens = nltk.word_tokenize(text)
    text = nltk.Text(tokens)
    # remove punctuation, count text words
    nonPunct = re.compile('.*[A-Za-z].*')
    return [w for w in text if nonPunct.match(w)]

def no_stop_words(text_words):
    return [w for w in text_words if w.lower() not in stops]

def process(no_stop_words_count):
    return sorted(
        no_stop_words_count.items(),
        key=operator.itemgetter(1),
        reverse=True
    )

def ini_app(app):
    nltk.download('punkt')
