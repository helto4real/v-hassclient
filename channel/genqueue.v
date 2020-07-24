module channel

// struct FastQueue<T> {
// mut:
// 	read_index		int 		
// 	write_index		int 	
// 	q        []&T
// pub:
// 	max_size int
// pub mut:
// 	size     int
// }

// pub fn (mut q FastQueue<T>) push<T>(mut item &T) ?bool {
// 	if q.full() {
// 		return error("queue is full")
// 	}

// 	q.q[q.write_index] = item

// 	q.write_index++
// 	q.size++

// 	if q.write_index == q.max_size
// 	{
// 		q.write_index = 0
// 	}
// 	return true
// }

// // pop reads on item from queue
// pub fn (mut q FastQueue<T>) pop<T>() ?&T {

// 	if q.empty() {return error('queue is empty')}

// 	item := q.q[q.read_index]

// 	q.read_index++
// 	q.size--

// 	if q.read_index == q.max_size
// 	{
// 		q.read_index = 0
// 	}
// 	return item
// }

// [inline]
// // full returns true if queue is full
// fn (q FastQueue) full() bool {
// 	return q.size == q.max_size
// }

// [inline]
// // full returns true if queue is full
// fn (q FastQueue) empty() bool {
// 	return q.size == 0
// }


// //new_queue instance a new queue with static max_size
// pub fn new_fast_queue<T>(max_size int) &FastQueue<T> {
// 	arr := &FastQueue<T>{max_size: max_size}
// 	return arr
// }

// pub fn new_fast_queue<T>(max_size int) T {
//     mut arr := T{}
//     return arr
// }

// struct Queue<T> {
// pub:
// 	// max size of queue
// 	max_size int
// pub mut:
// 	// list of T items
// 	q        []&T
// 	// actual size of queue
// 	size     int
// }

// pub fn new_queue<T>(max_size int) &FastQueue<T> {
//     mut queue := &FastQueue<T>{max_size: max_size}
//     return queue
// }