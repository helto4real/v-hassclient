module hassclient

import time
import x.json2

pub struct HassState {
	last_changed_str string @[json: 'last_changed']
	last_updated_str string @[json: 'last_updated']
pub:
	entity_id  string
	state      string
	attributes map[string]json2.Any
pub mut:
	last_updated time.Time
	last_changed time.Time
}

fn parse_hass_state(hass_state_json json2.Any) !HassState {
	mut mp := hass_state_json.as_map()

	mut state := HassState{
		entity_id: mp['entity_id']!.str()
		state: mp['state']!.str()
		attributes: mp['attributes']!.as_map()
		last_changed_str: mp['last_changed']!.str()
		last_updated_str: mp['last_updated']!.str()
	}

	offset := time.offset()
	last_updated := time.parse_iso8601(state.last_updated_str) or { time.Time{} }
	state.last_updated = last_updated.add_seconds(offset)

	last_changed := time.parse_iso8601(state.last_changed_str) or { time.Time{} }
	state.last_changed = last_changed.add_seconds(offset)
	return state
}

pub struct HassEventData {
pub:
	entity_id string
pub mut:
	new_state HassState
	old_state HassState
}

fn parse_hass_event_data(hass_event_data_json json2.Any) !HassEventData {
	mut mp := hass_event_data_json.as_map()
	return HassEventData{
		entity_id: mp['entity_id']!.str()
		new_state: parse_hass_state(mp['new_state']!)!
		old_state: parse_hass_state(mp['old_state']!)!
	}
}

pub struct HassEvent {
pub:
	event_type string
	time_fired string
	origin     string
	context    Context
}

pub struct Context {
	id        string
	parent_id string
	user_id   string
}

fn parse_context(context_json json2.Any) !Context {
	mut mp := context_json.as_map()
	return Context{
		id: mp['id']!.str()
		parent_id: mp['parent_id']!.str()
		user_id: mp['user_id']!.str()
	}
}

pub struct HassStateChangedEvent {
pub mut:
	time_fired string
	data       HassEventData
	context    Context
}

fn parse_hass_state_changed_event(hass_state_changed_event_json json2.Any) !HassStateChangedEvent {
	mut mp := hass_state_changed_event_json.as_map()
	return HassStateChangedEvent{
		time_fired: mp['time_fired']!.str()
		data: parse_hass_event_data(mp['data']!)!
		context: parse_context(mp['context']!)!
	}
}

pub struct StateChangedEventMessage {
pub mut:
	id    int = -1
	event HassStateChangedEvent
}

fn parse_hass_changed_event_message(changed_event_json json2.Any) !StateChangedEventMessage {
	mut mp := changed_event_json.as_map()
	return StateChangedEventMessage{
		id: mp['id']!.int()
		event: parse_hass_state_changed_event(mp['event']!)!
	}
}

pub struct EventMessage {
pub mut:
	id    int = -1
	event HassEvent
}

fn parse_hass_event_message(hass_event_message json2.Any) !EventMessage {
	mut mp := hass_event_message.as_map()
	return EventMessage{
		id: mp['id']!.int()
		event: parse_hass_hass_event(mp['event']!)!
	}
}

fn parse_hass_hass_event(hass_event_json json2.Any) !HassEvent {
	mut mp := hass_event_json.as_map()
	return HassEvent{
		time_fired: mp['time_fired']!.str()
		event_type: mp['event_type']!.str()
	}
}

pub struct SubscribeToEventsMessage {
	message_type string = 'subscribe_events' @[json: 'type']
pub:
	id int
}

fn new_subscribe_events_message(id int) SubscribeToEventsMessage {
	return SubscribeToEventsMessage{
		id: id
	}
}

fn (e SubscribeToEventsMessage) encode_json() string {
	mut jsn_any := map[string]json2.Any{}
	jsn_any['id'] = e.id
	jsn_any['type'] = e.message_type
	return jsn_any.str()
}

pub struct AuthMessage {
	message_type string = 'auth' @[json: 'type']
pub:
	access_token string
}

fn new_auth_message(token string) AuthMessage {
	return AuthMessage{
		access_token: token
	}
}

fn (e AuthMessage) encode_json() string {
	mut jsn_any := map[string]json2.Any{}
	jsn_any['access_token'] = e.access_token
	jsn_any['type'] = e.message_type
	return jsn_any.str()
}

pub struct CallServiceMessage {
	message_type string = 'call_service' @[json: 'type']
pub:
	id           int
	domain       string
	service      string
	service_data json2.Any
	target       Target
}

fn new_call_service_message(id int, domain string, service string, service_data json2.Any, target Target) CallServiceMessage {
	return CallServiceMessage{
		id: id
		domain: domain
		service: service
		service_data: service_data
		target: target
	}
}

fn (e CallServiceMessage) encode_json() json2.Any {
	mut jsn_any := map[string]json2.Any{}
	jsn_any['id'] = e.id
	jsn_any['type'] = e.message_type
	jsn_any['domain'] = e.domain
	jsn_any['service'] = e.service
	if e.service_data !is json2.Null {
		jsn_any['service_data'] = e.service_data
	}
	if e.target.entity_id.len > 0 || e.target.device_id.len > 0 || e.target.area_id.len > 0 {
		jsn_any['target'] = e.target.encode_json()
	}

	return jsn_any
}

pub struct Target {
	entity_id []string
	device_id []string
	area_id   []string
}

pub fn (e Target) encode_json() json2.Any {
	mut jsn_any := map[string]json2.Any{}
	if e.entity_id.len > 0 {
		if e.entity_id.len == 1 {
			jsn_any['entity_id'] = e.entity_id[0]
		} else {
			mut entities := e.entity_id.map(json2.Any(it))

			jsn_any['entity_id'] = entities
		}
	}

	if e.device_id.len > 0 {
		if e.device_id.len == 1 {
			jsn_any['device_id'] = e.device_id[0]
		} else {
			mut devices := e.device_id.map(json2.Any(it))

			jsn_any['device_id'] = devices
		}
	}

	if e.area_id.len > 0 {
		if e.area_id.len == 1 {
			jsn_any['area_id'] = e.area_id[0]
		} else {
			mut areas := e.area_id.map(json2.Any(it))

			jsn_any['area_id'] = areas
		}
	}
	return jsn_any
}
