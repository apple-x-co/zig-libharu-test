const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/font_demo.c
pub fn run() !void {
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
        var c_font_name = std.mem.span(@as([*:0]const u8, @ptrCast(font_name)));
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
}
