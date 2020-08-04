import channel

struct Item {
	nr int = 0
}

fn get_item(nr int) &Item {
	return &Item{
		nr: nr
	}
}

fn test_insert_read_one_item() {
	mut ch := channel.new_buffered_channel(1) or {
		panic(err)
	}
	go write_channel(mut ch, 1)
	it_ptr := ch.read() or {
		panic(err)
	}
	item := &Item(it_ptr)
	assert item.nr == 1
}

fn write_channel(mut ch channel.Channel, i int) {
	item := get_item(i)
	ch.write(item) or {
		panic(err)
	}
}
