module main

import hassclient as hc
import log

fn main() {
	c := hc.new_connection(
		hc.ConnectionConfig {
			hass_uri: "ws://192.168.1.7:8123/api/websocket",
			token: '' // Uses the HASS_TOKEN env instead if empty
			log_level: log.Level.debug
		}
	)
	println('CONNECTING!')
	go c.connect()

	for {
		state := c.state_change() or {panic(err)}
		println('$state.entity_id : $state.new_state.state ($state.old_state.state), $state.new_state.last_updated; $state.new_state.last_updated.microsecond')
	}
}