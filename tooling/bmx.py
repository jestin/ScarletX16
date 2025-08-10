#!/usr/bin/env python
# package requirements: pillow
import os
import sys
import struct
import argparse
from PIL import Image
from typing import List


class Bmx:
    header_fmt = "<3sBBBHHBBHbB"
    VERSION = 1

    class Error(RuntimeError):
        pass

    def __init__(self):
        assert struct.calcsize(Bmx.header_fmt) == 16
        self.magic = b"BMX"
        self.version = Bmx.VERSION
        self.bpp = 0
        self.vera_color_depth = 0
        self.width = 0
        self.height = 0
        self.pal_used = 0
        self.pal_start = 0
        self.data_start = 0
        self.compressed = 0
        self.border = 0
        self.palette_data = b""
        self.bitmap_data = b""

    def __str__(self) -> str:
        cmpr = "compressed" if self.compressed else "uncompressed"
        return f"[BMX image {self.width}*{self.height}, {self.bpp} bpp, {self.pal_used} colors, {cmpr}]"

    def read(self, filename: str):
        data = open(filename, "rb").read()
        self.parse_header(data)
        self.palette_data = data[32: 32 + self.pal_used * 2]
        self.bitmap_data = data[32 + self.pal_used * 2:]

    def write(self, filename: str) -> None:
        header_pal_used = self.pal_used if self.pal_used < 256 else 0
        header = struct.pack(Bmx.header_fmt, self.magic, self.version, self.bpp, self.vera_color_depth, self.width,
                                self.height, header_pal_used, self.pal_start, self.data_start, self.compressed,
                                self.border) + bytes(16)
        with open(filename, "wb") as out:
            out.write(header)
            out.write(self.palette_data)
            out.write(self.bitmap_data)

    def set_bpp(self, bpp: int) -> None:
        self.bpp = bpp
        if bpp == 1:
            self.vera_color_depth = 0
        elif bpp == 2:
            self.vera_color_depth = 1
        elif bpp == 4:
            self.vera_color_depth = 2
        elif bpp == 8:
            self.vera_color_depth = 3
        else:
            raise ValueError("bpp must be 1,2,4,8")

    def set_vera_colordepth(self, depth: int) -> None:
        self.vera_color_depth = depth
        self.bpp = 2 ** depth
        if depth < 0 or depth > 3:
            raise ValueError("depth must be 0,1,2,3")

    def parse_header(self, bmxdata: bytes) -> None:
        if bmxdata[0:3] != b"BMX":
            raise self.Error("not a BMX file")
        self.magic, self.version, self.bpp, self.vera_color_depth, self.width, self.height, self.pal_used, self.pal_start, self.data_start, self.compressed, self.border = struct.unpack(
            Bmx.header_fmt, bmxdata[:16])
        if self.magic != b"BMX":
            raise self.BmxError("not a BMX file")
        if self.version != Bmx.VERSION:
            raise self.BmxError("invalid BMX version, only supports " + str(Bmx.VERSION))
        if self.pal_used == 0:
            self.pal_used = 256
        if self.data_start != 32 + 2 * self.pal_used:
            print("Warning: data start offset mismatch:", self.data_start, "expected:", 32 + 2 * self.pal_used)

    def get_palette_rgb32(self) -> List[tuple]:
        rgb = []
        for i in range(0, self.pal_used * 2, 2):
            G4 = self.palette_data[i] >> 4
            B4 = self.palette_data[i] & 15
            R4 = self.palette_data[i + 1] & 15
            rgb.append((R4 << 4 | R4, G4 << 4 | G4, B4 << 4 | B4))
        return rgb

    def as_image(self) -> Image:
        if self.compressed:
            raise self.BmxError("doesn't support compressed images")
        if self.bpp == 8:
            img = Image.frombytes("P", (self.width, self.height), self.bitmap_data)
        else:
            raise self.BmxError("no support for bpp " + str(self.bpp))
        palette = []
        for rgb in self.get_palette_rgb32():
            palette.append(rgb[0])
            palette.append(rgb[1])
            palette.append(rgb[2])
        img.putpalette(palette)
        return img

    def load_image(self, image: Image, max_width: int = 320, max_height: int = 240, preserve_first_16_colors=False) -> None:
        default_colors = [
            0x0, 0x0, 0x0,   # 0 = black
            0xf, 0xf, 0xf,   # 1 = white
            0x8, 0x0, 0x0,   # 2 = red
            0xa, 0xf, 0xe,   # 3 = cyan
            0xc, 0x4, 0xc,   # 4 = purple
            0x0, 0xc, 0x5,   # 5 = green
            0x0, 0x0, 0xa,   # 6 = blue
            0xe, 0xe, 0x7,   # 7 = yellow
            0xd, 0x8, 0x5,   # 8 = orange
            0x6, 0x4, 0x0,   # 9 = brown
            0xf, 0x7, 0x7,   # 10 = light red
            0x3, 0x3, 0x3,   # 11 = dark grey
            0x7, 0x7, 0x7,   # 12 = medium grey
            0xa, 0xf, 0x6,   # 13 = light green
            0x0, 0x8, 0xf,   # 14 = light blue
            0xb, 0xb, 0xb    # 15 = light grey
        ]

        if image.size[0] > max_width or image.size[1] > max_height:
            print(f"Image too large, resizing to {max_width}*{max_height}")
            image.thumbnail((max_width, max_height))
        if image.mode != "P":
            image = image.convert("RGB")
            if preserve_first_16_colors:
                print("Preserving first 16 colors")
            palette_image = image.quantize(colors=240 if preserve_first_16_colors else 256, dither=Image.Dither.NONE, method=Image.Quantize.MAXCOVERAGE)
            # convert palette to X16 4:4:4 and re-quantize to this palette
            palette = [self.to4bit(x) for x in palette_image.getpalette()]
            if preserve_first_16_colors:
                palette = default_colors + palette
                print("Number of colors: ", len(palette)//3)
            rgb = {(palette[i], palette[i + 1], palette[i + 2]) for i in range(0, len(palette), 3)}
            palette = []
            for r, g, b in sorted(rgb):
                palette.append(r << 4 | r)
                palette.append(g << 4 | g)
                palette.append(b << 4 | b)
            palette_image.putpalette(palette)
            image = image.quantize(dither=Image.Dither.FLOYDSTEINBERG, palette=palette_image)
            print(f"Converted to image with palette, {len(palette) // 3} colors")
        else:
            print(f"Image with palette, {len(image.getpalette()) // 3} colors")
        self.width, self.height = image.size
        self.set_bpp(8)
        palette = [self.to4bit(x) for x in image.getpalette()]
        self.pal_used = len(palette) // 3
        x16_palette = []
        for i in range(0, self.pal_used * 3, 3):
            x16_palette.append(palette[i + 1] << 4 | palette[i + 2])
            x16_palette.append(palette[i])
        self.data_start = 32 + 2 * self.pal_used
        self.palette_data = bytes(x16_palette)
        self.bitmap_data = bytes(image.getdata())

    def to4bit(self, color: int) -> int:
        # more accurate colorspace reduction, see https://threadlocalmutex.com/?p=48
        return (color * 15 + 135) >> 8


def bmx_show(filename: str) -> None:
    bmx = Bmx()
    bmx.read(filename)
    print(f"showing: {bmx}")
    img = bmx.as_image()
    img.show()


def bmx_info(filename: str) -> None:
    bmx = Bmx()
    bmx.read(filename)
    print(f"{filename}: {bmx}")


def bmx_create(filename: str, preserve16: bool) -> None:
    img = Image.open(filename)
    bmx = Bmx()
    bmx.load_image(img, preserve_first_16_colors=preserve16)
    filebase = os.path.splitext(os.path.basename(filename))[0]
    outputfile = f"{filebase}.bmx"
    bmx.write(outputfile)
    print(f"wrote {filename} as {outputfile} {bmx}")


def bmx_convert(filename: str) -> None:
    bmx = Bmx()
    bmx.read(filename)
    filebase = os.path.splitext(os.path.basename(filename))[0]
    outputfile = f"{filebase}.png"
    img = bmx.as_image()
    img.save(outputfile)
    print(f"wrote {filename} {bmx} as {outputfile}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description="Commander-X16 'BMX' image format converter",
        epilog="Text at the bottom of help")
    parser.add_argument("--preserve16", action="store_true", default=False, help="preserve first 16 default Vera color palette entries")
    parser.add_argument("action", help="the action to perform", type=str, choices=["show", "info", "tobmx", "topng"])
    parser.add_argument("filename", help="the file to process", type=str)
    args = parser.parse_args()
    if args.action == "show":
        bmx_show(args.filename)
    elif args.action == "info":
        bmx_info(args.filename)
    elif args.action == "tobmx":
        bmx_create(args.filename, args.preserve16)
    elif args.action == "topng":
        bmx_convert(args.filename)
