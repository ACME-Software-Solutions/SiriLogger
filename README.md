# SiriLogger
a vibe-coded app to verify some basic functionality

Q: "Can I send commands through Siri to my BE, while the device is locked?"
A: Yes! This is pretty clunky but right now I can do the following:

1. phone locked, server.py running
2. "hey siri, log my entry"
3. "what is the message for your log entry?"
4. "ahoy there!"
5. message is sent to the server (currently in a GET request)

This should be switched to a POST request when it comes time to running E2E tests, but for now it works!
