try:
    import sr.comp
except ImportError:
    print("No srcomp detected. Did you activate the virtualenv?")
    print("$ source venv/bin/activate")
    exit(1)

import cherrypy
import argparse
import os.path
import threading
import subprocess
import time
from sr.comp.http import app

parser = argparse.ArgumentParser()
parser.add_argument('compstate', help='path to compstate repo')
parser.add_argument('--no-scorer', action='store_false',
                    dest='scorer', help='disable the scorer system')
parser.add_argument('--no-stream', action='store_false',
                    dest='stream', help='disable the event stream')
parser.add_argument('--overlay', action='store_true',
                    help='enable using the livestream overlay')
args = parser.parse_args()

app.config['COMPSTATE'] = args.compstate

mydir = os.path.dirname(os.path.realpath(__file__))

if args.stream:
    def start_stream_thread():
        murder_stream = threading.Event()
        # Run streams thread
        def run_streams():
            # Hack, pending a better solution to determining whether
            # cherrypy has actually started yet.
            stream_dir = os.path.join(mydir, 'srcomp-stream')
            stream_process = subprocess.Popen(('node', 'main.js'),
                                              cwd=stream_dir)
            murder_stream.wait()
            stream_process.terminate()
            stream_process.wait()
        cherrypy.engine.subscribe('stop', murder_stream.set)
        thr = threading.Thread(name='streams', target=run_streams)
        thr.start()
    cherrypy.engine.subscribe('start', start_stream_thread)

cherrypy.tree.graft(app, '/comp-api')
if args.scorer:
    from sr.comp.scorer import app as scorer_app

    scorer_app.config['COMPSTATE'] = args.compstate
    scorer_app.config['COMPSTATE_LOCAL'] = True

    cherrypy.tree.graft(scorer_app, '/scorer')

screens_dir = os.path.realpath(os.path.join(mydir, 'srcomp-screens'))
config={
    '/': {
        'tools.staticdir.on': True,
        'tools.staticdir.dir': screens_dir,
        'tools.caching.on': False,
    },
    'global': {
        'server.socket_host': '::',
        'server.socket_port': 5112,
        'server.thread_pool': 8
    }
}

if args.overlay:
    overlay_dir = os.path.realpath(os.path.join(mydir, 'livestream-overlay'))
    config['/overlay'] = {
        'tools.staticdir.on': True,
        'tools.staticdir.dir': overlay_dir,
        'tools.caching.on': False,
    }
    print('Livestream overlay is available at: http://localhost:5112/overlay/stream.html')

cherrypy.quickstart(config=config)

