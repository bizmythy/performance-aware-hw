const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const performance_aware_hw = @import("performance_aware_hw");

pub fn main() !void {
    const dir_options: fs.Dir.OpenOptions = .{
        .access_sub_paths = true,
        .iterate = false,
    };
    const perfaware_dir = try fs.openDirAbsolute("/home/drew/personal/computer_enhance/perfaware", dir_options);
    const part_1 = try perfaware_dir.openDir("part1", dir_options);

    try readInstructions(part_1, "listing_0037_single_register_mov");
    try readInstructions(part_1, "listing_0038_many_register_mov");
}

fn readInstructions(dir: fs.Dir, exe: []const u8) !void {
    print("Reading instructions from {s}\n", .{exe});
    const exe_file = try dir.openFile(exe, .{ .mode = .read_only });

    var buf: [1024 * 1024]u8 = undefined;
    var reader = exe_file.reader(&buf);

    while (true) {
        // pop next byte from reader
        const byte = reader.interface.takeByte() catch |err| {
            const etype = std.Io.Reader.Error;
            switch (err) {
                etype.EndOfStream => break,
                etype.ReadFailed => return err,
            }
        };
        print("byte read: {b}\n", .{byte});

        // interpret byte
    }
}
