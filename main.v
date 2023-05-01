module main

import hassclient as hc
import log
import os

fn main() {
	mut c := hc.new_connection(hc.ConnectionConfig{
		hass_uri: 'ws://localhost:8124/api/websocket'
		token: $env('HASS_TOKEN')
		// Uses the HASS_TOKEN env instead if empty
		log_level: log.Level.debug
	}) or { panic(err) }
	spawn c.connect()
	spawn handle_new_messages(mut c)
	os.get_line()
}

fn handle_new_messages(mut c hc.HassConnection) {
	for {
		mut event_data := <-c.events_channel
		id := event_data.id
		event := event_data.event
		println('FROM CHANNEL:  ${id} ${event}')
	}
}
