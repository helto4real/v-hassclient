module hassclient

// fn test_parse_message_type_minimal_returns_correct_type() {
// 	hass_msg := hassclient.parse_hass_message('{"id": 5, "type": "testtype", "event": {"hello": "world"}}') or {exit(1)}
// 	println(hass_msg)
// 	assert hass_msg.message_type == 'testtype'
// }

fn test_parse_message_type_minimal_returns_correct_type() {
	hass_msg := parse_hass_message('{"type": "testtype"}') or { panic(err) }
	print(hass_msg)
	assert hass_msg.message_type == 'testtype'
}

fn test_parse_message_type_auth_returns_auth_type() {
	hass_msg := parse_hass_message('{"type": "auth_required", "ha_version": "0.110.3"}') or {
		panic(err)
	}
	print(hass_msg)

	assert hass_msg.message_type == 'auth_required'
}

fn test_parse_message_type_event_returns_auth_type() {
	hass_msg := parse_hass_message('{"id": 5, "type":"event", "event":{"data": "HELLO", "event_type": "test_event", "time_fired": "2016-11-26T01:37:24.265429+00:00", "origin": "LOCAL"}}') or {
		eprint(err)
		panic(err)
	}
	print(hass_msg)

	assert hass_msg.message_type == 'event'
}
