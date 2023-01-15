const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/jpfont_demo.c
pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    const PAGE_HEIGHT = 210;

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

    // configure pdf-document to be compressed.
    _ = c.HPDF_SetCompressionMode(pdf, c.HPDF_COMP_ALL);

    // declaration for using Japanese font, encoding.
    _ = c.HPDF_UseJPEncodings(pdf);
    _ = c.HPDF_UseJPFonts(pdf);

    const detail_font: [16]c.HPDF_Font = .{
        c.HPDF_GetFont(pdf, "MS-Mincho", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-Mincho,Bold", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-Mincho,Italic", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-Mincho,BoldItalic", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PMincho", "90msp-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PMincho,Bold", "90msp-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PMincho,Italic", "90msp-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PMincho,BoldItalic", "90msp-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-Gothic", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-Gothic,Bold", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-Gothic,Italic", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-Gothic,BoldItalic", "90ms-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PGothic", "90msp-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PGothic,Bold", "90msp-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PGothic,Italic", "90msp-RKSJ-H"),
        c.HPDF_GetFont(pdf, "MS-PGothic,BoldItalic", "90msp-RKSJ-H"),
    };

    // Set page mode to use outlines.
    _ = c.HPDF_SetPageMode(pdf, c.HPDF_PAGE_MODE_USE_OUTLINE);

    // create outline root.
    const root = c.HPDF_CreateOutline(pdf, null, "JP font demo", null);
    _ = c.HPDF_Outline_SetOpened(root, c.HPDF_TRUE);

    var i: u64 = 0;
    while (i <= 15) : (i += 1) {
        // add a new page object.
        const page = c.HPDF_AddPage(pdf);

        // create outline entry
        const outline = c.HPDF_CreateOutline(pdf, root, c.HPDF_Font_GetFontName(detail_font[i]), null);
        const dst = c.HPDF_Page_CreateDestination(page);
        _ = c.HPDF_Outline_SetDestination(outline, dst);

        const title_font = c.HPDF_GetFont(pdf, "Helvetica", null);
        _ = c.HPDF_Page_SetFontAndSize(page, title_font, 10);

        _ = c.HPDF_Page_BeginText(page);

        // move the position of the text to top of the page.
        _ = c.HPDF_Page_MoveTextPos(page, 10, 190);
        _ = c.HPDF_Page_ShowText(page, c.HPDF_Font_GetFontName(detail_font[i]));

        _ = c.HPDF_Page_SetFontAndSize(page, detail_font[i], 15);
        _ = c.HPDF_Page_MoveTextPos(page, 10, -20);
        _ = c.HPDF_Page_ShowText(page, "abcdefghijklmnopqrstuvwxyz");
        _ = c.HPDF_Page_MoveTextPos(page, 0, -20);
        _ = c.HPDF_Page_ShowText(page, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        _ = c.HPDF_Page_MoveTextPos(page, 0, -20);
        _ = c.HPDF_Page_ShowText(page, "1234567890");
        _ = c.HPDF_Page_MoveTextPos(page, 0, -20);

        _ = c.HPDF_Page_SetFontAndSize(page, detail_font[i], 10);
        _ = c.HPDF_Page_ShowText(page, samp_text.ptr);
        _ = c.HPDF_Page_MoveTextPos(page, 0, -18);

        _ = c.HPDF_Page_SetFontAndSize(page, detail_font[i], 16);
        _ = c.HPDF_Page_ShowText(page, samp_text.ptr);
        _ = c.HPDF_Page_MoveTextPos(page, 0, -27);

        _ = c.HPDF_Page_SetFontAndSize(page, detail_font[i], 23);
        _ = c.HPDF_Page_ShowText(page, samp_text.ptr);
        _ = c.HPDF_Page_MoveTextPos(page, 0, -36);

        _ = c.HPDF_Page_SetFontAndSize(page, detail_font[i], 30);
        _ = c.HPDF_Page_ShowText(page, samp_text.ptr);

        const p = c.HPDF_Page_GetCurrentTextPos(page);

        // finish to print text.
        _ = c.HPDF_Page_EndText(page);

        _ = c.HPDF_Page_SetLineWidth(page, 0.5);

        var x_pos: f32 = 20;
        var j: u64 = 0;
        const len = samp_text.len;
        while (j <= len) : (j += 2) {
            _ = c.HPDF_Page_MoveTo(page, x_pos, p.y - 10);
            _ = c.HPDF_Page_LineTo(page, x_pos, p.y - 12);
            _ = c.HPDF_Page_Stroke(page);
            x_pos = x_pos + 30;
        }

        _ = c.HPDF_Page_SetWidth(page, p.x + 20);
        _ = c.HPDF_Page_SetHeight(page, PAGE_HEIGHT);

        _ = c.HPDF_Page_MoveTo(page, 10, PAGE_HEIGHT - 25);
        _ = c.HPDF_Page_LineTo(page, p.x + 10, PAGE_HEIGHT - 25);
        _ = c.HPDF_Page_Stroke(page);

        _ = c.HPDF_Page_MoveTo(page, 10, PAGE_HEIGHT - 85);
        _ = c.HPDF_Page_LineTo(page, p.x + 10, PAGE_HEIGHT - 85);
        _ = c.HPDF_Page_Stroke(page);

        _ = c.HPDF_Page_MoveTo(page, 10, p.y - 12);
        _ = c.HPDF_Page_LineTo(page, p.x + 10, p.y - 12);
        _ = c.HPDF_Page_Stroke(page);
    }

    _ = c.HPDF_SaveToFile(pdf, "output/jpfont_demo.pdf");
}
