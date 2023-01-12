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

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

// pub fn error_handler() void {
// }

test "font_demo" {
    // https://github.com/libharu/libharu/blob/master/demo/font_demo.c

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

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

    // save the document to a file
    _ = c.HPDF_SaveToFile(pdf, "./output/font_demo.pdf");

    try bw.flush(); // don't forget to flush!
}

test "text_demo" {
    // https://github.com/libharu/libharu/blob/master/demo/text_demo.c

    const allocator = std.testing.allocator;

    const sample_text = "abcdefgABCDEFG123!#$%&+-@?";
    // const sample_text2 = "The quick brown fox jumps over the lazy dog.";

    const page_title = "Text Demo";
    var pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    // // set compression mode
    _ = c.HPDF_SetCompressionMode(pdf, c.HPDF_COMP_ALL);

    // create default-font
    const font = c.HPDF_GetFont(pdf, "Helvetica", null);

    // add a new page object.
    var page = c.HPDF_AddPage(pdf);

    // draw grid to the page
    // print_grid  (pdf, page);

    // print the title of the page (with positioning center).
    _ = c.HPDF_Page_SetFontAndSize(page, font, 24);
    var tw = c.HPDF_Page_TextWidth(page, page_title);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, (c.HPDF_Page_GetWidth(page) - tw) / 2, c.HPDF_Page_GetHeight(page) - 50, page_title);
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 60, c.HPDF_Page_GetHeight(page) - 60);

    // font size
    var fsize: f32 = 8.0;
    while (fsize < 60) : (fsize *= 1.5) {
        // set style and size of font.
        _ = c.HPDF_Page_SetFontAndSize(page, font, fsize);

        // set the position of the text.
        _ = c.HPDF_Page_MoveTextPos(page, 0, -5 - fsize);

        // measure the number of characters which included in the page.
        var len = c.HPDF_Page_MeasureText(page, sample_text, c.HPDF_Page_GetWidth(page) - 120, c.HPDF_FALSE, null);

        // truncate the text.
        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{sample_text[0..len]});
        defer allocator.free(text);
        _ = c.HPDF_Page_ShowText(page, text.ptr);

        // print the description.
        _ = c.HPDF_Page_MoveTextPos(page, 0, -10);
        _ = c.HPDF_Page_SetFontAndSize(page, font, 8);
        var text2 = try std.fmt.allocPrintZ(allocator, "Fontsize={d}", .{fsize});
        defer allocator.free(text2);
        _ = c.HPDF_Page_ShowText(page, text2.ptr);
        // var formatted = try std.fmt.bufPrint(&buf, "Fontsize={}", .{fsize});
        // var c_formatted = std.mem.span(@ptrCast([*:0]const u8, formatted));
        // _ = c.HPDF_Page_ShowText(page, c_formatted.ptr);
    }

    // font color
    _ = c.HPDF_Page_SetFontAndSize(page, font, 8);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -30);
    _ = c.HPDF_Page_ShowText(page, "Font color");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 18);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -20);

    var i: u64 = 0;
    var len = sample_text.len;
    while (i < len) : (i += 1) {
        var r: f32 = @intToFloat(f32, i) / @intToFloat(f32, len);
        var g: f32 = 1.0 - @intToFloat(f32, i) / @intToFloat(f32, len);

        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{sample_text[i .. i + 1]});
        defer allocator.free(text);

        _ = c.HPDF_Page_SetRGBFill(page, r, g, 0.0);
        _ = c.HPDF_Page_ShowText(page, text.ptr);
    }
    _ = c.HPDF_Page_MoveTextPos(page, 0, -25);

    i = 0;
    while (i < len) : (i += 1) {
        var r: f32 = @intToFloat(f32, i) / @intToFloat(f32, len);
        var b: f32 = 1.0 - @intToFloat(f32, i) / @intToFloat(f32, len);

        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{sample_text[i .. i + 1]});
        defer allocator.free(text);

        _ = c.HPDF_Page_SetRGBFill(page, r, 1.0, b);
        _ = c.HPDF_Page_ShowText(page, text.ptr);
    }
    _ = c.HPDF_Page_MoveTextPos(page, 0, -25);

    i = 0;
    while (i < len) : (i += 1) {
        var b: f32 = @intToFloat(f32, i) / @intToFloat(f32, len);
        var g: f32 = 1.0 - @intToFloat(f32, i) / @intToFloat(f32, len);

        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{sample_text[i .. i + 1]});
        defer allocator.free(text);

        _ = c.HPDF_Page_SetRGBFill(page, 1.0, g, b);
        _ = c.HPDF_Page_ShowText(page, text.ptr);
    }
    _ = c.HPDF_Page_MoveTextPos(page, 0, -25);

    _ = c.HPDF_Page_EndText(page);

    var ypos: c.HPDF_REAL = 450;

    // Font rendering mode
    _ = c.HPDF_Page_SetFontAndSize(page, font, 32);
    _ = c.HPDF_Page_SetRGBFill(page, 0.5, 0.5, 0.0);
    _ = c.HPDF_Page_SetLineWidth(page, 1.5);

    // PDF_FILL
    show_description(page, 60, ypos, "RenderingMode=PDF_FILL");
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_FILL);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, ypos, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);

    // save the document to a file
    _ = c.HPDF_SaveToFile(pdf, "./output/text_demo.pdf");
}

fn show_description(page: c.HPDF_Page, x: c.HPDF_REAL, y: c.HPDF_REAL, text: []const u8) void {
    const fsize = c.HPDF_Page_GetCurrentFontSize(page);
    const font = c.HPDF_Page_GetCurrentFont(page);
    const color = c.HPDF_Page_GetRGBFill(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetRGBFill(page, 0, 0, 0);
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_FILL);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);
    _ = c.HPDF_Page_TextOut(page, x, y - 12, text.ptr);
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, fsize);
    _ = c.HPDF_Page_SetRGBFill(page, color.r, color.g, color.b);
}
