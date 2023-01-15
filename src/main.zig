const std = @import("std");
const font_demo = @import("demo/font_demo.zig");
const text_demo = @import("demo/text_demo.zig");
const text_demo2 = @import("demo/text_demo2.zig");
const ttfont_demo = @import("demo/ttfont_demo.zig");
const ttfont_demo_jp = @import("demo/ttfont_demo_jp.zig");
const jpfont_demo = @import("demo/jpfont_demo.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try font_demo.run();
    try text_demo.run();
    try text_demo2.run();
    try ttfont_demo.run();
    try ttfont_demo_jp.run();
    try jpfont_demo.run();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}
