module hassclient

import x.json2
import os

fn test_parse_message_type_auth_returns_auth_type() ? {
	state_changed_event := os.read_file('./hassclient/testdata/event.json') ?
	event_msg := parse_hass_changed_event_message(json2.raw_decode(state_changed_event) or {
		json2.Any(json2.null)
	})

	assert event_msg.id == 1
	assert event_msg.event.data.entity_id == 'sensor.load_15m'
	assert event_msg.event.data.new_state.state == '0.07'
	assert event_msg.event.data.new_state.attributes['unit_of_measurement'].str() == ' '
}
