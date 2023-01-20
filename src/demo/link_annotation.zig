const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/link_annotation.c
pub fn run() !void {
    var page = [_]c.HPDF_Page{undefined} ** 9;
    var rect = c.HPDF_Rect{
        .left = 0,
        .top = 0,
        .right = 0,
        .bottom = 0,
    };

    const pdf = c.HPDF_New(error_handler, null);
    defer c.HPDF_Free(pdf);

    // /* create default-font */
    const font = c.HPDF_GetFont(pdf, "Helvetica", null);

    // /* create index page */
    const index_page = c.HPDF_AddPage(pdf);
    _ = c.HPDF_Page_SetWidth(index_page, 300);
    _ = c.HPDF_Page_SetHeight(index_page, 220);

    // /* Add 7 pages to the document. */
    var i: u32 = 0;
    while (i < 7) : (i += 1) {
        page[i] = c.HPDF_AddPage(pdf);
        print_page(page[i], font, i + 1);
    }

    _ = c.HPDF_Page_BeginText(index_page);
    _ = c.HPDF_Page_SetFontAndSize(index_page, font, 10);
    _ = c.HPDF_Page_MoveTextPos(index_page, 15, 200);
    _ = c.HPDF_Page_ShowText(index_page, "Link Annotation Demo");
    _ = c.HPDF_Page_EndText(index_page);

    // /*
    //  * Create Link-Annotation object on index page.
    //  */
    _ = c.HPDF_Page_BeginText(index_page);
    _ = c.HPDF_Page_SetFontAndSize(index_page, font, 8);
    _ = c.HPDF_Page_MoveTextPos(index_page, 20, 180);
    _ = c.HPDF_Page_SetTextLeading(index_page, 23);

    // /* page1 (HPDF_ANNOT_NO_HIGHTLIGHT) */
    var tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "Jump to Page1 (HilightMode=HPDF_ANNOT_NO_HIGHTLIGHT)");
    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_MoveToNextLine(index_page);

    var dst = c.HPDF_Page_CreateDestination(page[0]);

    var annot = c.HPDF_Page_CreateLinkAnnot(index_page, rect, dst);

    _ = c.HPDF_LinkAnnot_SetHighlightMode(annot, c.HPDF_ANNOT_NO_HIGHTLIGHT);

    // /* page2 (HPDF_ANNOT_INVERT_BOX) */
    tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "Jump to Page2 (HilightMode=HPDF_ANNOT_INVERT_BOX)");
    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_MoveToNextLine(index_page);

    dst = c.HPDF_Page_CreateDestination(page[1]);

    annot = c.HPDF_Page_CreateLinkAnnot(index_page, rect, dst);

    _ = c.HPDF_LinkAnnot_SetHighlightMode(annot, c.HPDF_ANNOT_INVERT_BOX);

    // /* page3 (HPDF_ANNOT_INVERT_BORDER) */
    tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "Jump to Page3 (HilightMode=HPDF_ANNOT_INVERT_BORDER)");
    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_MoveToNextLine(index_page);

    dst = c.HPDF_Page_CreateDestination(page[2]);

    annot = c.HPDF_Page_CreateLinkAnnot(index_page, rect, dst);

    _ = c.HPDF_LinkAnnot_SetHighlightMode(annot, c.HPDF_ANNOT_INVERT_BORDER);

    //    /* page4 (HPDF_ANNOT_DOWN_APPEARANCE) */
    tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "Jump to Page4 (HilightMode=HPDF_ANNOT_DOWN_APPEARANCE)");
    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_MoveToNextLine(index_page);

    dst = c.HPDF_Page_CreateDestination(page[3]);

    annot = c.HPDF_Page_CreateLinkAnnot(index_page, rect, dst);

    _ = c.HPDF_LinkAnnot_SetHighlightMode(annot, c.HPDF_ANNOT_DOWN_APPEARANCE);

    // /* page5 (dash border) */
    tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "Jump to Page5 (dash border)");
    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_MoveToNextLine(index_page);

    dst = c.HPDF_Page_CreateDestination(page[4]);

    annot = c.HPDF_Page_CreateLinkAnnot(index_page, rect, dst);

    _ = c.HPDF_LinkAnnot_SetBorderStyle(annot, 1, 3, 2);

    // /* page6 (no border) */
    tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "Jump to Page6 (no border)");
    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_MoveToNextLine(index_page);

    dst = c.HPDF_Page_CreateDestination(page[5]);

    annot = c.HPDF_Page_CreateLinkAnnot(index_page, rect, dst);

    _ = c.HPDF_LinkAnnot_SetBorderStyle(annot, 0, 0, 0);

    // /* page7 (bold border) */
    tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "Jump to Page7 (bold border)");
    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_MoveToNextLine(index_page);

    dst = c.HPDF_Page_CreateDestination(page[6]);

    annot = c.HPDF_Page_CreateLinkAnnot(index_page, rect, dst);

    _ = c.HPDF_LinkAnnot_SetBorderStyle(annot, 2, 0, 0);

    // /* URI link */
    const uri = "http://libharu.org";
    tp = c.HPDF_Page_GetCurrentTextPos(index_page);

    _ = c.HPDF_Page_ShowText(index_page, "URI (");
    _ = c.HPDF_Page_ShowText(index_page, uri);
    _ = c.HPDF_Page_ShowText(index_page, ")");

    rect.left = tp.x - 4;
    rect.bottom = tp.y - 4;
    rect.right = c.HPDF_Page_GetCurrentTextPos(index_page).x + 4;
    rect.top = tp.y + 10;

    _ = c.HPDF_Page_CreateURILinkAnnot(index_page, rect, uri);

    _ = c.HPDF_Page_EndText(index_page);

    // /* save the document to a file */
    _ = c.HPDF_SaveToFile(pdf, "output/link_annotation.pdf");
}

fn error_handler(error_no: c.HPDF_STATUS, detail_no: c.HPDF_STATUS, user_data: ?*anyopaque) callconv(.C) void {
    _ = user_data;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    stdout.print("ERROR: error_no={}, detail_no={}\n", .{ error_no, detail_no }) catch unreachable;

    bw.flush() catch unreachable;
}

fn print_page(page: c.HPDF_Page, font: c.HPDF_Font, page_num: u64) void {
    var buf: [50]u8 = undefined;

    _ = c.HPDF_Page_SetWidth(page, 200);
    _ = c.HPDF_Page_SetHeight(page, 200);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 20);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 50, 150);
    var text = std.fmt.bufPrintZ(&buf, "Page:{}", .{page_num}) catch return;
    _ = c.HPDF_Page_ShowText(page, text.ptr);
    _ = c.HPDF_Page_EndText(page);
}
