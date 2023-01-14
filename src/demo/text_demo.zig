const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});
const grid = @import("grid.zig");

// https://github.com/libharu/libharu/blob/master/demo/text_demo.c
pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const samp_text = "abcdefgABCDEFG123!#$%&+-@?";
    const samp_text2 = "The quick brown fox jumps over the lazy dog.";

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
    grid.print(pdf, page);

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
        var len = c.HPDF_Page_MeasureText(page, samp_text, c.HPDF_Page_GetWidth(page) - 120, c.HPDF_FALSE, null);

        // truncate the text.
        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{samp_text[0..len]});
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
    var len = samp_text.len;
    while (i < len) : (i += 1) {
        var r: f32 = @intToFloat(f32, i) / @intToFloat(f32, len);
        var g: f32 = 1.0 - @intToFloat(f32, i) / @intToFloat(f32, len);

        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{samp_text[i .. i + 1]});
        defer allocator.free(text);

        _ = c.HPDF_Page_SetRGBFill(page, r, g, 0.0);
        _ = c.HPDF_Page_ShowText(page, text.ptr);
    }
    _ = c.HPDF_Page_MoveTextPos(page, 0, -25);

    i = 0;
    while (i < len) : (i += 1) {
        var r: f32 = @intToFloat(f32, i) / @intToFloat(f32, len);
        var b: f32 = 1.0 - @intToFloat(f32, i) / @intToFloat(f32, len);

        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{samp_text[i .. i + 1]});
        defer allocator.free(text);

        _ = c.HPDF_Page_SetRGBFill(page, r, 1.0, b);
        _ = c.HPDF_Page_ShowText(page, text.ptr);
    }
    _ = c.HPDF_Page_MoveTextPos(page, 0, -25);

    i = 0;
    while (i < len) : (i += 1) {
        var b: f32 = @intToFloat(f32, i) / @intToFloat(f32, len);
        var g: f32 = 1.0 - @intToFloat(f32, i) / @intToFloat(f32, len);

        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{samp_text[i .. i + 1]});
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

    // PDF_STROKE
    show_description(page, 60, ypos - 50, "RenderingMode=PDF_STROKE");
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_STROKE);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, ypos - 50, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);

    // PDF_FILL_THEN_STROKE
    show_description(page, 60, ypos - 100, "RenderingMode=PDF_FILL_THEN_STROKE");
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_FILL_THEN_STROKE);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, ypos - 100, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);

    // PDF_FILL_CLIPPING
    show_description(page, 60, ypos - 150, "RenderingMode=PDF_FILL_CLIPPING");
    _ = c.HPDF_Page_GSave(page);
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_FILL_CLIPPING);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, ypos - 150, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);
    show_stripe_pattern(page, 60, ypos - 150);
    _ = c.HPDF_Page_GRestore(page);

    // PDF_STROKE_CLIPPING
    show_description(page, 60, ypos - 200, "RenderingMode=PDF_STROKE_CLIPPING");
    _ = c.HPDF_Page_GSave(page);
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_STROKE_CLIPPING);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, ypos - 200, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);
    show_stripe_pattern(page, 60, ypos - 200);
    _ = c.HPDF_Page_GRestore(page);

    // /* PDF_FILL_STROKE_CLIPPING */
    show_description(page, 60, ypos - 250, "RenderingMode=PDF_FILL_STROKE_CLIPPING");
    _ = c.HPDF_Page_GSave(page);
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_FILL_STROKE_CLIPPING);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, ypos - 250, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);
    show_stripe_pattern(page, 60, ypos - 250);
    _ = c.HPDF_Page_GRestore(page);

    // Reset text attributes */
    _ = c.HPDF_Page_SetTextRenderingMode(page, c.HPDF_FILL);
    _ = c.HPDF_Page_SetRGBFill(page, 0, 0, 0);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 30);

    // Rotating text
    var angle1: f32 = 30; // A rotation of 30 degrees.
    var rad1: f32 = angle1 / 180.0 * 3.141592; // Calculate the radian value.

    show_description(page, 320, ypos - 60, "Rotating text");
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetTextMatrix(page, @cos(rad1), @sin(rad1), -@sin(rad1), @cos(rad1), 330, ypos - 60);
    _ = c.HPDF_Page_ShowText(page, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);

    // Skewing text.
    show_description(page, 320, ypos - 120, "Skewing text");
    _ = c.HPDF_Page_BeginText(page);

    angle1 = 10;
    var angle2: f32 = 20.0;
    rad1 = angle1 / 180.0 * 3.141592;
    var rad2: f32 = angle2 / 180.0 * 3.141592;

    _ = c.HPDF_Page_SetTextMatrix(page, 1, @tan(rad1), @tan(rad2), 1, 320, ypos - 120);
    _ = c.HPDF_Page_ShowText(page, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);

    // scaling text (X direction)
    show_description(page, 320, ypos - 175, "Scaling text (X direction)");
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetTextMatrix(page, 1.5, 0, 0, 1, 320, ypos - 175);
    _ = c.HPDF_Page_ShowText(page, "ABCabc12");
    _ = c.HPDF_Page_EndText(page);

    // scaling text (Y direction)
    show_description(page, 320, ypos - 250, "Scaling text (Y direction)");
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetTextMatrix(page, 1, 0, 0, 2, 320, ypos - 250);
    _ = c.HPDF_Page_ShowText(page, "ABCabc123");
    _ = c.HPDF_Page_EndText(page);

    // char spacing, word spacing
    show_description(page, 60, 140, "char-spacing 0");
    show_description(page, 60, 100, "char-spacing 1.5");
    show_description(page, 60, 60, "char-spacing 1.5, word-spacing 2.5");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 20);
    _ = c.HPDF_Page_SetRGBFill(page, 0.1, 0.3, 0.1);

    // char-spacing 0
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, 140, samp_text2);
    _ = c.HPDF_Page_EndText(page);

    // char-spacing 1.5
    _ = c.HPDF_Page_SetCharSpace(page, 1.5);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, 100, samp_text2);
    _ = c.HPDF_Page_EndText(page);

    // char-spacing 1.5, word-spacing 3.5
    _ = c.HPDF_Page_SetWordSpace(page, 2.5);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, 60, 60, samp_text2);
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

fn show_stripe_pattern(page: c.HPDF_Page, x: c.HPDF_REAL, y: c.HPDF_REAL) void {
    var iy: c.HPDF_REAL = 0;

    while (iy < 50) : (iy += 3) {
        _ = c.HPDF_Page_SetRGBStroke(page, 0.0, 0.0, 0.5);
        _ = c.HPDF_Page_SetLineWidth(page, 1);
        _ = c.HPDF_Page_MoveTo(page, x, y + iy);
        _ = c.HPDF_Page_LineTo(page, x + c.HPDF_Page_TextWidth(page, "ABCabc123"), y + iy);
        _ = c.HPDF_Page_Stroke(page);
    }

    _ = c.HPDF_Page_SetLineWidth(page, 2.5);
}
