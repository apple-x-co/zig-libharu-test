const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

// https://github.com/libharu/libharu/blob/master/demo/image_demo.c
pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    _ = c.HPDF_SetCompressionMode(pdf, c.HPDF_COMP_ALL);

    // create default-font
    const font = c.HPDF_GetFont(pdf, "Helvetica", null);

    // /* add a new page object. */
    const page = c.HPDF_AddPage(pdf);

    _ = c.HPDF_Page_SetWidth(page, 550);
    _ = c.HPDF_Page_SetHeight(page, 500);

    const dst = c.HPDF_Page_CreateDestination(page);
    _ = c.HPDF_Destination_SetXYZ(dst, 0, c.HPDF_Page_GetHeight(page), 1);
    _ = c.HPDF_SetOpenAction(pdf, dst);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 20);
    _ = c.HPDF_Page_MoveTextPos(page, 220, c.HPDF_Page_GetHeight(page) - 70);
    _ = c.HPDF_Page_ShowText(page, "ImageDemo");
    _ = c.HPDF_Page_EndText(page);

    // load image file.
    const image = c.HPDF_LoadPngImageFromFile(pdf, "src/demo/pngsuite/basn3p02.png");
    const image1 = c.HPDF_LoadPngImageFromFile(pdf, "src/demo/pngsuite/basn3p02.png");
    const image2 = c.HPDF_LoadPngImageFromFile(pdf, "src/demo/pngsuite/basn0g01.png");
    const image3 = c.HPDF_LoadPngImageFromFile(pdf, "src/demo/pngsuite/maskimage.png");

    const iw: f32 = @as(f32, @floatFromInt(c.HPDF_Image_GetWidth(image)));
    const ih: f32 = @as(f32, @floatFromInt(c.HPDF_Image_GetHeight(image)));

    _ = c.HPDF_Page_SetLineWidth(page, 0.5);

    var x: f32 = 100;
    var y: f32 = c.HPDF_Page_GetHeight(page) - 150;

    // Draw image to the canvas. (normal-mode with actual size.)
    _ = c.HPDF_Page_DrawImage(page, image, x, y, iw, ih);

    try show_description(allocator, page, x, y, "Actual Size");

    x += 150;

    // Scalling image (X direction)
    _ = c.HPDF_Page_DrawImage(page, image, x, y, iw * 1.5, ih);

    try show_description(allocator, page, x, y, "Scalling image (X direction)");

    x += 150;

    // Scalling image (Y direction).
    _ = c.HPDF_Page_DrawImage(page, image, x, y, iw, ih * 1.5);
    try show_description(allocator, page, x, y, "Scalling image (Y direction)");

    x = 100;
    y -= 120;

    // Skewing image.
    var angle1: f32 = 10;
    var angle2: f32 = 20;
    var rad1: f32 = angle1 / 180 * 3.141592;
    var rad2: f32 = angle2 / 180 * 3.141592;

    _ = c.HPDF_Page_GSave(page);

    _ = c.HPDF_Page_Concat(page, iw, @tan(rad1) * iw, @tan(rad2) * ih, ih, x, y);

    _ = c.HPDF_Page_ExecuteXObject(page, image);
    _ = c.HPDF_Page_GRestore(page);

    try show_description(allocator, page, x, y, "Skewing image");

    x += 150;

    // Rotating image
    var angle: f32 = 30; // rotation of 30 degrees.
    var rad: f32 = angle / 180 * 3.141592; // Calculate the radian value.

    _ = c.HPDF_Page_GSave(page);

    _ = c.HPDF_Page_Concat(page, iw * @cos(rad), iw * @sin(rad), ih * -@sin(rad), ih * @cos(rad), x, y);

    _ = c.HPDF_Page_ExecuteXObject(page, image);
    _ = c.HPDF_Page_GRestore(page);

    try show_description(allocator, page, x, y, "Rotating image");

    x += 150;

    // draw masked image.
    // Set image2 to the mask image of image1
    _ = c.HPDF_Image_SetMaskImage(image1, image2);

    _ = c.HPDF_Page_SetRGBFill(page, 0, 0, 0);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x - 6, y + 14);
    _ = c.HPDF_Page_ShowText(page, "MASKMASK");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_DrawImage(page, image1, x - 3, y - 3, iw + 6, ih + 6);

    try show_description(allocator, page, x, y, "masked image");

    x = 100;
    y -= 120;

    // color mask.
    _ = c.HPDF_Page_SetRGBFill(page, 0, 0, 0);
    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x - 6, y + 14);
    _ = c.HPDF_Page_ShowText(page, "MASKMASK");
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Image_SetColorMask(image3, 0, 255, 0, 0, 0, 255);
    _ = c.HPDF_Page_DrawImage(page, image3, x, y, iw, ih);

    try show_description(allocator, page, x, y, "Color Mask");

    // save the document to a file
    _ = c.HPDF_SaveToFile(pdf, "output/image_demo.pdf");
}

fn show_description(allocator: std.mem.Allocator, page: c.HPDF_Page, x: c.HPDF_REAL, y: c.HPDF_REAL, text: []const u8) !void {
    _ = c.HPDF_Page_MoveTo(page, x, y - 10);
    _ = c.HPDF_Page_LineTo(page, x, y + 10);
    _ = c.HPDF_Page_MoveTo(page, x - 10, y);
    _ = c.HPDF_Page_LineTo(page, x + 10, y);
    _ = c.HPDF_Page_Stroke(page);

    _ = c.HPDF_Page_SetFontAndSize(page, c.HPDF_Page_GetCurrentFont(page), 8);
    _ = c.HPDF_Page_SetRGBFill(page, 0, 0, 0);

    _ = c.HPDF_Page_BeginText(page);

    var coordinate = try std.fmt.allocPrintZ(allocator, "(x={d},y={d})", .{ x, y });
    defer allocator.free(coordinate);

    _ = c.HPDF_Page_MoveTextPos(page, x - c.HPDF_Page_TextWidth(page, coordinate.ptr) - 5, y - 10);
    _ = c.HPDF_Page_ShowText(page, coordinate.ptr);
    _ = c.HPDF_Page_EndText(page);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_MoveTextPos(page, x - 20, y - 25);
    _ = c.HPDF_Page_ShowText(page, text.ptr);
    _ = c.HPDF_Page_EndText(page);
}
