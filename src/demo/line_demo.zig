const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/line_demo.c
pub fn run() !void {
    const page_title = "Line Example";

    const DASH_MODE1: []const c.HPDF_REAL = &.{
        3,
    };
    const DASH_MODE2: []const c.HPDF_REAL = &.{
        3,
        7,
    };
    const DASH_MODE3: []const c.HPDF_REAL = &.{
        8,
        7,
        2,
        7,
    };

    var tw: c.HPDF_REAL = 0;

    const pdf = c.HPDF_New(error_handler, null);
    defer c.HPDF_Free(pdf);

    // /* create default-font */
    const font = c.HPDF_GetFont(pdf, "Helvetica", null);

    // /* add a new page object. */
    const page = c.HPDF_AddPage(pdf);

    // /* print the lines of the page. */
    _ = c.HPDF_Page_SetLineWidth(page, 1);
    _ = c.HPDF_Page_Rectangle(page, 50, 50, c.HPDF_Page_GetWidth(page) - 100, c.HPDF_Page_GetHeight(page) - 110);
    _ = c.HPDF_Page_Stroke(page);

    // /* print the title of the page (with positioning center). */
    _ = c.HPDF_Page_SetFontAndSize(page, font, 24);
    tw = c.HPDF_Page_TextWidth(page, page_title);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, (c.HPDF_Page_GetWidth(page) - tw) / 2, c.HPDF_Page_GetHeight(page) - 50);
    _ = c.HPDF_Page_ShowText(page, page_title);
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 10);

    // /* Draw various widths of lines. */
    _ = c.HPDF_Page_SetLineWidth(page, 0);
    draw_line(page, 60, 770, "line width = 0");

    _ = c.HPDF_Page_SetLineWidth(page, 1.0);
    draw_line(page, 60, 740, "line width = 1.0");

    _ = c.HPDF_Page_SetLineWidth(page, 2.0);
    draw_line(page, 60, 710, "line width = 2.0");

    // /* Line dash pattern */
    _ = c.HPDF_Page_SetLineWidth(page, 1.0);

    _ = c.HPDF_Page_SetDash(page, DASH_MODE1.ptr, 1, 1);
    draw_line(page, 60, 680, "dash_ptn=[3], phase=1 -- 2 on, 3 off, 3 on...");

    _ = c.HPDF_Page_SetDash(page, DASH_MODE2.ptr, 2, 2);
    draw_line(page, 60, 650, "dash_ptn=[7, 3], phase=2 -- 5 on 3 off, 7 on,...");

    _ = c.HPDF_Page_SetDash(page, DASH_MODE3.ptr, 4, 0);
    draw_line(page, 60, 620, "dash_ptn=[8, 7, 2, 7], phase=0");

    _ = c.HPDF_Page_SetDash(page, null, 0, 0);

    _ = c.HPDF_Page_SetLineWidth(page, 30);
    _ = c.HPDF_Page_SetRGBStroke(page, 0.0, 0.5, 0.0);

    // /* Line Cap Style */
    _ = c.HPDF_Page_SetLineCap(page, c.HPDF_BUTT_END);
    draw_line2(page, 60, 570, "PDF_BUTT_END");

    _ = c.HPDF_Page_SetLineCap(page, c.HPDF_ROUND_END);
    draw_line2(page, 60, 505, "PDF_ROUND_END");

    _ = c.HPDF_Page_SetLineCap(page, c.HPDF_PROJECTING_SQUARE_END);
    draw_line2(page, 60, 440, "PDF_PROJECTING_SCUARE_END");

    // /* Line Join Style */
    _ = c.HPDF_Page_SetLineWidth(page, 30);
    _ = c.HPDF_Page_SetRGBStroke(page, 0.0, 0.0, 0.5);

    _ = c.HPDF_Page_SetLineJoin(page, c.HPDF_MITER_JOIN);
    _ = c.HPDF_Page_MoveTo(page, 120, 300);
    _ = c.HPDF_Page_LineTo(page, 160, 340);
    _ = c.HPDF_Page_LineTo(page, 200, 300);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 60, 360);
    _ = c.HPDF_Page_ShowText(page, "PDF_MITER_JOIN");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetLineJoin(page, c.HPDF_ROUND_JOIN);
    _ = c.HPDF_Page_MoveTo(page, 120, 195);
    _ = c.HPDF_Page_LineTo(page, 160, 235);
    _ = c.HPDF_Page_LineTo(page, 200, 195);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 60, 255);
    _ = c.HPDF_Page_ShowText(page, "PDF_ROUND_JOIN");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetLineJoin(page, c.HPDF_BEVEL_JOIN);
    _ = c.HPDF_Page_MoveTo(page, 120, 90);
    _ = c.HPDF_Page_LineTo(page, 160, 130);
    _ = c.HPDF_Page_LineTo(page, 200, 90);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 60, 150);
    _ = c.HPDF_Page_ShowText(page, "PDF_BEVEL_JOIN");
    _ = c.HPDF_Page_EndText(page);

    // /* Draw Rectangle */
    _ = c.HPDF_Page_SetLineWidth(page, 2);
    _ = c.HPDF_Page_SetRGBStroke(page, 0, 0, 0);
    _ = c.HPDF_Page_SetRGBFill(page, 0.75, 0.0, 0.0);

    draw_rect(page, 300, 770, "Stroke");
    _ = c.HPDF_Page_Stroke(page);

    draw_rect(page, 300, 720, "Fill");
    _ = c.HPDF_Page_Fill(page);

    draw_rect(page, 300, 670, "Fill then Stroke");
    _ = c.HPDF_Page_FillStroke(page);

    // /* Clip Rect */
    _ = c.HPDF_Page_GSave(page); // /* Save the current graphic state */
    draw_rect(page, 300, 620, "Clip Rectangle");
    _ = c.HPDF_Page_Clip(page);
    _ = c.HPDF_Page_Stroke(page);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 13);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 290, 600);
    _ = c.HPDF_Page_SetTextLeading(page, 12);
    _ = c.HPDF_Page_ShowText(page, "Clip Clip Clip Clip Clip Clipi Clip Clip Clip");
    _ = c.HPDF_Page_ShowTextNextLine(page, "Clip Clip Clip Clip Clip Clip Clip Clip Clip");
    _ = c.HPDF_Page_ShowTextNextLine(page, "Clip Clip Clip Clip Clip Clip Clip Clip Clip");
    _ = c.HPDF_Page_EndText(page);
    _ = c.HPDF_Page_GRestore(page);

    // /* Curve Example(CurveTo2) */
    var x: c.HPDF_REAL = 330;
    var y: c.HPDF_REAL = 440;
    var x1: c.HPDF_REAL = 430;
    var y1: c.HPDF_REAL = 530;
    var x2: c.HPDF_REAL = 480;
    var y2: c.HPDF_REAL = 470;
    var x3: c.HPDF_REAL = 480;
    var y3: c.HPDF_REAL = 90;

    _ = c.HPDF_Page_SetRGBFill(page, 0, 0, 0);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 300, 540);
    _ = c.HPDF_Page_ShowText(page, "CurveTo2(x1, y1, x2, y2)");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x + 5, y - 5);
    _ = c.HPDF_Page_ShowText(page, "Current point");
    _ = c.HPDF_Page_MoveTextPos(page, x1 - x, y1 - y);
    _ = c.HPDF_Page_ShowText(page, "(x1, y1)");
    _ = c.HPDF_Page_MoveTextPos(page, x2 - x1, y2 - y1);
    _ = c.HPDF_Page_ShowText(page, "(x2, y2)");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetDash(page, DASH_MODE1.ptr, 1, 0);

    _ = c.HPDF_Page_SetLineWidth(page, 0.5);
    _ = c.HPDF_Page_MoveTo(page, x1, y1);
    _ = c.HPDF_Page_LineTo(page, x2, y2);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_SetDash(page, null, 0, 0);

    _ = c.HPDF_Page_SetLineWidth(page, 1.5);

    _ = c.HPDF_Page_MoveTo(page, x, y);
    _ = c.HPDF_Page_CurveTo2(page, x1, y1, x2, y2);
    _ = c.HPDF_Page_Stroke(page);

    // /* Curve Example(CurveTo3) */
    y -= 150;
    y1 -= 150;
    y2 -= 150;

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 300, 390);
    _ = c.HPDF_Page_ShowText(page, "CurveTo3(x1, y1, x2, y2)");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x + 5, y - 5);
    _ = c.HPDF_Page_ShowText(page, "Current point");
    _ = c.HPDF_Page_MoveTextPos(page, x1 - x, y1 - y);
    _ = c.HPDF_Page_ShowText(page, "(x1, y1)");
    _ = c.HPDF_Page_MoveTextPos(page, x2 - x1, y2 - y1);
    _ = c.HPDF_Page_ShowText(page, "(x2, y2)");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetDash(page, DASH_MODE1.ptr, 1, 0);

    _ = c.HPDF_Page_SetLineWidth(page, 0.5);
    _ = c.HPDF_Page_MoveTo(page, x, y);
    _ = c.HPDF_Page_LineTo(page, x1, y1);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_SetDash(page, null, 0, 0);

    _ = c.HPDF_Page_SetLineWidth(page, 1.5);
    _ = c.HPDF_Page_MoveTo(page, x, y);
    _ = c.HPDF_Page_CurveTo3(page, x1, y1, x2, y2);
    _ = c.HPDF_Page_Stroke(page);

    // /* Curve Example(CurveTo) */
    y -= 150;
    y1 -= 160;
    y2 -= 130;
    x2 += 10;

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, 300, 240);
    _ = c.HPDF_Page_ShowText(page, "CurveTo(x1, y1, x2. y2, x3, y3)");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x + 5, y - 5);
    _ = c.HPDF_Page_ShowText(page, "Current point");
    _ = c.HPDF_Page_MoveTextPos(page, x1 - x, y1 - y);
    _ = c.HPDF_Page_ShowText(page, "(x1, y1)");
    _ = c.HPDF_Page_MoveTextPos(page, x2 - x1, y2 - y1);
    _ = c.HPDF_Page_ShowText(page, "(x2, y2)");
    _ = c.HPDF_Page_MoveTextPos(page, x3 - x2, y3 - y2);
    _ = c.HPDF_Page_ShowText(page, "(x3, y3)");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetDash(page, DASH_MODE1.ptr, 1, 0);

    _ = c.HPDF_Page_SetLineWidth(page, 0.5);
    _ = c.HPDF_Page_MoveTo(page, x, y);
    _ = c.HPDF_Page_LineTo(page, x1, y1);
    _ = c.HPDF_Page_Stroke(page);
    _ = c.HPDF_Page_MoveTo(page, x2, y2);
    _ = c.HPDF_Page_LineTo(page, x3, y3);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_SetDash(page, null, 0, 0);

    _ = c.HPDF_Page_SetLineWidth(page, 1.5);
    _ = c.HPDF_Page_MoveTo(page, x, y);
    _ = c.HPDF_Page_CurveTo(page, x1, y1, x2, y2, x3, y3);
    _ = c.HPDF_Page_Stroke(page);

    /////////
    _ = c.HPDF_SaveToFile(pdf, "output/line_demo.pdf");
}

