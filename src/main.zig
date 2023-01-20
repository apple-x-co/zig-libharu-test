const std = @import("std");
const font_demo = @import("demo/font_demo.zig");
const text_demo = @import("demo/text_demo.zig");
const text_demo2 = @import("demo/text_demo2.zig");
const ttfont_demo = @import("demo/ttfont_demo.zig");
const ttfont_demo_jp = @import("demo/ttfont_demo_jp.zig");
const jpfont_demo = @import("demo/jpfont_demo.zig");
const image_demo = @import("demo/image_demo.zig");
const jpeg_demo = @import("demo/jpeg_demo.zig");
const png_demo = @import("demo/png_demo.zig");
const raw_image_demo = @import("demo/raw_image_demo.zig");
const arc_demo = @import("demo/arc_demo.zig");
const ext_gstate_demo = @import("demo/ext_gstate_demo.zig");
const line_demo = @import("demo/line_demo.zig");
const link_annotation = @import("demo/link_annotation.zig");

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
    try image_demo.run();
    try jpeg_demo.run();
    try png_demo.run();
    try raw_image_demo.run();
    try arc_demo.run();
    try ext_gstate_demo.run();
    try line_demo.run();
    try link_annotation.run();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}
