const std = @import("std");

const Lifegame = struct {
    alloc: std.mem.Allocator,
    row: usize,
    col: usize,
    grid: std.ArrayList(std.ArrayList(bool)),

    const Self = @This();

    pub fn init(alloc: std.mem.Allocator, row: usize, col: usize) !Self {
        const grid = try std.ArrayList(std.ArrayList(bool)).initCapacity(alloc, row);

        return Self{
            .alloc = alloc,
            .row = row,
            .col = col,
            .grid = grid,
        };
    }

    pub fn deinit(self: *Self) void {
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
