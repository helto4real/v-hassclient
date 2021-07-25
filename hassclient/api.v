module hassclient

import x.json2

pub fn (mut c HassConnection) call_service(domain string, service string, service_data json2.Any, entity_id ...string) ? {
	c.sequence++

	cs := new_call_service_message(c.sequence, domain, service, service_data, Target{
		entity_id: entity_id
	})
	str_encoded := cs.encode_json()
	c.ws.write_string(str_encoded.str()) ?
}

pub fn (mut c HassConnection) call_service_with_device(domain string, service string, service_data json2.Any, device_id ...string) ? {
	c.sequence++

	cs := new_call_service_message(c.sequence, domain, service, service_data, Target{
		device_id: device_id
	})
	str_encoded := cs.encode_json()
	c.ws.write_string(str_encoded.str()) ?
}

pub fn (mut c HassConnection) call_service_with_area(domain string, service string, service_data json2.Any, area_id ...string) ? {
	c.sequence++

	cs := new_call_service_message(c.sequence, domain, service, service_data, Target{
		area_id: area_id
	})
	str_encoded := cs.encode_json()
	c.ws.write_string(str_encoded.str()) ?
}
