const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/ttfont_demo.c
pub fn run() !void {
    const SAMP_TXT = "The quick brown fox jumps over the lazy dog.";

    var pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    // Add a new page object.
    var page = c.HPDF_AddPage(pdf);

    const title_font = c.HPDF_GetFont(pdf, "Helvetica", null);

    const detail_font_name = c.HPDF_LoadTTFontFromFile(pdf, "./fonts/JetBrainsMono-Thin.ttf", c.HPDF_TRUE);
    const detail_font = c.HPDF_GetFont(pdf, detail_font_name, null);

    _ = c.HPDF_Page_SetFontAndSize(page, title_font, 10);

    _ = c.HPDF_Page_BeginText(page);

    // Move the position of the text to top of the page.
    _ = c.HPDF_Page_MoveTextPos(page, 10, 190);
    _ = c.HPDF_Page_ShowText(page, detail_font_name);

    _ = c.HPDF_Page_ShowText(page, "(Embedded Subset)");

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 15);
    _ = c.HPDF_Page_MoveTextPos(page, 10, -20);
    _ = c.HPDF_Page_ShowText(page, "abcdefghijklmnopqrstuvwxyz");
    _ = c.HPDF_Page_MoveTextPos(page, 0, -20);
    _ = c.HPDF_Page_ShowText(page, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    _ = c.HPDF_Page_MoveTextPos(page, 0, -20);
    _ = c.HPDF_Page_ShowText(page, "1234567890");
    _ = c.HPDF_Page_MoveTextPos(page, 0, -20);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 10);
    _ = c.HPDF_Page_ShowText(page, SAMP_TXT);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -18);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 16);
    _ = c.HPDF_Page_ShowText(page, SAMP_TXT);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -27);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 23);
    _ = c.HPDF_Page_ShowText(page, SAMP_TXT);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -36);

    _ = c.HPDF_Page_SetFontAndSize(page, detail_font, 30);
    _ = c.HPDF_Page_ShowText(page, SAMP_TXT);
    _ = c.HPDF_Page_MoveTextPos(page, 0, -36);

    var pw = c.HPDF_Page_TextWidth(page, SAMP_TXT);
    const page_height = 210;
    const page_width = pw + 40;

    _ = c.HPDF_Page_SetWidth(page, page_width);
    _ = c.HPDF_Page_SetHeight(page, page_height);

    // Finish to print text
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetLineWidth(page, 0.5);

    _ = c.HPDF_Page_MoveTo(page, 10, page_height - 25);
    _ = c.HPDF_Page_LineTo(page, page_width - 10, page_height - 25);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_MoveTo(page, 10, page_height - 85);
    _ = c.HPDF_Page_LineTo(page, page_width - 10, page_height - 85);
    _ = c.HPDF_Page_Stroke(page);

    // save the document to a file
    _ = c.HPDF_SaveToFile(pdf, "./output/ttfont_demo.pdf");
}