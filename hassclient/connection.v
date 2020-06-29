module hassclient
import net.websocket
import time
import log
import os
import channel

pub struct HassConnection {
	hass_uri	string
	pub:
	token		string
	mut:
	state_chan	&channel.Channel
	ws 			&websocket.Client
	sequence	int = 1
	logger  	&log.Log

}

pub struct ConnectionConfig {
	hass_uri 	string
	token		string
	log_level	log.Level = log.Level.info
}

// Instance new connection to Home Assistant
pub fn new_connection(cc ConnectionConfig) &HassConnection {

	token := if cc.token != '' { cc.token } else { os.getenv('HASS_TOKEN') }
	state_chan := channel.new_buffered_channel(100) or {panic(err)}

	mut c := &HassConnection {
		hass_uri: cc.hass_uri,
		token: token,
		ws: websocket.new(cc.hass_uri)
		state_chan: state_chan
		logger: &log.Log{}
	}
	c.ws.nonce_size = 16 // For python back-ends

	c.ws.subscriber.subscribe_method('on_open', on_open, c)
	c.ws.subscriber.subscribe_method('on_message', on_message, c)
	c.ws.subscriber.subscribe_method('on_error', on_error, c)
	c.ws.subscriber.subscribe_method('on_close', on_close, c)

	c.logger.set_level(cc.log_level)
	c.logger.debug('Initialized HassConnection')

	return c
}

pub fn (mut c HassConnection) state_change() ?&HassEventData {
	s := c.state_chan.read() or {return error(err)}
	return &HassEventData(s)
}

// Connects to Home Assistant
pub fn (mut c HassConnection) connect () {
	mut ws := c.ws
	c.logger.debug('Connecting to Home Assistant at $c.hass_uri')
	status := ws.connect()
	c.logger.debug('Connect status: ${status}')
	go ws.listen()

	for true {
		time.sleep_ms(5000)
	}
}

fn on_open(mut c HassConnection, ws websocket.Client, _ voidptr) {
	c.logger.debug('Websocket opened')
}

// Try to see if this fixes anything from @spytheman
fn check(){ m := HassMessage{} println(m) }

fn on_message(mut c HassConnection, ws websocket.Client, msg &websocket.Message) {
	match msg.opcode {
		.text_frame {
			msg_str := string(byteptr(msg.payload))
			hass_msg := parse_hass_message(msg_str) or
						{
							c.logger.error(err)
							HassMessage {}
						}
			match hass_msg.message_type {
				// When auth_required send the authorization message with token
				'auth_required' {
					c.logger.debug('Got auth_required, sending token...')
					auth_message := new_auth_message(c.token)
					c.ws.write(auth_message.str, auth_message.len, .text_frame)
				}
				// When auth is ok, setup subscriptions for all events
				'auth_ok' {
					c.logger.debug('Authentication success, subscribe to events...')
					c.sequence++
					subscribe_msg := new_subscribe_events_message(c.sequence)
					c.ws.write(subscribe_msg.str, subscribe_msg.len, .text_frame)
				}
				'event' {
					event_msg := parse_hass_event_message(msg_str) or
						{
							c.logger.error(err)
							EventMessage {}
						}
					match event_msg.event.event_type {
						// Home Assistant entity has changed state or attributes
						'state_changed' {
							c.logger.debug('state_changed event...')
							state_changed_event_msg := parse_hass_changed_event_message(msg_str) or
							{
								c.logger.error(err)
								StateChangedEventMessage {}
							}
							event_data := state_changed_event_msg.event.data
							c.state_chan.write(&event_data)

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

fn on_close(mut c HassConnection, ws websocket.Client, _ voidptr) {
	c.logger.debug('websocket closed.')
}

fn on_error(mut c HassConnection, ws websocket.Client, err string) {
	c.logger.error(err)
}