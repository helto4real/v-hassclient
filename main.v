module main
import hassclient as hc
import log
import os

fn main() {
	mut c := hc.new_connection(
		hc.ConnectionConfig {
			hass_uri: "ws://192.168.1.7:8123/api/websocket",
			token: '' // Uses the HASS_TOKEN env instead if empty
			log_level: log.Level.debug
		}
	) or {panic(err)}
	go c.connect() or {panic(err)}
	go handle_new_messages(mut c)
	os.get_line()
	
}

fn handle_new_messages(mut c hc.HassConnection) 
{
	for {
		mut event_data :=  <- c.ch_state_changed  
		println('FROM CHANNEL: $event_data')
		unsafe {
			event_data.free()
		}
	}
}