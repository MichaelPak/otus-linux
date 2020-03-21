from flask import Flask

app = Flask(__name__)


@app.route('/back/')
def hello_world():
    return "<h1>Hi, Otus Linux! I'm backend.</h1>"

