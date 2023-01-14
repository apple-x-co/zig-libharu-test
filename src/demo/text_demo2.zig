const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});
const grid = @import("grid.zig");

// https://github.com/libharu/libharu/blob/master/demo/text_demo2.c
pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const SAMP_TXT = "The quick brown fox jumps over the lazy dog. ";

    var pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    // Add a new page object.
    var page = c.HPDF_AddPage(pdf);
    _ = c.HPDF_Page_SetSize(page, c.HPDF_PAGE_SIZE_A5, c.HPDF_PAGE_PORTRAIT);

    // draw grid to the page
    grid.print(pdf, page);

    var font = c.HPDF_GetFont(pdf, "Helvetica", null);
    _ = c.HPDF_Page_SetTextLeading(page, 20);

    // HPDF_TALIGN_LEFT
    var rect: c.HPDF_Rect = c.HPDF_Rect{
        .left = 25,
        .top = 545,
        .right = 200,
        .bottom = 505,
    };

    _ = c.HPDF_Page_Rectangle(page, rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);
    _ = c.HPDF_Page_TextOut(page, rect.left, rect.top + 3, "HPDF_TALIGN_LEFT");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 13);
    _ = c.HPDF_Page_TextRect(page, rect.left, rect.top, rect.right, rect.bottom, SAMP_TXT, c.HPDF_TALIGN_LEFT, null);

    _ = c.HPDF_Page_EndText(page);

    // HPDF_TALIGN_RIGTH
    rect.left = 220;
    rect.right = 395;

    _ = c.HPDF_Page_Rectangle(page, rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);
    _ = c.HPDF_Page_TextOut(page, rect.left, rect.top + 3, "HPDF_TALIGN_RIGTH");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 13);
    _ = c.HPDF_Page_TextRect(page, rect.left, rect.top, rect.right, rect.bottom, SAMP_TXT, c.HPDF_TALIGN_RIGHT, null);

    _ = c.HPDF_Page_EndText(page);

    // HPDF_TALIGN_CENTER
    rect.left = 25;
    rect.top = 475;
    rect.right = 200;
    rect.bottom = rect.top - 40;

    _ = c.HPDF_Page_Rectangle(page, rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);
    _ = c.HPDF_Page_TextOut(page, rect.left, rect.top + 3, "HPDF_TALIGN_CENTER");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 13);
    _ = c.HPDF_Page_TextRect(page, rect.left, rect.top, rect.right, rect.bottom, SAMP_TXT, c.HPDF_TALIGN_CENTER, null);

    _ = c.HPDF_Page_EndText(page);

    // HPDF_TALIGN_JUSTIFY
    rect.left = 220;
    rect.right = 395;

    _ = c.HPDF_Page_Rectangle(page, rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);
    _ = c.HPDF_Page_TextOut(page, rect.left, rect.top + 3, "HPDF_TALIGN_JUSTIFY");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 13);
    _ = c.HPDF_Page_TextRect(page, rect.left, rect.top, rect.right, rect.bottom, SAMP_TXT, c.HPDF_TALIGN_JUSTIFY, null);

    _ = c.HPDF_Page_EndText(page);

    // Skewed coordinate system
    _ = c.HPDF_Page_GSave(page);

    var angle1: f32 = 5;
    var angle2: f32 = 10;
    var rad1: f32 = angle1 / 180 * 3.141592;
    var rad2: f32 = angle2 / 180 * 3.141592;

    _ = c.HPDF_Page_Concat(page, 1, @tan(rad1), @tan(rad2), 1, 25, 350);
    rect.left = 0;
    rect.top = 40;
    rect.right = 175;
    rect.bottom = 0;

    _ = c.HPDF_Page_Rectangle(page, rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);
    _ = c.HPDF_Page_TextOut(page, rect.left, rect.top + 3, "Skewed coordinate system");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 13);
    _ = c.HPDF_Page_TextRect(page, rect.left, rect.top, rect.right, rect.bottom, SAMP_TXT, c.HPDF_TALIGN_LEFT, null);

    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_GRestore(page);

    // Rotated coordinate system
    _ = c.HPDF_Page_GSave(page);

    angle1 = 5;
    rad1 = angle1 / 180 * 3.141592;

    _ = c.HPDF_Page_Concat(page, @cos(rad1), @sin(rad1), -@sin(rad1), @cos(rad1), 220, 350);
    rect.left = 0;
    rect.top = 40;
    rect.right = 175;
    rect.bottom = 0;

    _ = c.HPDF_Page_Rectangle(page, rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);
    _ = c.HPDF_Page_TextOut(page, rect.left, rect.top + 3, "Rotated coordinate system");

    _ = c.HPDF_Page_SetFontAndSize(page, font, 13);
    _ = c.HPDF_Page_TextRect(page, rect.left, rect.top, rect.right, rect.bottom, SAMP_TXT, c.HPDF_TALIGN_LEFT, null);

    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_GRestore(page);

    // text along a circle
    _ = c.HPDF_Page_SetGrayStroke(page, 0);
    _ = c.HPDF_Page_Circle(page, 210, 190, 145);
    _ = c.HPDF_Page_Circle(page, 210, 190, 113);
    _ = c.HPDF_Page_Stroke(page);

    angle1 = 360 / SAMP_TXT.len;
    angle2 = 180;

    _ = c.HPDF_Page_BeginText(page);
    font = c.HPDF_GetFont(pdf, "Courier-Bold", null);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 30);

    var i: u64 = 0;
    var len = SAMP_TXT.len;
    while (i < len) : (i += 1) {
        rad1 = (angle2 - 90) / 180 * 3.141592;
        rad2 = angle2 / 180 * 3.141592;

        var x: f32 = 210 + @cos(rad2) * 122;
        var y: f32 = 190 + @sin(rad2) * 122;

        _ = c.HPDF_Page_SetTextMatrix(page, @cos(rad1), @sin(rad1), -@sin(rad1), @cos(rad1), x, y);

        var text = try std.fmt.allocPrintZ(allocator, "{s}", .{SAMP_TXT[i .. i + 1]});
        defer allocator.free(text);

        _ = c.HPDF_Page_ShowText(page, text.ptr);

        angle2 -= angle1;
    }

    _ = c.HPDF_Page_EndText(page);

    // save the document to a file
    _ = c.HPDF_SaveToFile(pdf, "./output/text_demo2.pdf");
}
