module channel

struct Item {
	nr int = 0
}

fn get_item(nr int) &Item {
	return &Item {nr: nr}
}

fn test_instanse() {
	q := channel.new_queue(10) or {panic(err)}

	q.push(get_item(1)) or {panic(err)}

	i2 := q.pop() or {panic(err)}
	item := &Item(i2)
	assert item.nr == 1
}

fn test_queue_full() {
	q := channel.new_queue(5) or {panic(err)}

	q.push(get_item(1)) or {panic(err)}
	q.push(get_item(2)) or {panic(err)}
	q.push(get_item(3)) or {panic(err)}
	q.push(get_item(4)) or {panic(err)}
	q.push(get_item(5)) or {panic(err)}
	assert q.full() == true
	// Bug in V that does segment fault if I do not do one pop
	i2 := q.pop() or {panic(err)}
}

fn test_queue_error_when_push_full() {
	q := channel.new_queue(2) or {panic(err)}

	q.push(get_item(1)) or {panic(err)}
	q.push(get_item(2)) or {panic(err)}

	q.push(get_item(3)) or
	{
		assert err == 'queue is full'
		// Bug in V that does segment fault if I do not do one pop
		i2 := q.pop() or {panic(err)}
		return
	}

	assert false
}

fn test_queue_error_when_pop_empty() {
	q := channel.new_queue(2) or {panic(err)}
	q.pop() or
	{
		assert err == 'queue is empty'
		return
	}
	assert false
}

fn test_queue_new_queue_zero_size() {
	q := channel.new_queue(0) or
	{
		assert err == 'max_size have to be greater than zero'
		return
	}

	assert false
}

// test the whole circle around
fn test_queue_sequential_push_pop() {
	q := channel.new_queue(2) or {panic(err)}

	for i := 0; i < 10; i++ {
		q.push(get_item(1)) or {panic(err)}
		assert q.size == 1
		item := q.pop() or {panic(err)}
	    assert q.size == 0
	}
}

fn test_queue_sequential_push_pop_single_sized() {
	q := channel.new_queue(1) or {panic(err)}

	for i := 0; i < 10; i++ {
		q.push(get_item(1)) or {panic(err)}
		assert q.size == 1
		item := q.pop() or {panic(err)}
	    assert q.size == 0
	}
}


// test the whole circle around and checks values are correct too
fn test_queue_sequential_push_pop_advanced() {
	q := channel.new_queue(4) or {panic(err)}

	for i := 0; i < 100; i++ {
		q.push(get_item(1)) or {panic(err)}
		assert q.size == 1
		q.push(get_item(2)) or {panic(err)}
		assert q.size == 2

		i1 := q.pop() or {panic(err)}
		i2 := q.pop() or {panic(err)}
		item1 := &Item(i1)
		item2 := &Item(i2)
		assert item1.nr == 1
		assert item2.nr == 2

	    assert q.size == 0
	}
}