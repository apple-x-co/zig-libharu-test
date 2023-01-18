const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});
const grid = @import("grid.zig");

// https://github.com/libharu/libharu/blob/master/demo/arc_demo.c
pub fn run() !void {
    const pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    // /* add a new page object. */
    const page = c.HPDF_AddPage(pdf);

    _ = c.HPDF_Page_SetHeight(page, 220);
    _ = c.HPDF_Page_SetWidth(page, 200);

    // /* draw grid to the page */
    grid.print(pdf, page);

    // /* draw pie chart
    //  *
    //  *   A: 45% Red
    //  *   B: 25% Blue
    //  *   C: 15% green
    //  *   D: other yellow
    //  */

    var pos: c.HPDF_Point = .{
        .x = 0,
        .y = 0,
    };

    // /* A */
    _ = c.HPDF_Page_SetRGBFill(page, 1.0, 0, 0);
    _ = c.HPDF_Page_MoveTo(page, 100, 100);
    _ = c.HPDF_Page_LineTo(page, 100, 180);
    _ = c.HPDF_Page_Arc(page, 100, 100, 80, 0, 360 * 0.45);
    pos = c.HPDF_Page_GetCurrentPos(page);
    _ = c.HPDF_Page_LineTo(page, 100, 100);
    _ = c.HPDF_Page_Fill(page);

    // /* B */
    _ = c.HPDF_Page_SetRGBFill(page, 0, 0, 1.0);
    _ = c.HPDF_Page_MoveTo(page, 100, 100);
    _ = c.HPDF_Page_LineTo(page, pos.x, pos.y);
    _ = c.HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.45, 360 * 0.7);
    pos = c.HPDF_Page_GetCurrentPos(page);
    _ = c.HPDF_Page_LineTo(page, 100, 100);
    _ = c.HPDF_Page_Fill(page);

    // /* C */
    _ = c.HPDF_Page_SetRGBFill(page, 0, 1.0, 0);
    _ = c.HPDF_Page_MoveTo(page, 100, 100);
    _ = c.HPDF_Page_LineTo(page, pos.x, pos.y);
    _ = c.HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.7, 360 * 0.85);
    pos = c.HPDF_Page_GetCurrentPos(page);
    _ = c.HPDF_Page_LineTo(page, 100, 100);
    _ = c.HPDF_Page_Fill(page);

    // /* D */
    _ = c.HPDF_Page_SetRGBFill(page, 1.0, 1.0, 0);
    _ = c.HPDF_Page_MoveTo(page, 100, 100);
    _ = c.HPDF_Page_LineTo(page, pos.x, pos.y);
    _ = c.HPDF_Page_Arc(page, 100, 100, 80, 360 * 0.85, 360);
    pos = c.HPDF_Page_GetCurrentPos(page);
    _ = c.HPDF_Page_LineTo(page, 100, 100);
    _ = c.HPDF_Page_Fill(page);

    // /* draw center circle */
    _ = c.HPDF_Page_SetGrayStroke(page, 0);
    _ = c.HPDF_Page_SetGrayFill(page, 1);
    _ = c.HPDF_Page_Circle(page, 100, 100, 30);
    _ = c.HPDF_Page_Fill(page);

    // /* save the document to a file */
    _ = c.HPDF_SaveToFile(pdf, "output/arc_demo.pdf");
}
