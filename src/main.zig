const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    //////////////////////////////////////
    // https://github.com/libharu/libharu/blob/master/demo/font_demo.c
    const page_title = "Font Demo";
    var pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    // Add a new page object.
    var page = c.HPDF_AddPage(pdf);

    const height = c.HPDF_Page_GetHeight(page);
    const width = c.HPDF_Page_GetWidth(page);

    // Print the lines of the page.
    _ = c.HPDF_Page_SetLineWidth(page, 1);
    _ = c.HPDF_Page_Rectangle(page, 50, 50, width - 100, height - 110);
    _ = c.HPDF_Page_Stroke(page);

    // Print the title of the page (with positioning center).
    const def_font = c.HPDF_GetFont(pdf, "Helvetica", null);
    _ = c.HPDF_Page_SetFontAndSize(page, def_font, 24);

    const tw = c.HPDF_Page_TextWidth(page, page_title);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, (width - tw) / 2, height - 50, page_title);
    _ = c.HPDF_Page_EndText(page);

    // output subtitle.
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetFontAndSize(page, def_font, 16);
    _ = c.HPDF_Page_TextOut(page, 60, height - 80, "<Standerd Type1 fonts samples>");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 60, height - 105);

    const font_list = [_][]const u8{
        "Courier",
        "Courier-Bold",
        "Courier-Oblique",
        "Courier-BoldOblique",
        "Helvetica",
        "Helvetica-Bold",
        "Helvetica-Oblique",
        "Helvetica-BoldOblique",
        "Times-Roman",
        "Times-Bold",
        "Times-Italic",
        "Times-BoldItalic",
        "Symbol",
        "ZapfDingbats",
    };

    const samp_text = "abcdefgABCDEFG12345!#$%&+-@?";

    for (font_list) |font_name| {
        try stdout.print("Font name: {s}\n", .{font_name});

        var c_font_name = std.mem.span(@ptrCast([*:0]const u8, font_name));
        var font = c.HPDF_GetFont(pdf, c_font_name.ptr, null);

        // print a label of text
        _ = c.HPDF_Page_SetFontAndSize(page, def_font, 9);
        _ = c.HPDF_Page_ShowText(page, c_font_name.ptr);
        _ = c.HPDF_Page_MoveTextPos(page, 0, -18);

        // print a sample text.
        _ = c.HPDF_Page_SetFontAndSize(page, font, 20);
        _ = c.HPDF_Page_ShowText(page, samp_text);
        _ = c.HPDF_Page_MoveTextPos(page, 0, -20);
    }

    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_SaveToFile(pdf, "./font_demo.pdf");
    //////////////////////////////////////

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

// pub fn error_handler() void {
// }

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
