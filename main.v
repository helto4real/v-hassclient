module main

import hassclient as hc
import log
import os

fn main() {
	mut c := hc.new_connection(hc.ConnectionConfig{
		hass_uri: 'ws://host.docker.internal:8124/api/websocket'
		token: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJkZmY1MjZmMzc3ZDg0MGI3ODdlZmJiY2Q3MjM5N2VjZSIsImlhdCI6MTYzNzE1MTI5OCwiZXhwIjoxOTUyNTExMjk4fQ.l-BU63JnSMYw3__YFKACT4sSmTmBFN2K4TiQWiGGD8k'
		// Uses the HASS_TOKEN env instead if empty
		log_level: log.Level.debug
	}) or { panic(err) }
	go c.connect()
	go handle_new_messages(mut c)
	os.get_line()
}

fn handle_new_messages(mut c hc.HassConnection) {
	for {
		mut event_data := <-c.events_channel
		println('FROM CHANNEL: $event_data')
	}
}
