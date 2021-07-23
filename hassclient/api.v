module hassclient

import x.json2

pub fn (mut c HassConnection) call_service(domain string, service string, service_data json2.Any, target ...string) ? {
	c.sequence++

	cs := new_call_service_message(c.sequence, domain, service, service_data, target)
	str_encoded := cs.encode_json()
	c.ws.write_string(str_encoded) ?
	println('ENCODED: $str_encoded')
}
