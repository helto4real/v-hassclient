module hassclient

import x.websocket
import log
import os

pub struct HassConnection {
	hass_uri   string
pub:
	token      string
mut:
	ws         &websocket.Client
	sequence   int = 1
	logger     &log.Log
pub mut:
	ch_state_changed    chan StateChangedEventMessage
}

pub struct ConnectionConfig {
	hass_uri  string
	token     string
	log_level log.Level = log.Level.info
}

// Instance new connection to Home Assistant
pub fn new_connection(cc ConnectionConfig) ?&HassConnection {
	token := if cc.token != '' { cc.token } else { os.getenv('HOMEASSISTANT__TOKEN') }
	cl := websocket.new_client(cc.hass_uri)?
	ch := chan StateChangedEventMessage{cap: 100} 
	mut c := &HassConnection{
		hass_uri: cc.hass_uri
		token: token
		ws: cl
		ch_state_changed: ch
		logger: &log.Log{}
	}
	// c.ws.nonce_size = 16 // For python back-ends
	c.ws.on_message_ref(on_message, c)
	c.ws.on_close(fn (mut ws websocket.Client, close_reason int, a_string string) {
		println("SERVER CLOSED THE CONNECTION! ($close_reason), ")
		} )
	c.logger.set_level(cc.log_level)
	c.logger.debug('Initialized HassConnection')
	return c
}

// Connects to Home Assistant
pub fn (mut c HassConnection) connect() ? {
	mut ws := c.ws
	c.logger.debug('Connecting to Home Assistant at $c.hass_uri')
	ws.connect()?
	ws.listen()?
}

fn on_message(mut ws websocket.Client, msg &websocket.Message, mut c HassConnection) ? {
	match msg.opcode {
		.text_frame {
			msg_str := msg.payload.bytestr()
			hass_msg := parse_hass_message(msg_str) or {
				c.logger.error(err.msg)
				HassMessage{}
			}
			match hass_msg.message_type {
				// When auth_required send the authorization message with token
				'auth_required' {
					c.logger.debug('Got auth_required, sending token...')
					auth_message := new_auth_message(c.token)
					c.ws.write_string(auth_message) ?
					unsafe {
						// auth_message.free()
					}
				}
				// When auth is ok, setup subscriptions for all events
				'auth_ok' {
					c.logger.debug('Authentication success, subscribe to events...')
					c.sequence++
					subscribe_msg := new_subscribe_events_message(c.sequence)
					c.ws.write_string(subscribe_msg) ?
				}
				'event' {
					event_msg := parse_hass_event_message(msg_str) or {
						c.logger.error(err.msg)
						EventMessage{}
					}
					match event_msg.event.event_type {
						// Home Assistant entity has changed state or attributes
						'state_changed' {
							c.logger.debug('state_changed event...')
							mut state_changed_event_msg := parse_hass_changed_event_message(msg_str) or {
								c.logger.error(err.msg)
								return none
							}
							c.ch_state_changed <- state_changed_event_msg
							println(state_changed_event_msg)
						}
						else {}
					}

				}
				else {}
			}
		}
		else {
			c.logger.error('unhandled opcode: $msg.opcode')
		}
	}
}

