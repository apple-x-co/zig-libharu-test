const std = @import("std");
const c = @cImport({
    @cInclude("hpdf.h");
});

const RAW_IMAGE_DATA: []const c.HPDF_BYTE = &[128]c.HPDF_BYTE{ 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0xff, 0xfc, 0xff, 0xff, 0xff, 0xf8, 0xff, 0xff, 0xff, 0xf0, 0xf3, 0xf3, 0xff, 0xe0, 0xf3, 0xf3, 0xff, 0xc0, 0xf3, 0xf3, 0xff, 0x80, 0xf3, 0x33, 0xff, 0x00, 0xf3, 0x33, 0xfe, 0x00, 0xf3, 0x33, 0xfc, 0x00, 0xf8, 0x07, 0xf8, 0x00, 0xf8, 0x07, 0xf0, 0x00, 0xfc, 0xcf, 0xe0, 0x00, 0xfc, 0xcf, 0xc0, 0x00, 0xff, 0xff, 0x80, 0x00, 0xff, 0xff, 0x00, 0x00, 0xff, 0xfe, 0x00, 0x00, 0xff, 0xfc, 0x00, 0x00, 0xff, 0xf8, 0x0f, 0xe0, 0xff, 0xf0, 0x0f, 0xe0, 0xff, 0xe0, 0x0c, 0x30, 0xff, 0xc0, 0x0c, 0x30, 0xff, 0x80, 0x0f, 0xe0, 0xff, 0x00, 0x0f, 0xe0, 0xfe, 0x00, 0x0c, 0x30, 0xfc, 0x00, 0x0c, 0x30, 0xf8, 0x00, 0x0f, 0xe0, 0xf0, 0x00, 0x0f, 0xe0, 0xe0, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };

// https://github.com/libharu/libharu/blob/master/demo/raw_image_demo.c
pub fn run() !void {
    const pdf = c.HPDF_New(null, null);
    defer c.HPDF_Free(pdf);

    _ = c.HPDF_SetCompressionMode(pdf, c.HPDF_COMP_ALL);

    // /* create default-font */
    const font = c.HPDF_GetFont(pdf, "Helvetica", null);

    // /* add a new page object. */
    const page = c.HPDF_AddPage(pdf);

    _ = c.HPDF_Page_SetWidth(page, 172);
    _ = c.HPDF_Page_SetHeight(page, 80);

    _ = c.HPDF_Page_BeginText(page);
    _ = c.HPDF_Page_SetFontAndSize(page, font, 20);
    _ = c.HPDF_Page_MoveTextPos(page, 220, c.HPDF_Page_GetHeight(page) - 70);
    _ = c.HPDF_Page_ShowText(page, "RawImageDemo");
    _ = c.HPDF_Page_EndText(page);

    // /* load RGB raw-image file. */
    var image = c.HPDF_LoadRawImageFromFile(pdf, "src/demo/rawimage/32_32_rgb.dat", 32, 32, c.HPDF_CS_DEVICE_RGB);

    var x: f32 = 20;
    var y: f32 = 20;

    // /* Draw image to the canvas. (normal-mode with actual size.)*/
    _ = c.HPDF_Page_DrawImage(page, image, x, y, 32, 32);

    // /* load GrayScale raw-image file. */
    image = c.HPDF_LoadRawImageFromFile(pdf, "src/demo/rawimage/32_32_gray.dat", 32, 32, c.HPDF_CS_DEVICE_GRAY);

    x = 70;
    y = 20;

    // /* Draw image to the canvas. (normal-mode with actual size.)*/
    _ = c.HPDF_Page_DrawImage(page, image, x, y, 32, 32);

    // /* load GrayScale raw-image (1bit) file from memory. */
    image = c.HPDF_LoadRawImageFromMem(pdf, RAW_IMAGE_DATA.ptr, 32, 32, c.HPDF_CS_DEVICE_GRAY, 1);

    x = 120;
    y = 20;

    // /* Draw image to the canvas. (normal-mode with actual size.)*/
    _ = c.HPDF_Page_DrawImage(page, image, x, y, 32, 32);

    // /* save the document to a file */
    _ = c.HPDF_SaveToFile(pdf, "output/raw_image_demo.pdf");
}
