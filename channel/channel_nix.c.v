module channel

#include <pthread.h>
// fn C.pthread_cond_init(c &C.pthread_cond_t, m &C.pthread_mutex_t) int
fn C.pthread_cond_destroy(c &C.pthread_cond_t) int

// fn C.pthread_cond_wait(c &C.pthread_cond_t, m &C.pthread_mutex_t) int
// fn C.pthread_cond_signal(c &C.pthread_cond_t) int
fn C.pthread_cond_broadcast(c &C.pthread_cond_t) int

fn C.pthread_mutex_destroy(m &C.pthread_mutex_t) int

#flag -lpthread
[ref_only]
pub struct Channel {
mut:
	queue     &Queue
	mt        C.pthread_mutex_t
	r_cond    C.pthread_cond_t
	w_cond    C.pthread_cond_t
	w_waiting int = 0
	r_waiting int = 0
	buffered  bool = false
}

pub fn new_buffered_channel(size int) ?&Channel {
	mut q := new_queue(size) or {
		return error(err)
	}
	mut ch := &Channel{
		queue: q
		buffered: true
	}
	if C.pthread_mutex_init(&ch.mt, C.NULL) != 0 {
		return error('Failed to init mutex')
	}
	if C.pthread_cond_init(&ch.r_cond, C.NULL) != 0 {
		return error('Failed to init read cond')
	}
	if C.pthread_cond_init(&ch.w_cond, C.NULL) != 0 {
		return error('Failed to init write cond')
	}
	return ch
}

// write, writes an item to channel. channel will block if full
// v-bug makes me use bool until just return otional works
pub fn (mut c Channel) write(item voidptr) ?bool {
	C.pthread_mutex_lock(&c.mt)
	defer {
		C.pthread_mutex_unlock(&c.mt)
	}
	if c.buffered {
		for c.queue.size == c.queue.max_size {
			c.w_waiting++
			if C.pthread_cond_wait(&c.w_cond, &c.mt) != 0 {
				c.w_waiting--
				return error('err or in waiting for write conditional')
			}
			c.w_waiting--
		}
		c.queue.push(item) or {
			return error(err)
		}
		if c.r_waiting > 0 {
			if C.pthread_cond_signal(&c.r_cond) != 0 {
				return error('failed to set signal for read condiational')
			}
		}
	}
	return true
}

// read, reads next item, blocks until there are an item to read
pub fn (mut c Channel) read() ?voidptr {
	C.pthread_mutex_lock(&c.mt)
	defer {
		C.pthread_mutex_unlock(&c.mt)
	}
	if c.buffered {
		for c.queue.size == 0 {
			c.r_waiting++
			if C.pthread_cond_wait(&c.r_cond, &c.mt) != 0 {
				c.r_waiting--
				return error('err or in waiting for read conditional')
			}
			c.r_waiting--
		}
		item := c.queue.pop() or {
			return error(err)
		}
		if c.w_waiting > 0 {
			if C.pthread_cond_signal(&c.w_cond) != 0 {
				return error('failed to set signal for read condiational')
			}
		}
		return item
	}
	return error('only buffered supported')
}
