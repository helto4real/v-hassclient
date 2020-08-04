module main
// import channel
import hassclient as hc
import log

// struct TestStruct {
// 	pub mut:
// 	max_size int = 10
// }

struct Queue<T> {
mut: 
	// list of T items
	q        []&T
pub:
	// max size of queue
	max_size int
pub mut:
	// actual size of queue
	size     int
}

// fn new_queue<T>(max_size int) &Queue<T> {
//     queue := &Queue<T>{max_size: max_size}
//     return queue
// }

fn main() {
	// mut q := new_queue<TestStruct>(100) 
	// queue := &Queue<T>{max_size: 100}
	// println(queue.max_size)
// }
	// assert q.max_size == 100
	// q.push(mut &TestStruct{})
	// mut z := &TestStruct{}
	// q << z

	mut c := hc.new_connection(
		hc.ConnectionConfig {
			hass_uri: "ws://192.168.1.7:8123/api/websocket",
			token: '' // Uses the HASS_TOKEN env instead if empty
			log_level: log.Level.debug
		}
	) or {panic(err)}
	println('CONNECTING!')
	go c.connect() or {panic(err)}

	for {
		mut event_data := c.state_change() or {panic(err)}
		println('FROM QUEUE: $event_data')
		unsafe {
			free(event_data)
		}
		// println('$state.entity_id : $state.new_state.state ($state.old_state.state), $state.new_state.last_updated; $state.new_state.last_updated.microsecond')
	}
}