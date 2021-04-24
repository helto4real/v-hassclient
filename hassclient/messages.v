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

// pub fn (m &HassMessage) free() {
// 	m.message_type.free()
// }

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

// pub fn (mut se HassState) free() {
// 	// se.last_changed_str.free()
// 	// se.last_updated_str.free()
// 	// se.entity_id.free()
// 	// se.state.free()
// }

pub struct HassEventData {
	pub:
	entity_id 		string
	pub mut:
	new_state		HassState
	old_state		HassState
}

// pub fn (mut se HassEventData) free() {
// 	se.new_state.free()
// 	se.old_state.free()
// 	// se.entity_id.free()
// }

// clone, clones to heap
pub fn (ed HassEventData) clone() &HassEventData {
	mut event_data := &HassEventData{
		// entity_id: ed.entity_id
		new_state: ed.new_state
		old_state: ed.old_state
	}
	return event_data
}

pub struct HassEvent {
	time_fired		string
	pub:
	event_type 		string
}

// pub fn (e &HassEvent) free() {
// 	e.event_type.free()
// 	e.time_fired.free()
// }

pub struct HassStateChangedEvent {
	pub mut:
	time_fired		string
	data			HassEventData
}

// pub fn (mut m HassStateChangedEvent) free() {
// 	unsafe {

// 	m.data.free()
// 	// m.time_fired.free()
// 	}
// }

pub struct StateChangedEventMessage {
	pub mut:
	id				int						= -1
	event			HassStateChangedEvent
}

// pub fn (mut se StateChangedEventMessage) free() {
// 	se.event.free()
// }

// clone, clones to heap
pub fn (ed &StateChangedEventMessage) clone() &StateChangedEventMessage {
	mut ch_event := &StateChangedEventMessage{
		id: ed.id
		event: ed.event
	}
	return ch_event
}

pub struct EventMessage {
	pub mut:
	id				int						= -1
	event			HassEvent
}

// pub fn (m &EventMessage) free() {
// 	m.event.free()
// }


pub struct AuthMessage
{
	message_type	string [json:'type'] = 'auth'
	pub:
	access_token	string
}

// pub fn (m &AuthMessage) free() {
// 	// m.access_token.free()
// 	// m.message_type.free()
// }

pub struct SubscribeToEventsMessage
{
	message_type	string [json:'type'] = 'subscribe_events'
	pub:
	id				int
}

// pub fn (m &SubscribeToEventsMessage) free() {
// 	// m.message_type.free()
// }


// Parse the message type from Home Assistant message
fn parse_hass_message(jsn string) ?HassMessage {
	msg:= json.decode(HassMessage, jsn)?
	return msg
}

fn parse_hass_event_message(jsn string) ?EventMessage {
	msg:= json.decode(EventMessage, jsn)?
	return msg
}

fn parse_hass_changed_event_message(jsn string) ? StateChangedEventMessage {
	mut msg:= json.decode(StateChangedEventMessage, jsn)?

	new_last_updated := time.parse_iso8601(msg.event.data.new_state.last_updated_str)?
	msg.event.data.new_state.last_updated = new_last_updated

	new_last_changed := time.parse_iso8601(msg.event.data.new_state.last_changed_str)?
	msg.event.data.new_state.last_changed = new_last_changed

	old_last_updated := time.parse_iso8601(msg.event.data.old_state.last_updated_str)?
	msg.event.data.old_state.last_updated = old_last_updated

    old_last_changed := time.parse_iso8601(msg.event.data.old_state.last_changed_str)?
	msg.event.data.old_state.last_changed = old_last_changed

	return msg //.clone()
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