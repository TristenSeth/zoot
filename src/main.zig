// This is the real entry point for our program. It simply jumps (or branches,
// using the `b` instruction) to our main function, `zigMain`, written
// in Zig below.
//
// One important thing here is that I place this code in the `.text.boot`
// section of the resulting object. The linker script, `simplest.ld`, makes sure
// this section is placed right at the beginning of the resulting binary. That's
// what I want, because the RockPro64 will start running from the beginning
// of the binary.
//
// Maybe important: the linker will look (by default) for the `_start` symbol as
// the program entry point. As far as I understand, though, this isn't relevant
// for this program, because the RockPro64 will start running from the first
// byte of the image. I am really defining the entry point by using the
// `.text.boot`, and `_start` is effectivelly ignored. However, the linker
// will complain if it can't find `_start`, so I define it here to make our
// tools happy. There's probably a more elegant way to do this...
const mmio = @import("mmio.zig");
const uart = @import("uart.zig");

fn delay() void {
    var def_delay: usize = 1000000;
    const ptr: *volatile usize = &def_delay;

    while (def_delay > 0) {
        ptr.* -= 1;
    }
}

fn talker() void {
    comptime var limit = 10;
    while (limit > 0) {
        uart.print("hello\n");
        limit -= 1;
    }
}

export fn zigMain() noreturn {
    uart.uartInit();
    delay();
    talker();
    unreachable;
}
