from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
import datetime
import json # Still useful for sending a JSON response

# --- Configuration ---
HOST_NAME = '0.0.0.0'  # Listen on all available network interfaces
PORT_NUMBER = 4000
COMMAND_PATH = '/command'
# --- End Configuration ---

class MySimpleGetServer(BaseHTTPRequestHandler):

    def _send_json_response(self, status_code, data_dict):
        """Sends a JSON response."""
        self.send_response(status_code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(data_dict).encode('utf-8'))

    def do_GET(self):
        """Handles GET requests."""
        timestamp = datetime.datetime.now().isoformat()
        print(f"\n--- {timestamp} ---")
        print(f"GET request received for path: {self.path}")

        parsed_url = urlparse(self.path)
        query_params = parse_qs(parsed_url.query)

        print(f"Parsed Path: {parsed_url.path}")
        print(f"Query Parameters: {query_params}")

        if parsed_url.path == COMMAND_PATH:
            if 'message' in query_params and query_params['message']:
                # query_params['message'] is a list, take the first element
                received_message = query_params['message'][0]
                print(f"SUCCESS: Received message via GET parameter: \"{received_message}\"")
                self._send_json_response(200, {"status": "success", "message_received": received_message})
            else:
                print("Error: 'message' URL parameter not found or empty.")
                self._send_json_response(400, {"status": "error", "message": "Bad Request: 'message' URL parameter missing or empty."})
        elif parsed_url.path == '/':
             self._send_json_response(200, {"status": "ok", "message": "Python GET server is running. Send GET to /command?message=your_text"})
        else:
            print(f"Error: GET to unknown path {parsed_url.path}.")
            self._send_json_response(404, {"status": "error", "message": "Not Found. Try GET /command?message=your_text"})
        
        print("--- End Request ---")

    def do_POST(self):
        """Handles POST requests - respond that only GET is supported for /command."""
        timestamp = datetime.datetime.now().isoformat()
        print(f"\n--- {timestamp} ---")
        print(f"POST request received for path: {self.path} - This server primarily handles GET for /command.")
        self._send_json_response(405, {"status": "error", "message": "Method Not Allowed. Please use GET for /command."})
        print("--- End Request ---")


if __name__ == '__main__':
    try:
        server_address = (HOST_NAME, PORT_NUMBER)
        httpd = HTTPServer(server_address, MySimpleGetServer)
        print(f"Python GET server started on {HOST_NAME}:{PORT_NUMBER}")
        print(f"Listening for GET requests on {COMMAND_PATH}?message=<your_message>...")
        print("Press Ctrl+C to stop the server.")
        httpd.serve_forever()
    except OSError as e:
        if e.errno == 48: # Address already in use
            print(f"Error: Port {PORT_NUMBER} is already in use. Please close the other application or choose a different port.")
        else:
            print(f"Could not start server: {e}")
    except KeyboardInterrupt:
        print("\nCtrl+C received, shutting down the server...")
        httpd.socket.close()
        httpd.server_close()
        print("Server stopped.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
