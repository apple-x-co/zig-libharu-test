const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/png_demo.c
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

    _ = c.HPDF_Page_SetWidth(page, 550);
    _ = c.HPDF_Page_SetHeight(page, 650);

    const dst = c.HPDF_Page_CreateDestination(page);
    _ = c.HPDF_Destination_SetXYZ(dst, 0, c.HPDF_Page_GetHeight(page), 1);
    _ = c.HPDF_SetOpenAction(pdf, dst);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 20);
    _ = c.HPDF_Page_MoveTextPos(page, 220, c.HPDF_Page_GetHeight(page) - 70);
    _ = c.HPDF_Page_ShowText(page, "PngDemo");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_SetFontAndSize(page, font, 12);

    try draw_image(allocator, pdf, "basn0g01.png", 100, c.HPDF_Page_GetHeight(page) - 150, "1bit grayscale.");
    try draw_image(allocator, pdf, "basn0g02.png", 200, c.HPDF_Page_GetHeight(page) - 150, "2bit grayscale.");
    try draw_image(allocator, pdf, "basn0g04.png", 300, c.HPDF_Page_GetHeight(page) - 150, "4bit grayscale.");
    try draw_image(allocator, pdf, "basn0g08.png", 400, c.HPDF_Page_GetHeight(page) - 150, "8bit grayscale.");

    try draw_image(allocator, pdf, "basn2c08.png", 100, c.HPDF_Page_GetHeight(page) - 250, "8bit color.");
    try draw_image(allocator, pdf, "basn2c16.png", 200, c.HPDF_Page_GetHeight(page) - 250, "16bit color.");

    try draw_image(allocator, pdf, "basn3p01.png", 100, c.HPDF_Page_GetHeight(page) - 350, "1bit pallet.");
    try draw_image(allocator, pdf, "basn3p02.png", 200, c.HPDF_Page_GetHeight(page) - 350, "2bit pallet.");
    try draw_image(allocator, pdf, "basn3p04.png", 300, c.HPDF_Page_GetHeight(page) - 350, "4bit pallet.");
    try draw_image(allocator, pdf, "basn3p08.png", 400, c.HPDF_Page_GetHeight(page) - 350, "8bit pallet.");

    try draw_image(allocator, pdf, "basn4a08.png", 100, c.HPDF_Page_GetHeight(page) - 450, "8bit alpha.");
    try draw_image(allocator, pdf, "basn4a16.png", 200, c.HPDF_Page_GetHeight(page) - 450, "16bit alpha.");

    try draw_image(allocator, pdf, "basn6a08.png", 100, c.HPDF_Page_GetHeight(page) - 550, "8bit alpha.");
    try draw_image(allocator, pdf, "basn6a16.png", 200, c.HPDF_Page_GetHeight(page) - 550, "16bit alpha.");

    // save the document to a file
    _ = c.HPDF_SaveToFile(pdf, "output/png_demo.pdf");
}

fn draw_image(allocator: std.mem.Allocator, pdf: c.HPDF_Doc, filename: []const u8, x: f32, y: f32, text: []const u8) !void {
    const page = c.HPDF_GetCurrentPage(pdf);

    var filename1 = try std.fmt.allocPrintZ(allocator, "src/demo/pngsuite/{s}", .{filename});
    defer allocator.free(filename1);

    const image = c.HPDF_LoadPngImageFromFile(pdf, filename1.ptr);

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
