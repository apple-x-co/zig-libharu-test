const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

const PAGE_WIDTH: c.HPDF_REAL = 600;
const PAGE_HEIGHT: c.HPDF_REAL = 900;

// https://github.com/libharu/libharu/blob/master/demo/ext_gstate_demo.c
pub fn run() !void {
    const pdf = c.HPDF_New(error_handler, null);
    defer c.HPDF_Free(pdf);

    const hfont = c.HPDF_GetFont(pdf, "Helvetica-Bold", null);

    // /* add a new page object. */
    const page = c.HPDF_AddPage(pdf);

    _ = c.HPDF_Page_SetFontAndSize(page, hfont, 10);

    _ = c.HPDF_Page_SetHeight(page, PAGE_HEIGHT);
    _ = c.HPDF_Page_SetWidth(page, PAGE_WIDTH);

    // /* normal */
    _ = c.HPDF_Page_GSave(page);
    draw_circles(page, "normal", 40.0, PAGE_HEIGHT - 170);
    _ = c.HPDF_Page_GRestore(page);

    // /* transparency (0.8) */
    _ = c.HPDF_Page_GSave(page);
    var gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetAlphaFill(gstate, 0.8);
    _ = c.HPDF_ExtGState_SetAlphaStroke(gstate, 0.8);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "alpha fill = 0.8", 230.0, PAGE_HEIGHT - 170);
    _ = c.HPDF_Page_GRestore(page);

    // /* transparency (0.4) */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetAlphaFill(gstate, 0.4);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "alpha fill = 0.4", 420.0, PAGE_HEIGHT - 170);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_MULTIPLY */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_MULTIPLY);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_MULTIPLY", 40.0, PAGE_HEIGHT - 340);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_SCREEN */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_SCREEN);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_SCREEN", 230.0, PAGE_HEIGHT - 340);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_OVERLAY */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_OVERLAY);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_OVERLAY", 420.0, PAGE_HEIGHT - 340);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_DARKEN */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_DARKEN);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_DARKEN", 40.0, PAGE_HEIGHT - 510);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_LIGHTEN */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_LIGHTEN);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_LIGHTEN", 230.0, PAGE_HEIGHT - 510);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_COLOR_DODGE */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_COLOR_DODGE);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_COLOR_DODGE", 420.0, PAGE_HEIGHT - 510);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_COLOR_BUM */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_COLOR_BUM);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_COLOR_BUM", 40.0, PAGE_HEIGHT - 680);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_HARD_LIGHT */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_HARD_LIGHT);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_HARD_LIGHT", 230.0, PAGE_HEIGHT - 680);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_SOFT_LIGHT */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_SOFT_LIGHT);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_SOFT_LIGHT", 420.0, PAGE_HEIGHT - 680);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_DIFFERENCE */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_DIFFERENCE);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_DIFFERENCE", 40.0, PAGE_HEIGHT - 850);
    _ = c.HPDF_Page_GRestore(page);

    // /* blend-mode=HPDF_BM_EXCLUSHON */
    _ = c.HPDF_Page_GSave(page);
    gstate = c.HPDF_CreateExtGState(pdf);
    _ = c.HPDF_ExtGState_SetBlendMode(gstate, c.HPDF_BM_EXCLUSHON);
    _ = c.HPDF_Page_SetExtGState(page, gstate);
    draw_circles(page, "HPDF_BM_EXCLUSHON", 230.0, PAGE_HEIGHT - 850);
    _ = c.HPDF_Page_GRestore(page);

    // /* save the document to a file */
    _ = c.HPDF_SaveToFile(pdf, "output/ext_gstate_demo.pdf");
}

fn error_handler(error_no: c.HPDF_STATUS, detail_no: c.HPDF_STATUS, user_data: ?*anyopaque) callconv(.C) void {
    _ = user_data;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    stdout.print("ERROR: error_no={}, detail_no={}\n", .{ error_no, detail_no }) catch unreachable;

    bw.flush() catch unreachable;
}

fn draw_circles(page: c.HPDF_Page, description: []const u8, x: c.HPDF_REAL, y: c.HPDF_REAL) void {
    _ = c.HPDF_Page_SetLineWidth(page, 1.0);
    _ = c.HPDF_Page_SetRGBStroke(page, 0.0, 0.0, 0.0);
    _ = c.HPDF_Page_SetRGBFill(page, 1.0, 0.0, 0.0);
    _ = c.HPDF_Page_Circle(page, x + 40, y + 40, 40);
    _ = c.HPDF_Page_ClosePathFillStroke(page);
    _ = c.HPDF_Page_SetRGBFill(page, 0.0, 1.0, 0.0);
    _ = c.HPDF_Page_Circle(page, x + 100, y + 40, 40);
    _ = c.HPDF_Page_ClosePathFillStroke(page);
    _ = c.HPDF_Page_SetRGBFill(page, 0.0, 0.0, 1.0);
    _ = c.HPDF_Page_Circle(page, x + 70, y + 74.64, 40);
    _ = c.HPDF_Page_ClosePathFillStroke(page);

    _ = c.HPDF_Page_SetRGBFill(page, 0.0, 0.0, 0.0);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_TextOut(page, x + 0.0, y + 130.0, description.ptr);
    _ = c.HPDF_Page_EndText(page);
}
