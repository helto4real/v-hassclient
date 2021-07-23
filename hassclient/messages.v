module hassclient

import time
import x.json2
import json

pub struct HassState {
	last_changed_str string [json: 'last_changed']
	last_updated_str string [json: 'last_updated']
pub:
	entity_id  string
	state      string
	attributes map[string]json2.Any
pub mut:
	last_updated time.Time
	last_changed time.Time
}

fn parse_hass_state(json json2.Any) HassState {
	mut mp := json.as_map()

	mut state := HassState{
		entity_id: mp['entity_id'].str()
		state: mp['state'].str()
		attributes: mp['attributes'].as_map()
		last_changed_str: mp['last_changed'].str()
		last_updated_str: mp['last_updated'].str()
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

fn parse_hass_event_data(json json2.Any) HassEventData {
	mut mp := json.as_map()
	return HassEventData{
		entity_id: mp['entity_id'].str()
		new_state: parse_hass_state(mp['new_state'])
		old_state: parse_hass_state(mp['old_state'])
	}
}

pub struct HassEvent {
pub:
	event_type string
	time_fired string
	origin string
	context Context
}

pub struct Context {
    id string
    parent_id string
    user_id string
}

fn parse_context(json json2.Any) Context {
	mut mp := json.as_map()
	return Context{
		id: mp['id'].str(),
		parent_id: mp['parent_id'].str(),
		user_id: mp['user_id'].str()
	}
}
pub struct HassStateChangedEvent {
pub mut:
	time_fired string
	data       HassEventData
}

fn parse_hass_state_changed_event(json json2.Any) HassStateChangedEvent {
	mut mp := json.as_map()
	return HassStateChangedEvent{
		time_fired: mp['time_fired'].str()
		data: parse_hass_event_data(mp['data'])
	}
}

pub struct StateChangedEventMessage {
pub mut:
	id    int = -1
	event HassStateChangedEvent
}

fn parse_hass_changed_event_message(json json2.Any) StateChangedEventMessage {
	mut mp := json.as_map()
	return StateChangedEventMessage{
		id: mp['id'].int()
		event: parse_hass_state_changed_event(mp['event'])
	}
}

pub struct EventMessage {
pub mut:
	id    int = -1
	event HassEvent
}

fn parse_hass_event_message(json json2.Any) EventMessage {
	mut mp := json.as_map()
	return EventMessage{
		id: mp['id'].int()
		event: parse_hass_hass_event(mp['event'])
	}
}

fn parse_hass_hass_event(json json2.Any) HassEvent {
	mut mp := json.as_map()
	return HassEvent{
		time_fired: mp['time_fired'].str()
		event_type: mp['event_type'].str()
	}
}

pub struct SubscribeToEventsMessage {
	message_type string [json: 'type'] = 'subscribe_events'
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
	message_type string [json: 'type'] = 'auth'
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
	message_type string [json: 'type'] = 'call_service'
pub:
	id           int
	domain       string
	service      string
	service_data json2.Any
	target       []string
}

fn new_call_service_message(id int, domain string, service string, service_data json2.Any, target []string) CallServiceMessage {
	return CallServiceMessage{
		id: id
		domain: domain
		service: service
		service_data: service_data
		target: target
	}
}

fn (e CallServiceMessage) encode_json() string {
	mut jsn_any := map[string]json2.Any{}
	jsn_any['id'] = e.id
	jsn_any['type'] = e.message_type
	jsn_any['domain'] = e.domain
	jsn_any['service'] = e.service
	if e.service_data !is json2.Null {
		jsn_any['service_data'] = e.service_data
	}
	if e.target.len > 0 {
		if e.target.len == 1 {
			mut jsn_target := map[string]json2.Any{}
			jsn_target['entity_id'] = e.target[0]
			jsn_any['target'] = jsn_target
		} else {
			mut entities := []json2.Any{}
			for entity_id in e.target {
				mut jsn_target := map[string]json2.Any{}
				jsn_target['entity_id'] = entity_id
				entities << jsn_target
			}
			jsn_any['target'] = entities
		}
	}
	return jsn_any.str()
}

pub struct Entity {
	entity_id string
}
