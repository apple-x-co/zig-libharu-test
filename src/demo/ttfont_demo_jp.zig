const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/ttfont_demo_jp.c
pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath("./src/demo/mbtexts/sjis.txt", &path_buffer);
    // try stdout.print("{s}\n", .{path});

    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const stats = try file.stat();
    const required_size = stats.size;
    // try stdout.print("required_size:{}\n", .{required_size});

    const content = try file.readToEndAlloc(allocator, required_size);
    defer allocator.free(content);
    // try stdout.print("content:{s}\n", .{content});

    var samp_text = try std.fmt.allocPrintZ(allocator, "{s}", .{content});
    defer allocator.free(samp_text);

    const pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    // declaration for using Japanese encoding.
    // _ = c.HPDF_UseJPFonts(pdf);
    _ = c.HPDF_UseJPEncodings(pdf);
    _ = c.HPDF_SetCurrentEncoder(pdf, "90msp-RKSJ-H");

    _ = c.HPDF_SetCompressionMode(pdf, c.HPDF_COMP_ALL);

    // load ttc file
    const detail_font_name = c.HPDF_LoadTTFontFromFile(pdf, "./fonts/MPLUS1p-Thin.ttf", c.HPDF_TRUE);
    // const detail_font_name = "MS-Gothic";

    // add a new page object. */
    const page = c.HPDF_AddPage(pdf);

    const title_font = c.HPDF_GetFont(pdf, "Helvetica", null);

    const detail_font = c.HPDF_GetFont(pdf, detail_font_name, "90msp-RKSJ-H");

    _ = c.HPDF_Page_SetFontAndSize(page, title_font, 10);

    _ = c.HPDF_Page_BeginText(page);

    // move the position of the text to top of the page.
    _ = c.HPDF_Page_MoveTextPos(page, 10, 190);
    _ = c.HPDF_Page_ShowText(page, detail_font_name);
    _ = c.HPDF_Page_ShowText(page, " (");
    _ = c.HPDF_Page_ShowText(page, c.HPDF_Font_GetEncodingName(detail_font));
    _ = c.HPDF_Page_ShowText(page, ")");

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 15);
    _ = c.HPDF_Page_MoveTextPos(page, 10, -20);
    _ = c.HPDF_Page_ShowText(page, "abcdefghijklmnopqrstuvwxyz");
    _ = c.HPDF_Page_MoveTextPos(page, 0, -20);
    _ = c.HPDF_Page_ShowText(page, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    _ = c.HPDF_Page_MoveTextPos(page, 0, -20);
    _ = c.HPDF_Page_ShowText(page, "1234567890");
    _ = c.HPDF_Page_MoveTextPos(page, 0, -20);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 10);
    _ = c.HPDF_Page_ShowText(page, samp_text.ptr);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -18);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 16);
    _ = c.HPDF_Page_ShowText(page, samp_text.ptr);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -27);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 23);
    _ = c.HPDF_Page_ShowText(page, samp_text.ptr);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -36);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 30);
    _ = c.HPDF_Page_ShowText(page, samp_text.ptr);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -36);

    const pw = c.HPDF_Page_TextWidth(page, samp_text.ptr);
    const page_width: f32 = pw + 40.0;
    const page_height: f32 = 210.0;

    _ = c.HPDF_Page_SetWidth(page, page_width);
    _ = c.HPDF_Page_SetHeight(page, page_height);

    // finish to print text.
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetLineWidth(page, 0.5);

    _ = c.HPDF_Page_MoveTo(page, 10, page_height - 25);
    _ = c.HPDF_Page_LineTo(page, page_width - 10, page_height - 25);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_MoveTo(page, 10, page_height - 85);
    _ = c.HPDF_Page_LineTo(page, page_width - 10, page_height - 85);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_SaveToFile(pdf, "output/ttfont_demo_jp.pdf");

    // try bw.flush(); // don't forget to flush!
}
