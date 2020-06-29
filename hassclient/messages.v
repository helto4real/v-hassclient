module hassclient

import json
import time

pub struct HassMessage {
	pub:
	id				int						= -1
	message_type 	string [json:'type']
	// Will do the raw thing when json is workning correctly again
	// event			string [raw]
	// result			string [raw]
}

// pub struct HassAttribute



pub struct HassState {
	last_changed_str	string [json:'last_changed']
	last_updated_str	string [json:'last_updated']

	pub:
	entity_id 			string
	state				string
	// attributes			[]map[string]string
	pub mut:
	last_updated		time.Time
	last_changed		time.Time
}

pub struct HassEventData {
	pub:
	entity_id 		string
	pub mut:
	new_state		HassState
	old_state		HassState


}
pub struct HassEvent {
	time_fired		string
	pub:
	event_type 		string
}

pub struct HassStateChangedEvent {
	time_fired		string
	mut:
	data			HassEventData
}

pub struct StateChangedEventMessage {
	pub:
	id				int						= -1
	mut:
	event			HassStateChangedEvent
}

pub struct EventMessage {
	pub:
	id				int						= -1
	mut:
	event			HassEvent
}

pub struct AuthMessage
{
	message_type	string [json:'type'] = 'auth'
	pub:
	access_token	string
}

pub struct SubscribeToEventsMessage
{
	message_type	string [json:'type'] = 'subscribe_events'
	pub:
	id				int
}

// Parse the message type from Home Assistant message
fn parse_hass_message(jsn string) ?HassMessage {
	msg:= json.decode(HassMessage, jsn) or {return error(err)}
	return msg
}

fn parse_hass_event_message(jsn string) ?EventMessage {
	msg:= json.decode(EventMessage, jsn) or {return error(err)}
	return msg
}

fn parse_hass_changed_event_message(jsn string) ?StateChangedEventMessage {
	mut msg:= json.decode(StateChangedEventMessage, jsn) or {return error(err)}

	new_last_updated := time.parse_iso8601(msg.event.data.new_state.last_updated_str) or
											{ return error(err)}
	msg.event.data.new_state.last_updated = new_last_updated

	new_last_changed := time.parse_iso8601(msg.event.data.new_state.last_changed_str) or
											{ return error(err)}
	msg.event.data.new_state.last_changed = new_last_changed

	old_last_updated := time.parse_iso8601(msg.event.data.old_state.last_updated_str) or
											{ return error(err)}
	msg.event.data.old_state.last_updated = old_last_updated

	 old_last_changed := time.parse_iso8601(msg.event.data.old_state.last_changed_str) or
											{ return error(err)}
	msg.event.data.old_state.last_changed = old_last_changed

	return msg
}

fn new_auth_message(token string) string {
	result_msg := json.encode(AuthMessage {
		access_token: token
		})
	return result_msg
}

fn new_subscribe_events_message(id int) string {
	result_msg := json.encode(SubscribeToEventsMessage {id: id})
	return result_msg
}

// fn parse_hass_message_ptr(jsn_ptr voidptr) ?HassMessage {
// 	msg := parse_hass_message(jsn_ptr.str()) or  {return error(err)}
// 	return msg
// }