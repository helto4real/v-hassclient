module channel

// basic queue implementation, uses voidptr now but will use generics when implemented
// the queue is implemented as a ringbuffer for fast and zero allocation of memory
// the queue it is not thread safe
struct Queue {
mut:
	read_index  int = 0
	write_index int = 0
	q           []voidptr
pub:
	max_size    int
pub mut:
	size        int
}

// push writes one item to queue
fn (mut q Queue) push(item voidptr) ? {
	if q.full() {
		return error('queue is full')
	}
	q.q[q.write_index] = item
	q.write_index++
	q.size++
	if q.write_index == q.max_size {
		q.write_index = 0
	}
}

// pop reads on item from queue
fn (mut q Queue) pop() ?voidptr {
	if q.empty() {
		return error('queue is empty')
	}
	item := q.q[q.read_index]
	q.read_index++
	q.size--
	if q.read_index == q.max_size {
		q.read_index = 0
	}
	return item
}

[inline]
// full returns true if queue is full
fn (q Queue) full() bool {
	return q.size == q.max_size
}

[inline]
// full returns true if queue is full
fn (q Queue) empty() bool {
	return q.size == 0
}

// new_queue instance a new queue with static max_size
fn new_queue(max_size int) ?&Queue {
	if max_size <= 0 {
		return error('max_size have to be greater than zero')
	}
	q := &Queue{
		q: []voidptr{len: max_size}
		max_size: max_size
	}
	return q
}