fn error_handler(error_no: c.HPDF_STATUS, detail_no: c.HPDF_STATUS, user_data: ?*anyopaque) callconv(.C) void {
    _ = user_data;

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    stdout.print("ERROR: error_no={}, detail_no={}\n", .{ error_no, detail_no }) catch unreachable;

    bw.flush() catch unreachable;
}

fn draw_line(page: c.HPDF_Page, x: f32, y: f32, label: []const u8) void {
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x, y - 10);
    _ = c.HPDF_Page_ShowText(page, label.ptr);
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_MoveTo(page, x, y - 15);
    _ = c.HPDF_Page_LineTo(page, x + 220, y - 15);
    _ = c.HPDF_Page_Stroke(page);
}

fn draw_line2(page: c.HPDF_Page, x: f32, y: f32, label: []const u8) void {
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x, y);
    _ = c.HPDF_Page_ShowText(page, label.ptr);
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_MoveTo(page, x + 30, y - 25);
    _ = c.HPDF_Page_LineTo(page, x + 160, y - 25);
    _ = c.HPDF_Page_Stroke(page);
}

fn draw_rect(page: c.HPDF_Page, x: f32, y: f32, label: []const u8) void {
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x, y - 10);
    _ = c.HPDF_Page_ShowText(page, label.ptr);
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_Rectangle(page, x, y - 40, 220, 25);
}
