const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/jpeg_demo.c
pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    _ = c.HPDF_SetCompressionMode(pdf, c.HPDF_COMP_ALL);

    // create default-font
    const font = c.HPDF_GetFont(pdf, "Helvetica", null);

    // add a new page object.
    const page = c.HPDF_AddPage(pdf);

    _ = c.HPDF_Page_SetWidth(page, 650);
    _ = c.HPDF_Page_SetHeight(page, 500);

    const dst = c.HPDF_Page_CreateDestination(page);
    _ = c.HPDF_Destination_SetXYZ(dst, 0, c.HPDF_Page_GetHeight(page), 1);
    _ = c.HPDF_SetOpenAction(pdf, dst);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 20);
    _ = c.HPDF_Page_MoveTextPos(page, 220, c.HPDF_Page_GetHeight(page) - 70);
    _ = c.HPDF_Page_ShowText(page, "JpegDemo");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 12);

    try draw_image(allocator, pdf, "rgb.jpg", 70, c.HPDF_Page_GetHeight(page) - 410, "24bit color image");
    try draw_image(allocator, pdf, "gray.jpg", 340, c.HPDF_Page_GetHeight(page) - 410, "8bit grayscale image");

    // save the document to a file
    _ = c.HPDF_SaveToFile(pdf, "output/jpeg_demo.pdf");
}

fn draw_image(allocator: std.mem.Allocator, pdf: c.HPDF_Doc, filename: []const u8, x: f32, y: f32, text: []const u8) !void {
    const page = c.HPDF_GetCurrentPage(pdf);

    var filename1 = try std.fmt.allocPrintZ(allocator, "src/demo/images/{s}", .{filename});
    defer allocator.free(filename1);

    const image = c.HPDF_LoadJpegImageFromFile(pdf, filename1.ptr);

    // Draw image to the canvas.
    _ = c.HPDF_Page_DrawImage(page, image, x, y, @intToFloat(f32, c.HPDF_Image_GetWidth(image)), @intToFloat(f32, c.HPDF_Image_GetHeight(image)));

    // Print the text.
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetTextLeading(page, 16);
    _ = c.HPDF_Page_MoveTextPos(page, x, y);
    _ = c.HPDF_Page_ShowTextNextLine(page, filename.ptr);
    _ = c.HPDF_Page_ShowTextNextLine(page, text.ptr);
    _ = c.HPDF_Page_EndText(page);
}
