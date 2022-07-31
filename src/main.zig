const std = @import("std");

const Lifegame = struct {
    alloc: std.mem.Allocator,
    row: usize,
    col: usize,
    grid: std.ArrayList(std.ArrayList(bool)),

    const Self = @This();

    pub fn init(alloc: std.mem.Allocator, row: usize, col: usize) !Self {
        var grid = std.ArrayList(std.ArrayList(bool)).init(alloc);
        var r: usize = 0;
        while (r < row) : (r += 1) {
            var a = std.ArrayList(bool).init(alloc);
            var c: usize = 0;
            while (c < col) : (c += 1) {
                const v = std.crypto.random.int(usize) % 10 == 0;
                try a.append(v);
            }

            try grid.append(a);
        }

        return Self{
            .alloc = alloc,
            .row = row,
            .col = col,
            .grid = grid,
        };
    }

    pub fn deinit(self: *Self) void {
        for (self.grid.items) |row| {
            row.deinit();
        }

        self.grid.deinit();
    }
};

pub fn main() anyerror!void {
    var lg = try Lifegame.init(std.heap.page_allocator, 10, 10);
    defer lg.deinit();

    std.log.info("All your codebase are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
