const std = @import("std");
const fs = std.fs;

fn print(comptime fmt: []const u8, args: anytype) void {
    if (false) {
        std.debug.print(fmt, args);
    }
}

const performance_aware_hw = @import("performance_aware_hw");

pub fn main() !void {
    const dir_options: fs.Dir.OpenOptions = .{
        .access_sub_paths = true,
        .iterate = false,
    };
    const perfaware_dir = try fs.openDirAbsolute("/home/drew/personal/computer_enhance/perfaware", dir_options);
    const part_1 = try perfaware_dir.openDir("part1", dir_options);

    // try readInstructions(part_1, "listing_0037_single_register_mov");
    try readInstructions(part_1, "listing_0038_many_register_mov");
}

const Register = enum(u8) {
    al,
    cl,
    dl,
    bl,
    ah,
    ch,
    dh,
    bh,
    ax,
    cx,
    dx,
    bx,
    sp,
    bp,
    si,
    di,

    const map: [8][2]Register = .{
        .{ .al, .ax },
        .{ .cl, .cx },
        .{ .dl, .dx },
        .{ .bl, .bx },
        .{ .ah, .sp },
        .{ .ch, .bp },
        .{ .dh, .si },
        .{ .bh, .di },
    };
    fn get(reg: u3, w: u1) Register {
        return Register.map[reg][w];
    }
};

const Mov = packed struct {
    w: u1,
    d: u1,
    instruction: u6,

    fn getIfMatch(instruction: u8) ?Mov {
        const maybe_mov: Mov = @bitCast(instruction);
        const match: u6 = 0b100010;
        if (maybe_mov.instruction == match) {
            return maybe_mov;
        }
        return null;
    }
};

const Mov2 = packed struct {
    r_w: u3,
    reg: u3,
    mod: u2,
};

fn readInstructions(dir: fs.Dir, exe: []const u8) !void {
    print("Reading instructions from {s}\n", .{exe});
    const exe_file = try dir.openFile(exe, .{ .mode = .read_only });

    var reader_buf: [1024 * 1024]u8 = undefined;
    var reader = exe_file.reader(&reader_buf);
    const instructions = &reader.interface;

    var writer_buf: [1024 * 1024]u8 = undefined;
    var writer = fs.File.stdout().writer(&writer_buf);
    const stdout = &writer.interface;

    // indicate that this is for 16 bit to NASM
    try stdout.writeAll("bits 16\n");

    while (true) {
        // pop next byte from reader
        const byte = instructions.takeByte() catch |err| {
            const etype = std.Io.Reader.Error;
            switch (err) {
                etype.EndOfStream => break,
                etype.ReadFailed => return err,
            }
        };
        print("instruction read: {b}\n", .{byte});

        if (Mov.getIfMatch(byte)) |mov| {
            print("MOV instruction found: {b} {b}\n", .{ mov.d, mov.w });

            const mov2_byte = try instructions.takeByte();
            const mov2: Mov2 = @bitCast(mov2_byte);
            print("MOV args found: {b} {b} {b}\n", .{ mov2.r_w, mov2.reg, mov2.mod });

            const register_r_w = Register.get(mov2.r_w, mov.w);
            const register_reg = Register.get(mov2.reg, mov.w);
            const registers = if (mov.d == 1) .{ register_reg, register_r_w } else .{ register_r_w, register_reg };
            try stdout.print("mov {t}, {t}\n", .{ registers[0], registers[1] });
        }
    }

    try stdout.flush();
}
