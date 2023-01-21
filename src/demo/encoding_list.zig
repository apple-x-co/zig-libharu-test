const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

const PAGE_WIDTH: c.HPDF_REAL = 420;
const PAGE_HEIGHT: c.HPDF_REAL = 400;
const CELL_WIDTH: u32 = 20;
const CELL_HEIGHT: u32 = 20;
const CELL_HEADER: u32 = 10;

// https://github.com/libharu/libharu/blob/master/demo/encoding_list.c
// https://ziglang.org/documentation/master/#Primitive-Types
pub fn run() !void {
    const encodings = [_][]const u8{
        "StandardEncoding",
        "MacRomanEncoding",
        "WinAnsiEncoding",
        "ISO8859-2",
        "ISO8859-3",
        "ISO8859-4",
        "ISO8859-5",
        "ISO8859-9",
        "ISO8859-10",
        "ISO8859-13",
        "ISO8859-14",
        "ISO8859-15",
        "ISO8859-16",
        "CP1250",
        "CP1251",
        "CP1252",
        "CP1254",
        "CP1257",
        "KOI8-R",
        "Symbol-Set",
        "ZapfDingbats-Set",
    };

    const pdf = c.HPDF_NewEx(error_handler, null, null, 0, null);
    defer c.HPDF_Free(pdf);

    // /* set compression mode */
    _ = c.HPDF_SetCompressionMode(pdf, c.HPDF_COMP_ALL);

    // /* Set page mode to use outlines. */
    _ = c.HPDF_SetPageMode(pdf, c.HPDF_PAGE_MODE_USE_OUTLINE);

    // /* get default font */
    const font = c.HPDF_GetFont(pdf, "Helvetica", null);

    const font_name = c.HPDF_LoadType1FontFromFile(pdf, "src/demo/type1/a010013l.afm", "src/demo/type1//a010013l.pfb");

    // /* create outline root. */
    const root = c.HPDF_CreateOutline(pdf, null, "Encoding list", null);
    _ = c.HPDF_Outline_SetOpened(root, c.HPDF_TRUE);

    for (encodings) |encoding| {
        const page = c.HPDF_AddPage(pdf);

        _ = c.HPDF_Page_SetWidth(page, PAGE_WIDTH);
        _ = c.HPDF_Page_SetHeight(page, PAGE_HEIGHT);

        const outline = c.HPDF_CreateOutline(pdf, root, encoding.ptr, null);
        const dst = c.HPDF_Page_CreateDestination(page);
        _ = c.HPDF_Destination_SetXYZ(dst, 0, c.HPDF_Page_GetHeight(page), 1);
        // /* HPDF_Destination_SetFitB(dst); */
        _ = c.HPDF_Outline_SetDestination(outline, dst);

        _ = c.HPDF_Page_SetFontAndSize(page, font, 15);
        draw_graph(page);

        _ = c.HPDF_Page_BeginText(page);
        _ = c.HPDF_Page_SetFontAndSize(page, font, 20);
        _ = c.HPDF_Page_MoveTextPos(page, 40, PAGE_HEIGHT - 50);
        _ = c.HPDF_Page_ShowText(page, encoding.ptr);
        _ = c.HPDF_Page_ShowText(page, " Encoding");
        _ = c.HPDF_Page_EndText(page);

        var font2: c.HPDF_Font = undefined;
        if (std.mem.eql(u8, encoding, "Symbol-Set")) {
            font2 = c.HPDF_GetFont(pdf, "Symbol", null);
        } else if (std.mem.eql(u8, encoding, "ZapfDingbats-Set")) {
            font2 = c.HPDF_GetFont(pdf, "ZapfDingbats", null);
        } else {
            font2 = c.HPDF_GetFont(pdf, font_name, encoding.ptr);
        }

        _ = c.HPDF_Page_SetFontAndSize(page, font2, 14);
        draw_fonts(page);
    }

    // /* save the document to a file */
    _ = c.HPDF_SaveToFile(pdf, "output/encoding_list.pdf");
}

fn error_handler(error_no: c.HPDF_STATUS, detail_no: c.HPDF_STATUS, user_data: ?*anyopaque) callconv(.C) void {
    _ = user_data;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    stdout.print("ERROR: error_no={}, detail_no={}\n", .{ error_no, detail_no }) catch unreachable;

    bw.flush() catch unreachable;
}

fn draw_graph(page: c.HPDF_Page) void {
    var buf: [50]u8 = undefined;
    var i: u32 = 0;

    // /* Draw 16 X 15 cells */

    // /* Draw vertical lines. */
    _ = c.HPDF_Page_SetLineWidth(page, 0.5);

    while (i <= 17) : (i += 1) {
        const x = @intToFloat(f32, i * CELL_WIDTH + 40);

        _ = c.HPDF_Page_MoveTo(page, x, PAGE_HEIGHT - 60);
        _ = c.HPDF_Page_LineTo(page, x, 40);
        _ = c.HPDF_Page_Stroke(page);

        if (i > 0 and i <= 16) {
            _ = c.HPDF_Page_BeginText(page);
            _ = c.HPDF_Page_MoveTextPos(page, x + 5, PAGE_HEIGHT - 75);
            var text = std.fmt.bufPrintZ(&buf, "{X}", .{i - 1}) catch return;
            _ = c.HPDF_Page_ShowText(page, text.ptr);
            _ = c.HPDF_Page_EndText(page);
        }
    }

    // /* Draw horizontal lines. */
    i = 0;
    while (i <= 15) : (i += 1) {
        const y = @intToFloat(f32, i * CELL_HEIGHT + 40);

        _ = c.HPDF_Page_MoveTo(page, 40, y);
        _ = c.HPDF_Page_LineTo(page, PAGE_WIDTH - 40, y);
        _ = c.HPDF_Page_Stroke(page);

        if (i < 14) {
            _ = c.HPDF_Page_BeginText(page);
            _ = c.HPDF_Page_MoveTextPos(page, 45, y + 5);
            var text = std.fmt.bufPrintZ(&buf, "{X}", .{15 - i}) catch return;
            _ = c.HPDF_Page_ShowText(page, text.ptr);
            _ = c.HPDF_Page_EndText(page);
        }
    }
}

fn draw_fonts(page: c.HPDF_Page) void {
    _ = c.HPDF_Page_BeginText(page);

    // /* Draw all character from 0x20 to 0xFF to the canvas. */
    var i: u32 = 1;
    while (i < 17) : (i += 1) {
        var j: u32 = 1;
        while (j < 17) : (j += 1) {
            const y = PAGE_HEIGHT - 55 - ((@intToFloat(f32, i) - 1) * @intToFloat(f32, CELL_HEIGHT));
            const x = @intToFloat(f32, j) * @intToFloat(f32, CELL_WIDTH) + 50;

            // FIXME: 9行目以降が表示されない
            const char: u8 = @intCast(u8, (i - 1) * 16 + (j - 1));
            if (char >= 32) {
                var buf: [2]u8 = undefined;
                var text = std.fmt.bufPrintZ(&buf, "{u}", .{char}) catch "";
                const d = x - c.HPDF_Page_TextWidth(page, text.ptr) / 2;
                _ = c.HPDF_Page_TextOut(page, d, y, text.ptr);
            }
        }
    }

    _ = c.HPDF_Page_EndText(page);
}
